#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# gen-status.py -- compute features/STATUS.md from the @grade tags in the
# .feature cards. The cards are the SOURCE OF TRUTH; the status table is derived,
# never hand-typed. Run it via `python3 features/gen-status.py`; the pre-commit
# hook runs it automatically whenever a features/*.feature is staged.
#
# Deterministic: output is a pure function of the cards (NO timestamp embedded),
# so it only changes when a card's grades change -- no churn.
# -----------------------------------------------------------------------------
import glob, os, sys

# Cards that are NOT hardware-runnable tracker features (excluded from the matrix).
EXCLUDE = {
    'session-changes-codespace.feature',   # meta/process card
    'recent-features-2026-06-03_to_04.feature',  # digest (rolls up other cards)
    'day-2026-06-03.feature',              # day rollup
    'session-2026-06-03-multitimbral-and-whitelabel.feature',  # session rollup
    'convey-test-runner.feature',          # host-side tool, not a tracker feature
    'convey-session-distiller.feature',    # host-side tool (the SessionEnd distiller)
}

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FEAT = os.path.join(ROOT, 'features')

def card_tags(path):
    """Return (scenario_count, set_of_grade_tags) from a .feature card."""
    scn = 0
    tags = set()
    for line in open(path, encoding='utf-8'):
        s = line.lstrip()
        if s.startswith('Scenario:'):
            scn += 1
        elif s.startswith('@'):
            # a scenario tag line: tokens like @shipped @build-verified ...
            for tok in s.split():
                if tok.startswith('@'):
                    tags.add(tok)
    return scn, tags

def mark(yes, no, unknown='—'):
    return '✓' if yes else ('✗' if no else unknown)

def main():
    rows = []
    n_build = n_rt_full = n_rt_partial = n_hw = n_hw_un = 0
    for path in sorted(glob.glob(os.path.join(FEAT, '*.feature'))):
        name = os.path.basename(path)
        if name in EXCLUDE:
            continue
        scn, t = card_tags(path)
        if not scn:
            continue
        build = ('@build-verified' in t) or ('@code-verified' in t)
        rt_v = '@runtime-verified' in t
        rt_u = '@runtime-untested' in t
        hw_v = '@hw-verified' in t
        hw_u = '@hw-untested' in t
        # runtime: ✓ all verified / ~ partial (verified AND untested) / ✗ only untested
        if rt_v and rt_u:
            runtime = '~ partial'; n_rt_partial += 1
        elif rt_v:
            runtime = '✓'; n_rt_full += 1
        elif rt_u:
            runtime = '✗'
        else:
            runtime = '—'
        hardware = mark(hw_v, hw_u)
        if build: n_build += 1
        if hw_v: n_hw += 1
        elif hw_u: n_hw_un += 1
        grades = ' '.join(sorted(t))
        rows.append((name.replace('.feature',''), scn, mark(build, not build),
                     runtime, hardware, grades))

    out = []
    out.append('# Feature Test Status — GENERATED, DO NOT EDIT BY HAND')
    out.append('')
    out.append('> Computed by `features/gen-status.py` from the `@grade` tags in')
    out.append('> `features/*.feature`. The cards are the source of truth; this table is')
    out.append('> derived. The pre-commit hook regenerates it whenever a card changes, so')
    out.append('> nobody hand-types "runtime-verified" into an index again. Hand edits here')
    out.append('> will be overwritten -- change the card\'s tags instead.')
    out.append('>')
    out.append('> Runtime = exercised in DOSBox-X (emulation). Hardware = real DOS metal.')
    out.append('> `~ partial` = some scenarios verified, some still untested.')
    out.append('')
    out.append('| Card | Scn | Build | Runtime (DOSBox) | Hardware | Grades present |')
    out.append('|------|----:|:-----:|:----------------:|:--------:|----------------|')
    for name, scn, b, rt, hw, grades in rows:
        out.append(f'| {name} | {scn} | {b} | {rt} | {hw} | {grades} |')
    out.append('')
    out.append('## Tally (computed)')
    out.append(f'- Cards: {len(rows)}')
    out.append(f'- Build-verified: {n_build}')
    out.append(f'- Runtime-verified in DOSBox-X: {n_rt_full} full + {n_rt_partial} partial')
    out.append(f'- **Hardware-verified: {n_hw}**  ·  hardware-untested: {n_hw_un}')
    out.append('')
    text = '\n'.join(out) + '\n'
    dst = os.path.join(FEAT, 'STATUS.md')
    old = open(dst, encoding='utf-8').read() if os.path.exists(dst) else ''
    if text != old:
        open(dst, 'w', encoding='utf-8').write(text)
        print('[gen-status] features/STATUS.md regenerated')
    else:
        print('[gen-status] features/STATUS.md already current')
    return 0

if __name__ == '__main__':
    sys.exit(main())
