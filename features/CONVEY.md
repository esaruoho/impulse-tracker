# Convey — principles

> **Convey** is the methodology these `features/` cards run on: code that *conveys
> its own verified status*. A behaviour is written once as a graded, linked,
> session-backed Feature; everything downstream (the index, the test matrix, the
> RESULT ledger) is GENERATED from it. You should never have to hand-type "this was
> tested" anywhere — the cards say it, and the views derive it.
>
> Convey is the named, reusable form of the report-card pattern (skill: `report-card`;
> schema: `GHERKIN-FEATURE-WIKI-PATTERN.md`). Whitelabel it across domains.

## Principle 1 — Tests → Features → automatic index (the conveyance) ★ this one

The chain, one direction only:

1. **Tests are Features.** A verifiable claim about behaviour is written ONCE, as a
   Gherkin `Scenario` in a `.feature` card — `Given / When / Then` cited to its
   innards. The scenario's **`@grade` tags ARE its test status** (`@build-verified`,
   `@runtime-verified`, `@hw-verified`, `@runtime-untested`, `@hw-untested`, …).
2. **Features become the index.** The index / status view is **GENERATED** from those
   tags by a script (`features/gen-status.py` → `features/STATUS.md`), run
   **automatically** by the pre-commit hook on any card change. It rides into the
   same commit.
3. **So you can always confirm**, with zero manual labor: *is this tested or not, at
   what level (build / runtime-in-DOSBox / real hardware), and where does it link*
   (to the card, its innards, its commits, its session).

**The anti-pattern (banned):** hand-maintaining a parallel "what's tested" list. If
you are typing "runtime-verified" into an index by hand, you've broken Convey — change
the card's tag and let the index regenerate. Hand edits to a generated view are
overwritten by design.

**Corollary — the conversations are plugged in too.** The Claude sessions that build
Convey are not a hand-typed list either: `features/gen-sessions.py` discovers them from
the live transcripts and generates `features/CONVEY-SESSIONS.generated.md` — each
conversation with a `claude --resume <id>` get-back command and the exact cards / tools
it touched. So a conversation and the tooling it creates are auto-linked, both ways:
the card knows its session (the `.session.md` get-back block), and the session registry
knows the cards. Run via `features/gen-all.sh`; the pre-commit hook does it on any card
commit.

**Why:** a hand-kept status list drifts and lies the moment a card changes. A derived
view cannot disagree with its source — the source IS the cards. One write, many true
views.

## The rest of the Convey principles (established earlier this work)

2. **A unit emits its report card** — born WITH the code, not bolted on after. The
   card is the durable artifact and the **seed** the work spawns from (codespace +
   areaspace from the card, thinkspace from the session).
3. **The triad** — `.feature` (spec/tests) + `.session.md` (the spawning conversation
   = the *vibe diff*) + **RESULT** (commits / PR / files). All three cross-linked; the
   wiki rebuilds straight from git.
4. **Two-way links** — the innards carry a greppable `FEATURE-CARD >>` marker back to
   the card; the card cites the innards. Navigable from either end.
5. **Honest grades, with a hardware floor** — the grade is the anti-lying mechanism.
   Ladder: `@build-verified` → `@runtime-verified` (DOSBox-X = emulation) →
   `@hw-verified` (real metal). **`@hw-untested` is the standing floor on every fork
   feature** until a hardware run earns `@hw-verified`. Never grade up to look done.
6. **Self-maintaining** — the RESULT-LOG and the index keep themselves current via the
   `.githooks` (`pre-commit` for direct-to-main, `post-merge` for merges); the cards
   are the only thing a human edits.

## Operational pieces (the impulse-tracker instance)

- Cards: `features/*.feature` (+ `*.session.md`).
- Index/map (curated): `features/INDEX.md` — commit↔feature map; does NOT hold test status.
- Test matrix (generated): `features/STATUS.md` ← `features/gen-status.py`.
- Automation: `.githooks/pre-commit`, `.githooks/post-merge`, `.githooks/report-card-stamp.sh`.
- Schema / how-to: `GHERKIN-FEATURE-WIKI-PATTERN.md`.

## The Convey base (distilling many conversations into one situation)

Convey is built across multiple parallel Claude sessions. Two files keep them from
drifting into N disconnected conversations:

- **`features/CONVEY-SITUATION.md`** — the single distilled situation. Read-this-first
  orientation: what Convey is, what's built, current status (pointing at generated
  sources), the cross-session decisions, and the open threads. The one place that
  holds what lives in no single card.
- **`features/CONVEY-SESSIONS.generated.md`** — the AUTO-DISCOVERED registry of every
  Convey conversation, plugged in straight from the live transcripts by
  `features/gen-sessions.py` (resume command + cards/tools each touched). Generated,
  not hand-typed.
- **`features/CONVEY-SESSIONS.md`** — the curated overlay: human roles / distillation
  notes on top of the generated registry (which conversation was the genesis, which is
  fully distilled, etc.).

The repo itself (cards + generated `STATUS.md` + git log) is the authoritative merged
record; these two add the human-readable synthesis on top.
