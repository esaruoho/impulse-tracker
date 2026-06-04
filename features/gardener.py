#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# gardener.py -- Convey GARDENER, the DETECTOR pass (read-only).
#
# Principle 7 (features/CONVEY.md): Convey is a garden, not just a seed. The cards
# and their reactions accrete around seed nodes; balance (RBI) demands PRUNING of
# MALFORMED branches so the central situation stays wholesome. This script is the
# DETECT half -- it walks the cards + sources and REPORTS malformed branches. It
# NEVER edits, moves, or deletes anything. Pruning (the mutate half) is a separate,
# deliberate, commit-with-a-reason step; detect first, prune second (same discipline
# as VRAM-markers-before-fix).
#
# THE FORK (Principle 7): a faithfully-recorded wrong turn in a .session.md is
# HEALTHY history and is NEVER a finding here. The detector only flags branches that
# are incoherent or contradict current reality -- dead cites, orphan sessions, dead
# back-links, stale duplicates, grade anomalies, index drift.
#
# Apple-native python3, no deps. Safe string scans only (no regex backtracking).
#
#   python3 features/gardener.py            # print the report to stdout
#   python3 features/gardener.py --report   # also write features/GARDENER.md (generated)
#   python3 features/gardener.py --quiet     # only print the summary counts
#
# Exit status: 0 if no PRUNE/DRIFT findings, 1 if any (so a hook/CI could gate on it).
# -----------------------------------------------------------------------------
import glob, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FEAT = os.path.join(ROOT, 'features')

# Cards that are NOT behaviour cards (rollups / meta / host tools). Exempt from the
# "every card needs a .session.md" and "every card is a tracker behaviour" checks.
META = {
    'session-changes-codespace.feature',
    'recent-features-2026-06-03_to_04.feature',
    'day-2026-06-03.feature',
    'session-2026-06-03-multitimbral-and-whitelabel.feature',
    'session-2026-06-04-order-list-and-hw-test.feature',
    'convey-test-runner.feature',
    'convey-gardener.feature',   # this tool's own card -- host-side, not a tracker behaviour
}

# The known grade vocabulary (Principle 5 ladder + status tags). A Scenario with no
# tag from this set is a grade anomaly.
GRADE_TAGS = {
    '@stock', '@shipped', '@build-verified', '@code-verified',
    '@runtime-verified', '@runtime-untested', '@hw-verified', '@hw-untested',
    '@todo', '@bug', '@fixed-pending-verify', '@blocked-by-architecture',
    '@analysis-verified', '@designed', '@sim-verified', '@untested',
    '@known-limit', '@removed', '@wont-build',
}

# Markers that flag a branch the maintainer already called dead-but-not-yet-pruned.
STALE_MARKERS = ('(stale duplicate)', 'COVERED BY', '*(superseded)*', '(superseded)')

# Source lives in repo root AND in the driver trees (WAVDRV.ASM etc. are cited).
SRC_GLOBS = ['*.ASM', '*.INC', 'SoundDrivers/*.ASM', 'SoundDrivers/*.INC',
             'Network/*.ASM', 'Network/*.INC']
DOC_DIRS = ['ReleaseDocumentation', 'InternalDocumentation']


def load_sources():
    """Concatenate all source text once (for fixed-substring symbol checks)."""
    blob = []
    for g in SRC_GLOBS:
        for p in glob.glob(os.path.join(ROOT, g)):
            try:
                blob.append(open(p, encoding='latin-1', errors='replace').read())
            except OSError:
                pass
    return '\n'.join(blob)


def repo_filenames():
    """Set of basenames the cites might reference (sources + docs)."""
    names = set()
    for g in SRC_GLOBS:
        for p in glob.glob(os.path.join(ROOT, g)):
            names.add(os.path.basename(p).upper())
    for d in DOC_DIRS:
        for p in glob.glob(os.path.join(ROOT, d, '*')):
            names.add(os.path.basename(p).upper())
    # repo-root docs too (CLAUDE.md, GHERKIN-FEATURE-WIKI-PATTERN.md, etc.)
    for p in glob.glob(os.path.join(ROOT, '*.md')):
        names.add(os.path.basename(p).upper())
    return names


