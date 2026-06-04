#!/usr/bin/env python3
"""hwtest.py -- interactive hardware-test runner for the IT.EXE fork changes.

Walks every FORK scenario that is not yet @hw-verified, shows you the steps
(Given/When/Then), and lets you record a verdict per item:

    [w] works      -> flips that scenario's @hw-untested -> @hw-verified in the card
    [f] failed     -> asks "how did it fail?" and logs it to features/HW-FAILURES.md
    [d] duplicate  -> tags the scenario @duplicate, drops it from the walk forever,
                      logs it to features/DUPLICATES.md (Convey-prune: redundant
                      branch, recorded with a reason). Auto-warns when an item has
                      the SAME steps as another so duplicates are easy to spot.
    [s] skip        [b] back        [q] quit & save

Saves after EVERY answer (features/hwtest-results.json), so it is fully
resumable -- quit any time, rerun, it picks up where you left off. On exit it
regenerates STATUS.md + HARDWARE-TEST.md and writes HW-FAILURES.md (the only
thing you need to send back). No dependencies, plain terminal.

Run:  python3 features/hwtest.py            # walk the unverified fork list
      python3 features/hwtest.py --reset     # forget prior verdicts, start over
      python3 features/hwtest.py --failures   # just (re)write HW-FAILURES.md
"""
import glob, json, os, sys, subprocess

# FEATURE-CARD >> features/convey-test-runner.feature
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FEAT = os.path.join(ROOT, 'features')
RESULTS = os.path.join(FEAT, 'hwtest-results.json')

EXCLUDE = {
    'session-changes-codespace.feature', 'recent-features-2026-06-03_to_04.feature',
    'day-2026-06-03.feature', 'session-2026-06-03-multitimbral-and-whitelabel.feature',
    'session-2026-06-04-order-list-and-hw-test.feature',
    'convey-test-runner.feature',  # this very runner -- don't list itself as a test
}
HW_OK = {'@hw-verified', '@hw-tested'}
DUP_OK = {'@duplicate'}   # user judged it a redundant branch; suppressed from the walk
STEP_KW = ('Given', 'When', 'Then', 'And', 'But')


def sig(title, steps):
    """Normalized signature (title + steps, lowercased, whitespace-collapsed) used
    to auto-spot exact duplicates across cards."""
    return ' '.join((title + ' ' + ' '.join(steps)).lower().split())


def parse_card(path):
    """Yield dicts: {title, tags(list), steps(list), tag_lineno(0-based)}."""
    lines = open(path, encoding='utf-8').read().splitlines()
    out, pending, pending_ln = [], [], -1
    i = 0
    while i < len(lines):
        s = lines[i].strip()
        if s.startswith('@'):
            pending = [t for t in s.split() if t.startswith('@')]
            pending_ln = i
        elif s.startswith('Scenario:'):
            title = s[len('Scenario:'):].strip()
            steps = []
            j = i + 1
            while j < len(lines):
                t = lines[j].strip()
                if t.startswith('Scenario:') or (t.startswith('@') and not t.startswith('# ')):
                    break
                if t.split(' ', 1)[0] in STEP_KW:
                    steps.append(t)
                j += 1
            out.append({'title': title, 'tags': pending, 'steps': steps,
                        'tag_lineno': pending_ln})
            pending, pending_ln = [], -1
            i = j
            continue
        i += 1
    return out, lines


def is_fork(tags):
    return any(t in ('@shipped', '@bug', '@fixed-pending-verify') for t in tags)


def load_items():
    """All fork scenarios not yet @hw-verified, DOSBox-verified first."""
    items = []
    for path in sorted(glob.glob(os.path.join(FEAT, '*.feature'))):
        name = os.path.basename(path)
        if name in EXCLUDE:
            continue
        scns, _ = parse_card(path)
        for sc in scns:
            tags = set(sc['tags'])
            if not is_fork(tags) or (tags & HW_OK) or (tags & DUP_OK):
                continue
            items.append({'card': name[:-8], 'path': path,
                          'title': sc['title'], 'tags': sc['tags'],
                          'steps': sc['steps']})
    # DOSBox-verified first (fast confirm), then mixed, then untested
    def rank(it):
        t = set(it['tags'])
        if '@runtime-verified' in t and '@runtime-untested' not in t:
            return 0
        if '@runtime-verified' in t:
            return 1
        return 2
    items.sort(key=rank)
    return items


