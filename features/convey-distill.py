#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# convey-distill.py -- the SessionEnd distiller.
#
# Wired as a Claude Code SessionEnd hook (.claude/settings.json). When a Convey
# conversation ends, this fires, reads the just-finished transcript (path comes
# in on stdin), and -- without waiting for a card-commit -- plugs the session
# into Convey LIVE:
#   1. regenerates features/CONVEY-SESSIONS.generated.md (the registry), and
#   2. writes a per-session distillation STUB at features/sessions/<id>.md
#      (metadata + touched cards/tools + resume command + @distill-pending), so
#      a human/agent can later flesh it into a full .session.md vibe-diff.
#
# It NEVER touches git (the working tree is shared by parallel sessions; auto-
# commit would race). It writes files only; the next commit's pre-commit hook
# carries them into git. It is fully DEFENSIVE: any error -> exit 0, so it can
# never disrupt a session ending. Metadata only -- no dialogue text is copied
# (privacy: the repo is public; the topic is derived from touched cards, not the
# user's words).
#
# Honest scope: this is a STUB distiller. It registers + summarizes by metadata;
# a true vibe-diff (the dialogue distilled) is still a human/agent act. Grade in
# the card: @runtime-untested for the real SessionEnd firing until observed.
# -----------------------------------------------------------------------------
import sys, os, json, re, subprocess, datetime

def main():
    # repo root = parent of this script's dir (reliable regardless of cwd)
    here = os.path.dirname(os.path.abspath(__file__))
    repo = os.path.dirname(here)
    feat = os.path.join(repo, 'features')

    # --- read the SessionEnd payload from stdin (defensive) ---
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    sid = payload.get('session_id') or ''
    tx = payload.get('transcript_path') or ''
    if not sid or not tx or not os.path.exists(tx):
        return 0

    # --- only act on Convey-relevant transcripts ---
    RELEVANCE = ('convey', '.feature', 'report card', 'report-card', 'features/')
    FEATURE_RE = re.compile(r'features/[A-Za-z0-9_.-]+\.feature')
    TOOL_HINTS = ('gen-status.py', 'gen-sessions.py', 'convey-distill.py', 'CONVEY.md',
                  'CONVEY-SITUATION.md', 'STATUS.md', 'INDEX.md', '.githooks/pre-commit',
                  '.githooks/post-merge', 'report-card-stamp.sh')
    real_cards = set()
    try:
        for p in os.listdir(feat):
            if p.endswith('.feature'):
                real_cards.add(p)
    except Exception:
        pass

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
                o = json.loads(line)
                ts = o.get('timestamp')
                if ts:
                    d = ts[:10]
                    if first is None or d < first: first = d
                    if last is None or d > last: last = d
            except Exception:
                pass
    except Exception:
        return 0
    if not relevant:
        return 0

    # --- 1) regenerate the registry (reuse gen-sessions.py; defensive) ---
    try:
        subprocess.run([sys.executable, os.path.join(feat, 'gen-sessions.py')],
                       cwd=repo, timeout=60,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

    # --- 2) write the per-session distillation stub ---
    try:
        sdir = os.path.join(feat, 'sessions')
        os.makedirs(sdir, exist_ok=True)
        span = first if first == last else f'{first} → {last}'
        cards = sorted(t for t in touched if t.endswith('.feature'))
        tools = sorted(t for t in touched if not t.endswith('.feature'))
        topic = ', '.join(cards[:6]) + (f' (+{len(cards)-6})' if len(cards) > 6 else '') \
                if cards else (', '.join(tools[:6]) if tools else 'convey (no cards touched)')
        body = []
        body.append(f'# Convey session stub — `{sid}`')
        body.append('')
        body.append('> Auto-written by the SessionEnd distiller (`features/convey-distill.py`).')
        body.append('> METADATA STUB, not a full vibe-diff. `@distill-pending` — a human/agent')
        body.append('> resumes the session and fleshes this into a real `<name>.session.md` if it')
        body.append('> holds decisions worth keeping. No dialogue text is stored here.')
        body.append('')
        body.append(f'- **Span:** {span}')
        body.append(f'- **Topic (derived from touched):** {topic}')
        body.append(f'- **Resume:** `claude --resume {sid}`')
        body.append(f'- **Transcript:** file://{tx}')
        if cards:
            body.append(f'- **Cards touched ({len(cards)}):** {", ".join(cards)}')
        if tools:
            body.append(f'- **Tooling touched:** {", ".join(tools)}')
        body.append('- **Status:** `@distill-pending`')
        body.append('')
        text = '\n'.join(body)
        dst = os.path.join(sdir, f'{sid}.md')
        old = open(dst, encoding='utf-8').read() if os.path.exists(dst) else ''
        if text != old:
            open(dst, 'w', encoding='utf-8').write(text)
        # proof-of-fire log (local; gitignored)
        with open(os.path.join(sdir, '.distill-log'), 'a', encoding='utf-8') as lg:
            lg.write(f'{datetime.datetime.now().isoformat(timespec="seconds")}  {sid}  '
                     f'cards={len(cards)} tools={len(tools)}\n')
    except Exception:
        pass

    return 0

if __name__ == '__main__':
    sys.exit(main())
