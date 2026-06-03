# SESSION (vibe diff) — F-key report cards (F2/F3/F4/F11/F12)

> The spawning conversation for the five sibling cards:
> `f2-pattern-editor.feature`, `f3-sample-list.feature`,
> `f4-instrument-list.feature`, `f11-order-list.feature`,
> `f12-song-variables.feature`.
> Stored per the Report Card rule: a card without its session is INCOMPLETE.
> This is *how we got here* — the request, the method, the wrong guess, the
> correction — alongside the cards' *what* and *why-as-grade*.

- **Card:** the five `features/f*.feature` files (this dir)
- **Commit:** `8ca97e9` ("features: report cards for F2/F3/F4/F11/F12 'what happens when pressed'")
- **Date:** 2026-06-03
- **Convention:** `GHERKIN-FEATURE-WIKI-PATTERN.md`; prior instance `features/midi-in-multitimbral.feature`

## The request

Esa: *"base on the gherkin style formatting of a feature, i want you to study
this codebase, and report back with .features for 'User Presses F2' to F3 to F4
to F11 to F12. 'what happens'. the simplest start of a .feature like this is to
draw it in the gherkin style formatting, and thus get the given when then
user-report. but this report-card."*

So: one report card per function key, Given/When/Then, graded, cited — the same
shape as the existing multitimbral card.

## Method

1. Read the existing `features/midi-in-multitimbral.feature` and
   `GHERKIN-FEATURE-WIKI-PATTERN.md` to match the schema (header block with
   report-card legend + source-file list + commit log; tagged scenarios; one
   behaviour per scenario; cite proc + line + commit).
2. Fanned out **five parallel Explore agents** (F2, F3, F4, F11, F12) to pin
   down exact dispatch entries, procs, line numbers, and the commits that
   shipped each fork addition. Key finds:
   - F-key dispatch lives in `IT_OBJ1.ASM` `GlobalKeyList` (~3138+), NOT
     `IT_M.ASM` as the CLAUDE.md prose implied; handlers are `Glbl_F2..F12`
     in `IT_G.ASM`.
   - F2-F2 default-length persistence: `068648f`.
   - F3 loader-keyjazz hang fix: `MIDISyncLoaderSuppress` + `Music_SilenceSampleVoices`
     (`a44c41b`, `64fa1ce`).
   - F4 tab cycle: `I_SelectScreen` (`IT_I.ASM:871`). MIDI-In field kept on its
     own card by cross-link, not duplicated here.
   - F11 power tools: `1a7aa16` + follow-ups `4eee4f8`/`90cfd04`/`74c3fe8`.
   - F12 dir pickers: `4eee4f8` via `D_PickDir_Common`; Quicksave row `7fd1abc`.

## The wrong guess, and the correction (the honest part)

The F12 agent reported the Samples→Instruments envelope-preservation feature as
**active in main**. My project memory said it was **reverted** and parked in PR #3
("open, DO NOT MERGE"). Rather than trust either, I checked git:

```
9493101 Merge pull request #3 from esaruoho/retain-envelopes-samples-to-instruments
9a1142c Cleaner policy: always remap + keep envelopes; gate garbage-clear on IMPI
...
b5a0c66 Revert Samples->Instruments envelope preservation
```

PR #3 **was merged**. The revert (`b5a0c66`) was a midpoint, not the end state;
the clean IMPI-gated re-implementation (`9a1142c`) re-landed via `9493101`. The
memory was stale. I:
- wrote the F12 envelope scenario to describe the **live** IMPI-gated policy
  (`F_SetControlInstrument` / `Music_InstrumentIsReal`), tagged `@shipped`;
- corrected `project_samples_to_instruments_envelope_reverted.md` (added a
  2026-06-03 UPDATE header + fixed its title) and the `MEMORY.md` pointer.

This is exactly the honesty-protocol case: a cited claim contradicted memory, so
verify against the source before writing it down.

## Decisions

- **Multitimbral stays its own card.** The F4 card only documents where the
  per-instrument MIDI-In field is *edited* (the Pitch tab) and cross-links to
  `midi-in-multitimbral.feature` for what the field *does* live — no duplication.
- **Grades:** `@stock` for upstream behaviour, `@shipped` for fork additions in
  main, `@build-verified` since the tree assembles/links clean. No `@hw-untested`
  was used on these (they are screen/edit behaviours, not MIDI-input paths).
- **No build run this session** — these cards describe already-shipped behaviour
  in main; I cited commits, I did not re-assemble. (If a future change touches
  these procs, re-grade against a fresh build.)

## The result (third leg of the triad)

Esa's framing: the report card needs the **PR + commits** too, so that the
`.feature` (spec/claims) + `.session` (the conversation) + the **result**
(commits / PR / files-changed) are all linked — *described it, tested for it,
developed it, then chuck the session + the commit + the PR + the files-changed
in together*. That makes a self-reorganizing wiki of *what the code is*, rebuildable
straight from git.

So each card now carries a `RESULT` header block. The accurate delivery map
(verified by first-parent ancestry, not guessed):

| Card | Feature commits | Delivery |
|------|-----------------|----------|
| F2   | `068648f` | direct to main, no PR |
| F3   | `a44c41b`, `64fa1ce`, `ec91331` | direct to main, no PR |
| F4   | `10c837b` | direct to main, no PR |
| F11  | `1a7aa16`, `4eee4f8`, `90cfd04`, `74c3fe8` | direct to main, no PR |
| F12  | dir rows `7fd1abc`/`8f11aa6`/`4eee4f8` (direct); envelope `d8ec842`→`b5a0c66` (direct) → `a44a607`/`9a1142c` **via PR #3**, merge `9493101` | mixed |

Card-authoring result (this session): `8ca97e9` (the five cards) + `009dbab`
(this session file + `SESSION >>` back-links) + the commit adding these RESULT
blocks. Note: there are two "PR #3"s in history — `f50e519` is **cs127**'s, the
envelope one is **esaruoho**'s `9493101`. Easy to conflate; don't.

## Why this helps an agent write better code (Esa's question)

The triad makes git itself a queryable knowledge base: `.feature` answers *what
should be true*, `.session` answers *why we decided that and what we got wrong*,
and the RESULT/commits answer *what actually shipped and where*. An agent landing
cold can load one card and reconstruct the spec, the rationale, and the diff
without re-reading thousands of lines of TASM — and can diff all three across
versions (a "vibe diff": code + claims + the dialogue that drove the change). The
honest grade (`@stock`/`@shipped`/`@build-verified`) is the anti-drift check; the
back-links keep it two-way so the wiki can be regenerated mechanically. A hook that,
on each merge, appends the PR/commit/files-changed to the matching card's RESULT
block would make it fully self-maintaining — the natural next step.

## Back-links

- Cards → this session: `SESSION >>` line in each card header.
- Cards → result: `RESULT` block in each card header (commits + PR #3 where applicable).
- Innards: the procs cited in each card's header `Source files` block.
- Memory: [[feedback_report_card_pattern]], [[project_samples_to_instruments_envelope_reverted]].