def cite_tokens(line):
    """From a '# cite:' line, return (files, symbols).
    files   = tokens that look like FOO.ASM / BAR.INC / BAZ.TXT (case-insensitive).
    symbols = underscore-bearing identifiers (LSWindow_ShiftEnter, Music_Stop, ...).
              Underscore is the conservative filter: mnemonics/prose almost never
              carry one, so this avoids false 'dead symbol' alarms.
    """
    files, syms = set(), set()
    # strip a leading 'FILE.ASM:1234-5678' off each token cleanly by char-classing
    for raw in line.replace('/', ' ').replace(',', ' ').replace('(', ' ').replace(')', ' ').split():
        tok = raw.strip(' \t:;')
        up = tok.upper()
        # file token: <name>.<EXT> possibly with a :line suffix already stripped
        base = up.split(':', 1)[0]
        if base.endswith(('.ASM', '.INC', '.TXT')) and len(base) > 4:
            stem = base.rsplit('.', 1)[0]
            # reject globs / prose like "*.ASM" or "16 *.ASM" — stem must be a clean name
            if stem and all(ch.isalnum() or ch == '_' for ch in stem):
                files.add(base)
            continue
        # symbol token: must contain an underscore and be identifier-ish
        core = tok.split(':', 1)[0]
        if '_' in core and len(core) >= 5 and all(c.isalnum() or c == '_' for c in core):
            # drop pure-UPPER constant-looking-with-underscore? keep -- procs can be UPPER
            syms.add(core)
    return files, syms


def parse_card(path):
    """Return dict: name, has_scenarios, scenarios=[{tags:set, line:int}], cites=[(lineno,text)],
    header_text(str)."""
    name = os.path.basename(path)
    lines = open(path, encoding='utf-8').read().splitlines()
    scenarios, cites, session_refs = [], [], []
    pending_tags = set()
    header = []
    for i, line in enumerate(lines, 1):
        s = line.lstrip()
        if s.startswith('#'):
            header.append(s)
        for tok in line.replace('>', ' ').split():
            if tok.endswith('.session.md'):
                session_refs.append(os.path.basename(tok))
        if s.startswith('@'):
            for tok in s.split():
                if tok.startswith('@'):
                    pending_tags.add(tok)
        elif s.startswith('Scenario:'):
            scenarios.append({'tags': set(pending_tags), 'line': i})
            pending_tags = set()
        elif s and not s.startswith('@'):
            # a non-tag, non-blank line that isn't a Scenario resets a dangling tag
            # block only if it's a Feature: line (tags above Feature are card-level)
            if s.startswith('Feature:'):
                pending_tags = set()
        if '# cite:' in line:
            cites.append((i, line.split('# cite:', 1)[1].strip()))
    return {'name': name, 'scenarios': scenarios, 'cites': cites,
            'session_refs': session_refs, 'header': '\n'.join(header)}


