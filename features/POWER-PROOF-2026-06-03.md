# Report-Card System — Proof of Power (2026-06-03)

Reproducible proof, gathered with `git grep` / `git log` (verifiable, not asserted).
Every number below came from a command, not a claim.

## What we built (one session's worth)

A **report-card system** for the impulse-tracker fork: every fork feature now
carries a born-with-it, honestly-graded, two-way-linked, session-backed,
git-rebuildable **triad** — `.feature` (spec) + `.session.md` (the spawning
conversation) + RESULT (commits/PR/files) — plus a `post-merge` hook that keeps
the RESULT leg current straight from git.

- Governing rule: `~/.claude/CLAUDE.md` §"BUILDING ANY UNIT EMITS ITS REPORT CARD"
- Operational HOW: the `report-card` skill
- Schema: `GHERKIN-FEATURE-WIKI-PATTERN.md`
- Self-maintaining leg: `.githooks/post-merge` (+ `README.md`)

## POWER 1 — the whole fork is a graded wiki

9 cards, scenario counts: f11(9) f12(4) f2(4) f3(5) f4(4) midi-in(9)
midi-sync(11) session-changes-codespace(13) wav(8).

## POWER 2 — HONESTY: the wiki is NOT all green (the anti-lying grade)

Grade distribution across all cards:

```
 57 @build-verified     8 @runtime-untested    3 @rule-active
 53 @shipped            8 @demonstrated         3 @design-untested
 19 @stock              3 @wired-untriggered    1 @untested
  9 @known-limit        3 @todo
  9 @hw-untested
```

~33 claims are openly marked not-fully-verified / limited / todo. That is the
product: a description that **cannot quietly become completion-framing fiction**,
because the grade is forced and visible.

## POWER 3 — two-way navigation (source <-> card)

14 greppable `FEATURE-CARD >>` back-links in the real `.ASM` source point at 4
cards. `grep FEATURE-CARD *.ASM` -> the card; the card's `# cite:` lines -> the
procs. The wiki is bidirectional.

## POWER 4 — provenance straight from git (hook-stamped, no hand-edit)

```
#   2026-06-03  direct-merge  merge b54ecc0  touched: WAV_Store2Dec
#   2026-06-03  direct-merge  merge 6de8cd0  touched: WAV_Store2Dec
```

The `post-merge` hook fired on a real `--no-ff` merge AND a fast-forward pull and
wrote these itself. Proven, persisted in `origin/main`.

## POWER 5 — ask the wiki, get a cited answer

"What happens when the user presses F11?" answered by reading ONE file
(`features/f11-order-list.feature`) instead of thousands of lines of 16-bit TASM —
with a Feature narrative, graded scenarios, and `# cite:` lines down to proc+line.

## POWER 6 — the vibe diff

5 `.session.md` files (the spawning conversations) are under version control, each
with a clickable "how to get back" block (transcript `file://` + session id +
`claude --resume`). The `features/` wiki compounds in git — one log entry per
change — so you can diff the code, the card, AND the dialogue across versions.

## Why it matters

Before: the fork's features lived in commit messages, ~10k lines of assembly, and
the operator's head. Documentation written after the fact drifts and lies.

After: each feature is born with a card that is simultaneously the **understanding**
(load it, skip re-deriving from raw source), the **command** (the Given/When/Then
goal + the boundary of what to touch), and the **seed** (codespace + areaspace from
the card, thinkspace from the session). The honest grade is the anti-lying
mechanism; the git-stamped RESULT is the provenance; the back-links make it
navigable both ways; the session makes the reasoning diffable.

## The honest caveats (because the system grades itself too)

- The `post-merge` hook only fires on a **merge / non-ff pull**. This fork ships
  **direct-to-main, no PRs**, which produce no merge commit — so in normal use the
  hook rarely fires (a `@known-limit`). It is a safety net for the merge/PR path,
  not the everyday path.
- The hook is **per-clone opt-in** (`git config core.hooksPath .githooks`); not
  committable, so a fresh clone runs it dormant until enabled.
- A **prose** WATCH line tokenizes to junk and self-tags spuriously — caught and
  fixed live this session (the meta-card now has none).