def flip_tag(path, title, newtag, replace=None):
    """On the tag line above `Scenario: <title>`, add `newtag` (replacing
    `replace` if given and present). Idempotent. Returns True on success."""
    scns, lines = parse_card(path)
    target = next((s for s in scns if s['title'] == title), None)
    if not target or target['tag_lineno'] < 0:
        return False
    ln = target['tag_lineno']
    raw = lines[ln]
    if newtag in raw:
        return True
    if replace and replace in raw:
        lines[ln] = raw.replace(replace, newtag)
    else:
        lines[ln] = raw.rstrip() + ' ' + newtag
    open(path, 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
    return True


def flip_tag_to_hw_verified(path, title):
    return flip_tag(path, title, '@hw-verified', replace='@hw-untested')


def regen():
    label = ''
    try:
        h = subprocess.check_output(['git', '-C', ROOT, 'rev-parse', '--short', 'HEAD']).decode().strip()
        label = '@' + h
    except Exception:
        pass
    for script, arg in (('gen-status.py', None), ('gen-hwtest.py', label or None)):
        p = os.path.join(FEAT, script)
        if os.path.exists(p):
            cmd = [sys.executable, p] + ([arg] if arg else [])
            try:
                subprocess.run(cmd, cwd=ROOT, check=False,
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            except Exception:
                pass


def write_failures(results):
    fails = {k: v for k, v in results.items() if v.get('verdict') == 'fail'}
    out = os.path.join(FEAT, 'HW-FAILURES.md')
    L = ['# Hardware test FAILURES — send these back\n',
         '> Generated by `features/hwtest.py`. Each entry is a fork scenario that '
         'FAILED on real hardware, with your note. This is the focused worklist.\n']
    if not fails:
        L.append('_No failures recorded._\n')
    else:
        for k, v in fails.items():
            card, title = k.split('::', 1)
            L.append('\n## 🔴 `%s` — %s' % (card, title))
            L.append('**How it failed:** %s\n' % (v.get('note') or '(no note)'))
    open(out, 'w', encoding='utf-8').write('\n'.join(L) + '\n')
    return len(fails)


def write_duplicates(results):
    dups = {k: v for k, v in results.items() if v.get('verdict') == 'duplicate'}
    out = os.path.join(FEAT, 'DUPLICATES.md')
    L = ['# Duplicate scenarios — pruned from the hardware walk\n',
         '> Generated by `features/hwtest.py`. Each entry is a scenario you judged a '
         'redundant duplicate (tagged `@duplicate` in its card, dropped from the walk). '
         'Convey-prune: a malformed/redundant branch, recorded WITH a reason — never a '
         'silent delete.\n']
    if not dups:
        L.append('_No duplicates marked._\n')
    else:
        for k, v in dups.items():
            card, title = k.split('::', 1)
            L.append('\n## ⊘ `%s` — %s' % (card, title))
            L.append('**Duplicate of:** %s\n' % (v.get('note') or '(unspecified)'))
    open(out, 'w', encoding='utf-8').write('\n'.join(L) + '\n')
    return len(dups)


CLR = '\033[2J\033[H'


def getch():
    """Read ONE keypress without waiting for Enter (raw tty). Ctrl-C/Ctrl-D ->
    'q'. Falls back to a line read when stdin isn't a tty (piped/smoke tests)."""
    try:
        import termios, tty
        fd = sys.stdin.fileno()
        old = termios.tcgetattr(fd)
        try:
            tty.setraw(fd)
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old)
        if ch in ('\x03', '\x04'):       # Ctrl-C / Ctrl-D
            return 'q'
        return ch
    except Exception:
        line = sys.stdin.readline()
        return line[:1] if line else 'q'


def main():
    args = sys.argv[1:]
    results = {}
    if os.path.exists(RESULTS) and '--reset' not in args:
        try:
            results = json.load(open(RESULTS))
        except Exception:
            results = {}
    if '--reset' in args:
        results = {}
    if '--failures' in args:
        n = write_failures(results)
        print('wrote features/HW-FAILURES.md (%d failures)' % n)
        return 0

    items = load_items()
    # signature -> [keys] so we can warn when two scenarios have identical steps
    sigmap = {}
    for it in items:
        sigmap.setdefault(sig(it['title'], it['steps']), []).append(it['card'] + '::' + it['title'])
    todo = [it for it in items if (it['card'] + '::' + it['title']) not in results]
    print(CLR + 'IT.EXE hardware test — %d fork scenarios, %d already answered, %d to go.\n'
          % (len(items), len(items) - len(todo), len(todo)))
    if not todo:
        print('Everything answered. Regenerating reports...')
    else:
        input('Test each on the DOS machine, then record here. Enter to start... ')

    i = 0
    order = todo
    while 0 <= i < len(order):
        it = order[i]
        key = it['card'] + '::' + it['title']
        t = set(it['tags'])
        dosbox = ('DOSBox ✓ (quick re-confirm)' if '@runtime-verified' in t and '@runtime-untested' not in t
                  else 'DOSBox ✓/✗ mixed' if '@runtime-verified' in t
                  else 'DOSBox ✗ — never emulated, test carefully')
        print(CLR)
        print('[%d/%d]  %s\n' % (i + 1, len(order), it['card']))
        print('  %s\n' % it['title'])
        for st in it['steps']:
            print('     %s' % st)
        print('\n  status: %s' % dosbox)
        # Auto-spot exact duplicates: any other scenario with identical steps?
        twins = [k for k in sigmap.get(sig(it['title'], it['steps']), []) if k != key]
        for tw in twins:
            mark = ''
            if tw in results:
                mark = ' [already %s]' % results[tw].get('verdict')
            print('  \033[33m⚠ same steps as: %s%s\033[0m' % (tw, mark))
        print('\n  [w]orks  [f]ailed  [d]uplicate  [s]kip  [b]ack  [q]uit&save')
        sys.stdout.write('  > '); sys.stdout.flush()
        ans = getch().lower()
        print(ans if ans.strip() else '')   # echo the keystroke (raw mode won't)
        if ans == 'q':
            break
        if ans == 'b':
            i = max(0, i - 1)
            continue
        if ans == 's':
            results[key] = {'verdict': 'skip', 'note': ''}
        elif ans == 'f':
            note = input('  how did it fail? > ').strip()
            results[key] = {'verdict': 'fail', 'note': note}
        elif ans == 'w':
            results[key] = {'verdict': 'pass', 'note': ''}
        elif ans == 'd':
            ref = input('  duplicate of? (card::scenario, or Enter for the twin above) > ').strip()
            if not ref and twins:
                ref = twins[0]
            results[key] = {'verdict': 'duplicate', 'note': ref}
        else:
            continue  # unrecognised -> re-show same item
        json.dump(results, open(RESULTS, 'w'), indent=1)
        i += 1

    # apply: flip passes to @hw-verified, mark duplicates @duplicate, in the cards
    flipped = dup = 0
    for it in items:
        key = it['card'] + '::' + it['title']
        verdict = results.get(key, {}).get('verdict')
        if verdict == 'pass':
            if flip_tag_to_hw_verified(it['path'], it['title']):
                flipped += 1
        elif verdict == 'duplicate':
            if flip_tag(it['path'], it['title'], '@duplicate'):
                dup += 1
    nfail = write_failures(results)
    ndup = write_duplicates(results)
    regen()
    print(CLR + 'Saved. %d hardware-verified, %d duplicates pruned, %d failures logged.'
          % (flipped, dup, nfail))
    print('  - features/HW-FAILURES.md  (send this back)')
    print('  - features/DUPLICATES.md   (scenarios you marked @duplicate)')
    print('  - features/STATUS.md + HARDWARE-TEST.md regenerated')
    print('  - card tags flipped for passes + duplicates (commit them: git add -A && git commit)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
