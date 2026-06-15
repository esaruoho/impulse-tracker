# AGENTS.md — Impulse Tracker (esaruoho fork)

Vendor-neutral guide for **any** AI coding agent working in this repo (Claude
Code, Codex, Cursor, Aider, …). The full development guide is **[`CLAUDE.md`](CLAUDE.md)** —
read it; this file is the short list of non-negotiables that keep the codebase
and its self-documenting wiki coherent. When the two differ, `CLAUDE.md` wins.

## What this is

Full Impulse Tracker 2.15 source — 16-bit real-mode TASM assembly (`.386P`),
built with **TASM 4.1 / TLINK 3.01 / Borland MAKE 4.0 under DOSBox-X** into
`IT.EXE` + `.DRV` sound drivers. Upstream (`jthlim/impulse-tracker`) is read-only;
feature work happens on this fork's `main`. We ship via **direct commits to
`main`, not PRs.**

## Build & verify

- Build everything locally: `dosbox-x -conf buildall.conf -fastlaunch -exit -nogui -nomenu`
  (mounts repo as `C:`, `tools-local/` as `T:`, runs `BUILDALL.BAT`). Toolchain
  binaries are Borland property — never commit them (`tools/`, `tools-local/` are
  gitignored).
- A change is `@build-verified` only when its `.asm` shows `Error/Warning = None`
  and `IT.EXE` links. It is **not** verified-as-working until `IT.EXE` is actually
  run and the behaviour observed.

## The report-card / Gherkin discipline (the part that makes "we all benefit")

This repo documents its own behaviour with **report cards**: Gherkin `.feature`
files in `features/`, one per behaviour cluster. Each card is a **triad** —
`<name>.feature` (graded Given/When/Then scenarios, each cited to proc + line +
commit), `<name>.session.md` (the conversation that produced it), and a
`RESULT-LOG` of what shipped. Schema: `GHERKIN-FEATURE-WIKI-PATTERN.md`. Map of
commit ↔ card: `features/INDEX.md`. Generated human reference:
`features/README.md`.

**The `.feature` house style** (a `#`-comment report-card banner, then plain Gherkin — copy an existing card like `features/sample-amplify-keeps-playback.feature` for the full banner):

```gherkin
# === REPORT CARD: <title> · WATCH: Proc1 Proc2 (symbols the hooks auto-stamp) ===
Feature: <behaviour title>
  As a <role>, I want <capability>, So that <benefit>.

  @shipped @build-verified @runtime-untested
  Scenario: <ONE behaviour, ONE verifiable outcome>
    # cite: IT_X.ASM SomeProc (~line NNN) — what satisfies it ; commit <hash>
    Given <starting state>
    When <the single action>
    Then <concrete verifiable outcome — never "it works">
    And <further outcome>
```

Rules: one Scenario = one behaviour; every Scenario graded with a tag; every claim has a `# cite:` proc+line+commit; the `Then` is a strong, checkable criterion. Full skeleton + rationale in `CLAUDE.md` and `GHERKIN-FEATURE-WIKI-PATTERN.md`.

**When you build or change a documented behaviour, in the same motion:**

1. Build + verify (above), commit + push to `main`.
2. Emit/update the card triad; add a `; FEATURE-CARD >> features/<name>.feature`
   back-link at the code it describes; list the `# WATCH:` procs it cites.
3. Enrol it in `features/INDEX.md`.
4. Regenerate the reference: **`python3 features/print-card.py --readme`** (writes
   `features/README.md`) and `--all` (per-card `features/dist/` outputs).
   `features/README.md` is generated — **edit the card, not the README.**
5. Grade honestly with tags (`@stock` / `@shipped` / `@build-verified` /
   `@runtime-verified` / `@runtime-untested` / `@hw-untested` / `@todo`). Never
   mark `@runtime-verified` for something you didn't actually run.

**One-time per clone** (git won't auto-run committed hooks):

```
convey hooks install --target .   # or, manually: git config core.hooksPath .githooks
```

These are **Convey's canonical hooks** (owned in `~/work/convey/templates/hooks/`),
not a private fork: the `pre-commit` / `post-merge` hooks auto-stamp a card's
RESULT-LOG when its WATCHed symbols change (scanning **all** tracked `*.feature`,
not just `features/`). `pre-commit` also sources `.githooks/pre-commit.local` —
this repo's own jobs (regenerating `features/STATUS.md` + the session registry),
which Convey never clobbers. Without enabling the hooks the cards still work as
docs but stop self-updating. Detail: `.githooks/README.md`.

## Hard rules

- **Never guess keybindings.** Source of truth is `ReleaseDocumentation/IT.TXT`
  and the keymap tables in `IT_PE.ASM` / `IT_K.ASM` / `IT_OBJ1.ASM`. If a key
  isn't documented, find its dispatch entry in code or say you can't confirm it.
  Hallucinated bindings erode trust. (See the keyboard reference in `CLAUDE.md`.)
- **Verify against the code before claiming.** Cite `file:line` and the proc.
- **`grep` here is `ugrep`** — its `\|` alternation can silently fail and some
  regexes catastrophically backtrack. Prefer `rg -F` (fixed strings) /
  `rg -e … -e …`; avoid greedy `.*<lit>.*` patterns.
- **Releases:** always tag `v2.354` distinguished by a `-YYYY-MM-DD` suffix
  (run the "Package DOS release zip" workflow with a blank version). Release
  notes are built from the direct-commit `git log`, not PRs.

## Layout (quick)

`IT.ASM` startup · `IT_M.ASM` dispatcher · `IT_MUSIC.ASM` playback/driver/mixer ·
`IT_K.ASM` keyboard + MIDI-in · `IT_PE.ASM` pattern editor · `IT_I.ASM`
sample/instrument lists · `IT_G.ASM` global keys · `IT_DISK.ASM` disk I/O ·
`IT_OBJ1.ASM` object/keymap tables · `SoundDrivers/` drivers · `features/`
report cards · `.githooks/` self-stamp engine. Full map in `CLAUDE.md`.
