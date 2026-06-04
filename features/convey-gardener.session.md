# Session — build the Convey Gardener detector (2026-06-04)

Vibe-diff for `convey-gardener.feature` / `features/gardener.py`. Faithful, not
flattering — including the false positives the first cut produced.

## The request (Esa)

> start building the gardener detector.

Following directly from CONVEY.md Principle 7 ("Convey is a garden, it prunes") and
the two-way conveyer design: the gardener is the DETECT half. Detect first, prune
second — the same discipline as VRAM-markers-before-fix.

## First cut, and what it got WRONG (the honest part)

The v1 ran and reported 12 DRIFT + 13 INCOMPLETE. Vetting each against reality
showed most were the DETECTOR's bugs, not the garden's:

- `WAVDRV.ASM not found` — it lives in `SoundDrivers/`, which v1 didn't scan. FIX:
  scan `SoundDrivers/*` and `Network/*` for both sources and filenames.
- `load_items` / `flip_tag_to_hw_verified` "dead symbols" — those are PYTHON
  functions cited by `convey-test-runner.feature` (a host-tool card). FIX: skip cite
  checks for META cards.
- `*.ASM not found` — the tokenizer treated the glob in prose ("16 *.ASM drivers")
  as a filename. FIX: reject file tokens whose stem isn't a clean identifier.
- 5 F-key cards "missing session" + `fkey-report-cards.session.md` "orphan" — those
  cards SHARE one session via a `# SESSION >>` header. FIX: honor SESSION >> refs;
  a session referenced by any card is not orphan, and a card pointing at an existing
  session is not missing one.
- `wav-render-quicksave:165` "no grade" — it's tagged `@known-limit`, which wasn't
  in my grade vocabulary. FIX: add it; and split "no tag at all" (DRIFT) from "tags
  present but none known" (INFO/unknown-grade).
- `@hw-verified without @runtime-verified` and `index-dead-ref` — reclassified to
  INFO: hardware implies runtime, and an INDEX entry under "Uncarded" is a planned
  card, not malformed.

## After hardening

`0 PRUNE · 0 DRIFT · 0 INCOMPLETE · 15 INFO`, exit 0. The 15 INFO are real
bookkeeping (spec/feasibility cards with no back-link; three planned cards named in
INDEX; one grade-ladder note) — and it caught my own omission: `pattern-length-
beyond-200.feature` was never enrolled in INDEX.md. That's a GROW reaction (enrol
it), not a prune.

## Design decisions

- Substring scans only (`sym in src`), no regex — honors the catastrophic-
  backtracking ban.
- Underscore filter for cited symbols: assembly procs/labels carry `_`
  (LSWindow_ShiftEnter, Music_Stop); mnemonics/prose almost never do. Conservative,
  kills false "dead symbol" alarms.
- Severity contract: PRUNE = maintainer already flagged dead; DRIFT = malformed,
  contradicts reality; INCOMPLETE = a gap to GROW (not prune); INFO = bookkeeping.
  Exit non-zero only on PRUNE/DRIFT so a future hook/CI could gate on real rot.
- It is the DETECTOR only. It mutates nothing. Pruning is a separate, reasoned,
  commit-with-a-reason step (quarantine, not silent rm) — the next unit.

## Honest grade

`@tool @runtime-verified` — it actually ran against the live garden and its output
was vetted line-by-line this session (that's what "runtime-verified" means for a
host tool: executed, output confirmed correct). Not `@hw` (it's not DOS code).

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/6ddcab86-2462-4295-9717-0b3f0e837425.jsonl
- Session ID: `6ddcab86-2462-4295-9717-0b3f0e837425` (identified by content)
- Resume: `claude --resume 6ddcab86-2462-4295-9717-0b3f0e837425`
- Session timestamp: 2026-06-04 ~12:40 EEST (verified via `date`)
- CWD: /Users/esaruoho/work/impulse-tracker
