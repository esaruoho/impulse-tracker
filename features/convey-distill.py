#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# convey-distill.py -- the SessionEnd distiller.
#
# Wired as a Claude Code SessionEnd hook (.claude/settings.json). When a Convey
# conversation ends, it writes a per-session distillation STUB at
# features/sessions/<id>.md (metadata + touched cards/tools + resume command +
# @distill-pending), so the session is plugged into Convey the moment it ends.
#
# !! DESIGN, corrected 2026-06-05 after checking the Claude Code hook docs
#    (claude-code-guide): SessionEnd hooks run SYNCHRONOUSLY and BLOCK teardown;
#    "Hook cancelled" means the harness KILLED the hook during teardown (e.g.
#    Ctrl+C), NOT a timeout; and DETACHED/background children are NOT guaranteed
#    to survive (Claude kills the hook's process group on exit). So:
#      - do the work SYNCHRONOUSLY and FAST (no fork/detach -- that was wrong);
#      - keep it to the ONE transcript's stub (cheap); do NOT regenerate the
#        whole registry here (scanning every transcript is ~2s -- too slow to
#        block teardown). The registry (CONVEY-SESSIONS.generated.md) refreshes
#        on the next commit via .githooks/pre-commit, or `features/gen-all.sh`.
#      - on every fire, FIRST capture the raw stdin payload + a FIRED log line,
#        so the next real exit is empirical proof (schema + that it ran), even if
#        parsing fails.
#
# Caveats it cannot fix (Claude Code bugs): exiting via Ctrl+C cancels the hook
# (#32712); /clear does not fire SessionEnd (#6428). It reliably runs on a normal
# `exit`. Never touches git. Metadata only (public repo). Defensive: exit 0.
# -----------------------------------------------------------------------------
import sys, os, json, re, datetime

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
FEAT = os.path.join(REPO, 'features')
SDIR = os.path.join(FEAT, 'sessions')

RELEVANCE = ('convey', '.feature', 'report card', 'report-card', 'features/')
FEATURE_RE = re.compile(r'features/[A-Za-z0-9_.-]+\.feature')
TOOL_HINTS = ('gen-status.py', 'gen-sessions.py', 'convey-distill.py', 'CONVEY.md',
              'CONVEY-SITUATION.md', 'STATUS.md', 'INDEX.md', '.githooks/pre-commit',
              '.githooks/post-merge', 'report-card-stamp.sh')


def log(msg):
    try:
        with open(os.path.join(SDIR, '.distill-log'), 'a', encoding='utf-8') as lg:
            lg.write(f'{datetime.datetime.now().isoformat(timespec="seconds")}  {msg}\n')
    except Exception:
        pass


def main():
    raw = sys.stdin.read()
    # EMPIRICAL proof-of-fire FIRST: capture the raw payload + a FIRED line, so the
    # next real exit shows it ran and what the actual schema is, even if parse fails.
    try:
        os.makedirs(SDIR, exist_ok=True)
        with open(os.path.join(SDIR, '.last-payload.json'), 'w', encoding='utf-8') as f:
            f.write(raw)
    except Exception:
        pass
    log(f'FIRED  bytes={len(raw)}')

    try:
        payload = json.loads(raw)
    except Exception:
        log('PARSE-FAIL  (raw payload captured in .last-payload.json)')
        return 0
    sid = payload.get('session_id') or ''
    tx = payload.get('transcript_path') or ''
    reason = payload.get('reason') or '?'
    if not sid or not tx or not os.path.exists(tx):
        log(f'SKIP  sid={bool(sid)} tx_exists={os.path.exists(tx) if tx else False} keys={list(payload)}')
        return 0

    # SYNCHRONOUS, single transcript -> stub. Fast enough to finish before teardown.
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
        log('SCAN-FAIL')
        return 0
    if not relevant:
        log(f'NOT-CONVEY  sid={sid[:8]}')
        return 0

    try:
        span = first if first == last else f'{first} → {last}'
        cards = sorted(t for t in touched if t.endswith('.feature'))
        tools = sorted(t for t in touched if not t.endswith('.feature'))
        topic = (', '.join(cards[:6]) + (f' (+{len(cards)-6})' if len(cards) > 6 else '')) \
            if cards else (', '.join(tools[:6]) if tools else 'convey (no cards touched)')
        b = [f'# Convey session stub — `{sid}`', '',
             '> Auto-written by the SessionEnd distiller (`features/convey-distill.py`).',
             '> METADATA STUB, not a full vibe-diff. `@distill-pending`. No dialogue text.',
             '> The registry (CONVEY-SESSIONS.generated.md) refreshes on the next commit,',
             '> not here -- SessionEnd must stay fast.', '',
             f'- **Span:** {span}',
             f'- **End reason:** {reason}',
             f'- **Topic (derived from touched):** {topic}',
             f'- **Resume:** `claude --resume {sid}`',
             f'- **Transcript:** file://{tx}']
        if cards: b.append(f'- **Cards touched ({len(cards)}):** {", ".join(cards)}')
        if tools: b.append(f'- **Tooling touched:** {", ".join(tools)}')
        b.append('- **Status:** `@distill-pending`')
        b.append('')
        text = '\n'.join(b)
        dst = os.path.join(SDIR, f'{sid}.md')
        old = open(dst, encoding='utf-8').read() if os.path.exists(dst) else ''
        if text != old:
            open(dst, 'w', encoding='utf-8').write(text)
        log(f'DONE  sid={sid[:8]} cards={len(cards)} tools={len(tools)} reason={reason}')
    except Exception:
        log('STUB-FAIL')
    return 0


if __name__ == '__main__':
    sys.exit(main())
