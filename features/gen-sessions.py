#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# gen-sessions.py -- plug the Claude CONVERSATIONS directly into the Convey
# tooling. Scans this project's Claude transcripts and GENERATES
# features/CONVEY-SESSIONS.generated.md: every Convey-relevant session, with its
# date span, a `claude --resume <id>` get-back command, and the Convey artifacts
# it touched (cards / generators / hooks it mentions). Conversation <-> tooling,
# auto-linked -- nobody hand-types the session list (Convey Principle 1).
#
# Reads ONLY metadata + filename mentions from the transcripts; it never copies
# conversation content into the repo. Transcripts live OUTSIDE the repo and are
# machine-local, so this is defensive: if the transcripts dir is absent (another
# clone / CI), it leaves the existing generated file untouched and exits 0.
#
# Output is kept STABLE (date-level spans, sorted sets -- no minute timestamps or
# line counts) so it only changes when a new session appears or a session reaches
# a new day / touches a new artifact, not on every commit.
# -----------------------------------------------------------------------------
import json, glob, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FEAT = os.path.join(ROOT, 'features')
# Claude stores transcripts per project under a slugified abs-path dir.
SLUG = os.path.abspath(ROOT).replace('/', '-')
TX_DIR = os.path.expanduser(f'~/.claude/projects/{SLUG}')

RELEVANCE = ('convey', '.feature', 'report card', 'report-card', 'features/')
FEATURE_RE = re.compile(r'features/[A-Za-z0-9_.-]+\.feature')
TOOL_HINTS = ('gen-status.py', 'gen-sessions.py', 'CONVEY.md', 'CONVEY-SITUATION.md',
              'STATUS.md', 'INDEX.md', '.githooks/pre-commit', '.githooks/post-merge',
              'report-card-stamp.sh', 'GHERKIN-FEATURE-WIKI-PATTERN.md')

def scan(path):
    """Return (first_date, last_date, touched_set) or None if not Convey-relevant."""
    first = last = None
    touched = set()
    relevant = False
    blob_lo = ''
    try:
        for line in open(path, encoding='utf-8'):
            try:
                o = json.loads(line)
            except Exception:
                continue
            ts = o.get('timestamp')
            if ts:
                d = ts[:10]
                if first is None or d < first: first = d
                if last is None or d > last: last = d
            lo = line.lower()
            if not relevant and any(k in lo for k in RELEVANCE):
                relevant = True
            for m in FEATURE_RE.findall(line):
                touched.add(m.split('/')[-1])
            for t in TOOL_HINTS:
                if t in line:
                    touched.add(t)
    except Exception:
        return None
    if not relevant or first is None:
        return None
    return first, last, touched

def main():
    dst = os.path.join(FEAT, 'CONVEY-SESSIONS.generated.md')
    if not os.path.isdir(TX_DIR):
        print(f'[gen-sessions] transcripts dir absent ({TX_DIR}); leaving generated file as-is')
        return 0
    # Only count cards that ACTUALLY EXIST -- a conversation often mentions example
    # filenames (features/widget.feature, a.feature, index.feature) that aren't real.
    real_cards = {os.path.basename(p) for p in glob.glob(os.path.join(FEAT, '*.feature'))}
    rows = []
    for path in glob.glob(os.path.join(TX_DIR, '*.jsonl')):
        sid = os.path.basename(path)[:-6]   # strip .jsonl
        r = scan(path)
        if not r:
            continue
        first, last, touched = r
        span = first if first == last else f'{first} → {last}'
        feats = sorted(t for t in touched if t.endswith('.feature') and t in real_cards)
        tools = sorted(t for t in touched if not t.endswith('.feature'))
        rows.append((first, sid, span, feats, tools))
    rows.sort()  # by first date, then id

    out = []
    out.append('# Convey — Sessions (GENERATED, DO NOT EDIT BY HAND)')
    out.append('')
    out.append('> Auto-discovered by `features/gen-sessions.py` from this machine\'s Claude')
    out.append('> transcripts. Every Convey-relevant conversation is plugged in here with a')
    out.append('> `claude --resume` get-back command and the Convey artifacts it touched.')
    out.append('> Hand edits are overwritten. Curated roles/distillation notes live in the')
    out.append('> companion `CONVEY-SESSIONS.md`; the single situation in `CONVEY-SITUATION.md`.')
    out.append('>')
    out.append('> Metadata only -- no conversation content is copied into the repo. The list')
    out.append('> reflects the machine it was generated on (transcripts are local).')
    out.append('')
    out.append(f'**{len(rows)} Convey conversations** plugged in:')
    out.append('')
    for first, sid, span, feats, tools in rows:
        out.append(f'### `{sid}`  ({span})')
        out.append(f'- Resume: `claude --resume {sid}`')
        out.append(f'- Transcript: file://{os.path.join(TX_DIR, sid)}.jsonl')
        if tools:
            out.append(f'- Convey tooling touched: {", ".join(tools)}')
        if feats:
            shown = ", ".join(feats[:14]) + (f' … (+{len(feats)-14})' if len(feats) > 14 else '')
            out.append(f'- Cards touched ({len(feats)}): {shown}')
        out.append('')
    text = '\n'.join(out)
    old = open(dst, encoding='utf-8').read() if os.path.exists(dst) else ''
    if text != old:
        open(dst, 'w', encoding='utf-8').write(text)
        print(f'[gen-sessions] CONVEY-SESSIONS.generated.md regenerated ({len(rows)} sessions)')
    else:
        print('[gen-sessions] CONVEY-SESSIONS.generated.md already current')
    return 0

if __name__ == '__main__':
    sys.exit(main())
