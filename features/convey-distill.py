#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# convey-distill.py -- the SessionEnd distiller.
#
# Wired as a Claude Code SessionEnd hook (.claude/settings.json). When a Convey
# conversation ends, this fires, reads the just-finished transcript (path on
# stdin), and plugs the session into Convey LIVE:
#   1. writes a per-session distillation STUB at features/sessions/<id>.md
#      (metadata + touched cards/tools + resume command + @distill-pending), and
#   2. regenerates features/CONVEY-SESSIONS.generated.md (the registry).
#
# !! EXIT-HOOK DISCIPLINE: it must return INSTANTLY or Claude cancels it.
#    (2026-06-05: the first version ran ~2.1s synchronously -- it scanned every
#    transcript via gen-sessions -- and on `exit` Claude reported "Hook
#    cancelled".) So: read stdin, then DETACH (fork + setsid) and let the PARENT
#    return 0 immediately; the detached child does the seconds-long work in its
#    own session, surviving the hook's exit. No fork available -> do only the
#    fast stub and skip the registry, still returning fast.
#
# Never touches git (shared working tree; auto-commit would race). Metadata only
# -- no dialogue text (the repo is public). Fully defensive: any error -> exit 0.
# Honest scope: a STUB distiller; a true vibe-diff is still a human/agent act.
# -----------------------------------------------------------------------------
import sys, os, json, re, subprocess, datetime

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
FEAT = os.path.join(REPO, 'features')

RELEVANCE = ('convey', '.feature', 'report card', 'report-card', 'features/')
FEATURE_RE = re.compile(r'features/[A-Za-z0-9_.-]+\.feature')
TOOL_HINTS = ('gen-status.py', 'gen-sessions.py', 'convey-distill.py', 'CONVEY.md',
              'CONVEY-SITUATION.md', 'STATUS.md', 'INDEX.md', '.githooks/pre-commit',
              '.githooks/post-merge', 'report-card-stamp.sh')


def do_work(sid, tx, full):
    """Heavy part: scan the one transcript, write the stub, (optionally) refresh
    the registry. Runs in the detached child so it can take its time."""
    try:
        real_cards = {p for p in os.listdir(FEAT) if p.endswith('.feature')}
    except Exception:
        real_cards = set()

    relevant = False
    first = last = None
    touched = set()
    try:
        for line in open(tx, encoding='utf-8'):
            lo = line.lower()
            if not relevant and any(k in lo for k in RELEVANCE):
                relevant = True
            for m in FEATURE_RE.findall(line):
                nm = m.split('/')[-1]
                if nm in real_cards:
                    touched.add(nm)
            for t in TOOL_HINTS:
                if t in line:
                    touched.add(t)
            try:
                ts = json.loads(line).get('timestamp')
                if ts:
                    d = ts[:10]
                    if first is None or d < first: first = d
                    if last is None or d > last: last = d
            except Exception:
                pass
    except Exception:
        return
    if not relevant:
        return

    # per-session stub
    try:
        sdir = os.path.join(FEAT, 'sessions')
        os.makedirs(sdir, exist_ok=True)
        span = first if first == last else f'{first} → {last}'
        cards = sorted(t for t in touched if t.endswith('.feature'))
        tools = sorted(t for t in touched if not t.endswith('.feature'))
        topic = (', '.join(cards[:6]) + (f' (+{len(cards)-6})' if len(cards) > 6 else '')) \
            if cards else (', '.join(tools[:6]) if tools else 'convey (no cards touched)')
        b = [f'# Convey session stub — `{sid}`', '',
             '> Auto-written by the SessionEnd distiller (`features/convey-distill.py`).',
             '> METADATA STUB, not a full vibe-diff. `@distill-pending` — a human/agent',
             '> resumes and fleshes this into a real `<name>.session.md` if it holds',
             '> decisions worth keeping. No dialogue text is stored here.', '',
             f'- **Span:** {span}',
             f'- **Topic (derived from touched):** {topic}',
             f'- **Resume:** `claude --resume {sid}`',
             f'- **Transcript:** file://{tx}']
        if cards: b.append(f'- **Cards touched ({len(cards)}):** {", ".join(cards)}')
        if tools: b.append(f'- **Tooling touched:** {", ".join(tools)}')
        b.append('- **Status:** `@distill-pending`')
        b.append('')
        text = '\n'.join(b)
        dst = os.path.join(sdir, f'{sid}.md')
        old = open(dst, encoding='utf-8').read() if os.path.exists(dst) else ''
        if text != old:
            open(dst, 'w', encoding='utf-8').write(text)
        with open(os.path.join(sdir, '.distill-log'), 'a', encoding='utf-8') as lg:
            lg.write(f'{datetime.datetime.now().isoformat(timespec="seconds")}  {sid}  '
                     f'cards={len(cards)} tools={len(tools)} full={full}\n')
    except Exception:
        pass

    # registry refresh (the slow part) -- only in the detached child
    if full:
        try:
            subprocess.run([sys.executable, os.path.join(FEAT, 'gen-sessions.py')],
                           cwd=REPO, timeout=120,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass


def main():
    # read the SessionEnd payload while stdin is still available (fast)
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    sid = payload.get('session_id') or ''
    tx = payload.get('transcript_path') or ''
    if not sid or not tx or not os.path.exists(tx):
        return 0

    # DETACH so the hook returns instantly; the child does the work in its own
    # session and survives `exit`. Fall back to a fast stub-only run if no fork.
    try:
        if os.fork() > 0:
            return 0                       # parent: instant hook return
    except Exception:
        do_work(sid, tx, full=False)       # no fork -> fast path (stub only)
        return 0
    # detached child:
    try: os.setsid()
    except Exception: pass
    try:
        dn = os.open(os.devnull, os.O_RDWR)
        for fd in (0, 1, 2):
            try: os.dup2(dn, fd)
            except Exception: pass
    except Exception:
        pass
    do_work(sid, tx, full=True)            # stub + registry, time no longer matters
    os._exit(0)


if __name__ == '__main__':
    sys.exit(main())
