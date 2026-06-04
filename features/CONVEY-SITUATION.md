# Convey — The Single Situation

> **Read this first to catch up on Convey across all conversations.** Multiple Claude
> sessions (see `CONVEY-SESSIONS.md`) have been building Convey in parallel in this one
> working tree. The repo IS the merged truth — this page distills it into one situation
> and holds the cross-session things that live in NO single card (the name, the
> decisions, the open threads).
>
> **Derived facts point at their generated source — do not hand-maintain them here.**
> (That's Convey Principle 1. Numbers below are snapshots; the generated files are live.)

## What Convey is

Convey = **code that conveys its own verified status.** A behaviour is written once as a
graded, linked, session-backed Gherkin Feature; every downstream view (index, test
matrix, RESULT ledger) is generated from it. Full principles: **`features/CONVEY.md`**.
Reusable HOW: the `report-card` skill. Schema: `GHERKIN-FEATURE-WIKI-PATTERN.md`.

## What's built (the components)

| Piece | File(s) | Role |
|-------|---------|------|
| Cards (the triad) | `features/*.feature` + `*.session.md` | spec/tests + spawning conversation, per behaviour |
| Commit↔feature map | `features/INDEX.md` | curated map (NOT test status) |
| Test matrix | `features/STATUS.md` ← `features/gen-status.py` | **generated** build/runtime/hardware grid |
| RESULT-LOG | header of each card | dated commit/PR lines, auto-stamped |
| Automation | `.githooks/{pre-commit,post-merge,report-card-stamp.sh}` | stamp RESULT-LOG + regenerate STATUS.md on every commit |
| Principles | `features/CONVEY.md` | the named methodology |
| Sessions | `features/CONVEY-SESSIONS.md` | which conversations built it |

## Current status (snapshot — live source: `features/STATUS.md`)

~21 behaviour cards. Build-verified: all. Runtime-verified in DOSBox-X: a handful full
+ a few partial. **Hardware-verified: ~1; the rest carry the `@hw-untested` floor**
(DOSBox-X is emulation, not metal). Genuinely uncarded backlog (`INDEX.md` ⬜):
`loader-keyjazz-hang`, `f2-pattern-editor-defaults`, `f4-f3-cursor-translate`.

## Decisions made across the sessions (the things in no single card)

- **The card is the seed; the session is part of it** (vibe diff). A card without its
  session is incomplete.
- **Honest grade ladder with a hardware floor:** build → runtime(DOSBox) → hardware;
  `@hw-untested` stays on every fork feature until a real-metal run earns `@hw-verified`.
- **Self-maintaining over hand-typed:** RESULT-LOG and STATUS.md regenerate on commit.
  Hand-maintaining a parallel status list is banned (Convey Principle 1).
- **INDEX is the map, STATUS is the matrix** — never put test status in INDEX by hand.
- **Convey is whitelabel** — same skeleton for code / circuits / APIs (in the skill).

## Open threads (what's not done)

- **Hardware testing**: ~19 features `@hw-untested`. Only real DOS metal clears it.
- **Runtime gaps**: Multi-WAV (`@runtime-untested`, loud banner), Ctrl-F on F11/F12,
  F4 play-dots, Shift-F4 multitimbral, F6-from-order, Alt-R tiling — built, not pressed.
- **Uncarded backlog**: the 3 ⬜ above.
- **Cross-session distillation is semi-manual**: this doc + the ledger are updated by
  hand when a new conversation lands; the per-feature facts auto-derive, but the
  "decisions / open threads" synthesis still needs a human/agent pass.

## How to use this

- **Catching up?** Read this, then `STATUS.md` (what's tested), then any card you care about.
- **New Convey conversation?** Register it in `CONVEY-SESSIONS.md`, then update the
  "Decisions" / "Open threads" here with anything that lives in no card.
- **Changed a behaviour?** Edit its card's scenario + `@grade` tags. STATUS.md and the
  RESULT-LOG follow automatically — don't touch them by hand.