def main():
    args = set(sys.argv[1:])
    write_report = '--report' in args
    quiet = '--quiet' in args

    src = load_sources()
    filenames = repo_filenames()
    cards = sorted(glob.glob(os.path.join(FEAT, '*.feature')))
    sessions = sorted(glob.glob(os.path.join(FEAT, '*.session.md')))
    index_path = os.path.join(FEAT, 'INDEX.md')
    index_text = open(index_path, encoding='utf-8').read() if os.path.exists(index_path) else ''

    card_bases = {os.path.basename(c)[:-len('.feature')] for c in cards}
    session_bases = {os.path.basename(s)[:-len('.session.md')] for s in sessions}

    # Parse every card once. Build the set of sessions REFERENCED by any card's
    # `# SESSION >> features/<x>.session.md` header — a shared session (e.g. the
    # F-key cards all point at fkey-report-cards.session.md) is neither orphan nor
    # a missing-session gap.
    parsed = {}
    referenced_sessions = set()
    for path in cards:
        c = parse_card(path)
        parsed[path] = c
        for ref in c['session_refs']:
            referenced_sessions.add(ref[:-len('.session.md')])

    def has_session(base, c):
        if base in session_bases:
            return True
        for ref in c['session_refs']:
            if os.path.exists(os.path.join(FEAT, ref)):
                return True
        return False

    findings = {'PRUNE': [], 'DRIFT': [], 'INCOMPLETE': [], 'INFO': []}

    # 1. Orphan sessions: a .session.md with neither a sibling card NOR any card
    #    pointing at it via SESSION >>.
    for b in sorted(session_bases - card_bases - referenced_sessions):
        findings['DRIFT'].append(('orphan-session', f'{b}.session.md',
                                  'no .feature card owns it (no sibling, no SESSION >> ref)'))

    # Per-card checks.
    for path in cards:
        c = parsed[path]
        name = c['name']
        base = name[:-len('.feature')]
        is_meta = name in META

        # 2. Card missing its session (triad incomplete) -- behaviour cards only.
        if not is_meta and not has_session(base, c):
            findings['INCOMPLETE'].append(('no-session', name,
                                           'triad missing .session.md (no sibling, no SESSION >> ref)'))

        # 3. Stale-duplicate / superseded markers in the card body/header.
        for marker in STALE_MARKERS:
            if marker in c['header']:
                findings['PRUNE'].append(('stale-marker', name, f'header carries "{marker}" -> prune candidate'))
                break

        # 4. Grade anomalies per scenario (behaviour cards only).
        if not is_meta:
            for scn in c['scenarios']:
                t = scn['tags']
                graded = t & GRADE_TAGS
                if not t:
                    findings['DRIFT'].append(('no-grade', f'{name}:{scn["line"]}', 'Scenario has no tag at all'))
                elif not graded:
                    findings['INFO'].append(('unknown-grade', f'{name}:{scn["line"]}',
                                             f'Scenario tags {sorted(t)} include no known @grade'))
                if '@runtime-verified' in t and '@runtime-untested' in t:
                    findings['DRIFT'].append(('grade-contradiction', f'{name}:{scn["line"]}',
                                              'same Scenario tagged @runtime-verified AND @runtime-untested'))
                if '@hw-verified' in t and '@runtime-verified' not in t:
                    findings['INFO'].append(('grade-ladder', f'{name}:{scn["line"]}',
                                             '@hw-verified without @runtime-verified (hw implies runtime; record both?)'))

        # 5. Dead cite file + dead cite symbol (behaviour cards only -- meta cards
        #    cite Python/host tooling, not assembly, so skip them).
        if not is_meta:
            for lineno, text in c['cites']:
                files, syms = cite_tokens(text)
                for f in files:
                    if f not in filenames:
                        findings['DRIFT'].append(('dead-cite-file', f'{name}:{lineno}', f'cited file {f} not found in repo'))
                for sym in syms:
                    if sym not in src:
                        findings['DRIFT'].append(('dead-cite-symbol', f'{name}:{lineno}',
                                                  f'cited symbol "{sym}" not found in any source'))

        # 6. Back-link presence: does any source carry FEATURE-CARD >> features/<base>?
        #    Spec/feasibility cards (no code shipped) legitimately have none -> INFO.
        if not is_meta and f'features/{base}' not in src:
            findings['INFO'].append(('no-backlink', name,
                                     'no source carries FEATURE-CARD >> features/' + base + ' (spec/feasibility cards exempt)'))

        # 7. Not enrolled in INDEX.md.
        if not is_meta and name not in index_text and base not in index_text:
            findings['INFO'].append(('not-in-index', name, 'card not referenced in INDEX.md'))

    # 8. INDEX references to nonexistent card files. Often a PLANNED card under
    #    "Uncarded features", so INFO not DRIFT -- either card it or it's a dead ref.
    for tok in index_text.replace('`', ' ').split():
        t = tok.strip('.,()')
        if t.endswith('.feature') and not os.path.exists(os.path.join(FEAT, t)):
            findings['INFO'].append(('index-ref-no-file', 'INDEX.md', f'names {t} (planned card, or dead ref)'))

    # ---- render ----
    order = ['PRUNE', 'DRIFT', 'INCOMPLETE', 'INFO']
    titles = {
        'PRUNE': 'PRUNE CANDIDATES (maintainer already flagged dead-but-not-removed)',
        'DRIFT': 'DRIFT (malformed: contradicts current reality)',
        'INCOMPLETE': 'INCOMPLETE (triad / back-link gaps -- grow, do not prune)',
        'INFO': 'INFO (bookkeeping)',
    }
    # de-dup index-dead-ref
    for k in findings:
        seen, uniq = set(), []
        for f in findings[k]:
            if f not in seen:
                seen.add(f); uniq.append(f)
        findings[k] = uniq

    lines = []
    lines.append('# Convey Gardener — DETECTOR report (read-only; nothing was changed)')
    lines.append('')
    lines.append('> Generated by `features/gardener.py`. Lists MALFORMED branches in the card')
    lines.append('> garden (Principle 7). This is the DETECT pass only — pruning is a separate,')
    lines.append('> deliberate commit-with-a-reason. A faithfully-recorded wrong turn in a')
    lines.append('> .session.md is healthy history and never appears here.')
    lines.append('')
    n_actionable = len(findings['PRUNE']) + len(findings['DRIFT'])
    lines.append(f'**Summary:** {len(findings["PRUNE"])} prune candidates · '
                 f'{len(findings["DRIFT"])} drift · {len(findings["INCOMPLETE"])} incomplete · '
                 f'{len(findings["INFO"])} info')
    lines.append('')
    for k in order:
        items = findings[k]
        lines.append(f'## {titles[k]} — {len(items)}')
        if not items:
            lines.append('')
            lines.append('_none_')
            lines.append('')
            continue
        lines.append('')
        for kind, where, why in items:
            lines.append(f'- `{kind}` **{where}** — {why}')
        lines.append('')

    report = '\n'.join(lines)
    if write_report:
        with open(os.path.join(FEAT, 'GARDENER.md'), 'w', encoding='utf-8') as fh:
            fh.write(report + '\n')
    if quiet:
        print(report.split('\n')[3])  # the summary line region
        print(f'PRUNE={len(findings["PRUNE"])} DRIFT={len(findings["DRIFT"])} '
              f'INCOMPLETE={len(findings["INCOMPLETE"])} INFO={len(findings["INFO"])}')
    else:
        print(report)

    return 1 if n_actionable else 0


if __name__ == '__main__':
    sys.exit(main())
