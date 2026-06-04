#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# gen-hwtest.py -- generate features/HARDWARE-TEST.md, a PER-SCENARIO hardware
# acceptance checklist for IT.EXE on real DOS metal.
#
# Every scenario that is NOT @hw-verified / @hw-tested is RED-LINED (🔴) so the
# tester can focus on it after flashing the build to hardware. Scenarios that
# ARE hardware-verified show ✅ and drop off the focus list.
#
# Source of truth = the .feature cards (their @grade tags). This file is derived;
# regenerate with `python3 features/gen-hwtest.py`. Pass the build label as argv[1]
# (e.g. "v2.354-2026-06-04 @95a4f9e"); defaults to "(unspecified build)".
# -----------------------------------------------------------------------------
import glob, os, sys

EXCLUDE = {
    'session-changes-codespace.feature',
    'recent-features-2026-06-03_to_04.feature',
    'day-2026-06-03.feature',
    'session-2026-06-03-multitimbral-and-whitelabel.feature',
    'session-2026-06-04-order-list-and-hw-test.feature',
}
HW_OK = {'@hw-verified', '@hw-tested'}

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FEAT = os.path.join(ROOT, 'features')


def scenarios(path):
    """Yield (title, tagset) for each Scenario, using the @tag line above it."""
    out, pending = [], []
    for line in open(path, encoding='utf-8'):
        s = line.strip()
        if s.startswith('@'):
            pending = [t for t in s.split() if t.startswith('@')]
        elif s.startswith('Scenario:'):
            out.append((s[len('Scenario:'):].strip(), set(pending)))
            pending = []
    return out


def hint(tags):
    if '@runtime-verified' in tags and '@runtime-untested' in tags:
        return 'DOSBox: mixed'
    if '@runtime-verified' in tags:
        return 'DOSBox ✓ (quick re-confirm on metal)'
    if '@runtime-untested' in tags:
        return 'DOSBox ✗ — UNTESTED even in emulation'
    if '@stock' in tags:
        return 'stock/upstream — low risk'
    return ''


def is_fork(tags):
    # a fork behaviour (something this fork changed) vs pure upstream stock
    return '@shipped' in tags or '@bug' in tags or '@fixed-pending-verify' in tags


def main():
    build = sys.argv[1] if len(sys.argv) > 1 else '(unspecified build)'
    fork_cards, stock_only = [], []
    total = redline = hw_done = 0

    for path in sorted(glob.glob(os.path.join(FEAT, '*.feature'))):
        name = os.path.basename(path)
        if name in EXCLUDE:
            continue
        scns = scenarios(path)
        if not scns:
            continue
        card = name[:-len('.feature')]
        rows = []
        any_fork = False
        for title, tags in scns:
            total += 1
            hw = bool(tags & HW_OK)
            if hw:
                hw_done += 1
                box = 'OK [x]'
                lead = '✅'
            else:
                redline += 1
                box = '[ ]'
                lead = '🔴'
            if is_fork(tags):
                any_fork = True
            rows.append((lead, box, title, hint(tags), is_fork(tags)))
        (fork_cards if any_fork else stock_only).append((card, rows))

    L = []
    L.append('# Hardware Test Sheet — IT.EXE on real DOS metal\n')
    L.append('> **GENERATED** from the `.feature` cards by `features/gen-hwtest.py`. '
             'Do not hand-edit. A scenario is **🔴 RED-LINED** until its card is graded '
             '`@hw-verified`; flip the card tag (runtime→hardware) and regenerate.\n')
    L.append('**Build under test:** `%s`  ·  put this IT.EXE on the DOS machine and work the 🔴 list.\n' % build)
    L.append('**Record results without burning chat:** run `./test-impulse-tracker` from the repo '
             '(works from any dir) — the TUI walks these, takes works/failed/notes, flips passes to '
             '`@hw-verified`, and writes `features/HW-FAILURES.md` (the only thing to send back).\n')
    L.append('**Focus order:** (1) 🔴 fork features below, DOSBox ✓ first (fast confirm), '
             'then DOSBox ✗ (never even emulated). (2) Stock/upstream last (low risk).\n')
    L.append('| | Count |\n|---|---:|\n| Total scenarios | %d |\n| 🔴 Need hardware test | %d |\n| ✅ Hardware-verified | %d |\n'
             % (total, redline, hw_done))
    L.append('\n---\n')

    L.append('## 🔴 Fork features — test these on the metal\n')
    for card, rows in fork_cards:
        fork_rows = [r for r in rows if r[4]]
        if not fork_rows:
            continue
        L.append('\n### `%s`' % card)
        for lead, box, title, h, _ in fork_rows:
            L.append('- %s %s %s%s' % (lead, box, title, ('  — _%s_' % h if h else '')))
    L.append('')

    # stock scenarios (within fork cards + pure-stock cards), low priority
    L.append('\n---\n')
    L.append('## Stock / upstream behaviours (low priority — verify only if time)\n')
    for card, rows in fork_cards + stock_only:
        stock_rows = [r for r in rows if not r[4]]
        if not stock_rows:
            continue
        L.append('\n### `%s`' % card)
        for lead, box, title, h, _ in stock_rows:
            L.append('- %s %s %s%s' % (lead, box, title, ('  — _%s_' % h if h else '')))
    L.append('')

    out = os.path.join(FEAT, 'HARDWARE-TEST.md')
    with open(out, 'w', encoding='utf-8') as f:
        f.write('\n'.join(L) + '\n')
    print('wrote %s' % os.path.relpath(out, ROOT))
    print('  total=%d  redline(🔴)=%d  hw-verified(✅)=%d' % (total, redline, hw_done))


if __name__ == '__main__':
    main()
