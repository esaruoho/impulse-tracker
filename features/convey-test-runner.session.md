# Session — convey-test-runner

> The thinkspace leg of the `convey-test-runner` triad. Faithful, not flattering.

## The request that exposed the gap

Esa, after using the runner:

> "listen, in this 'tests tester' TUI that you wrote, it is not done the Convey
> way. see, we would start with the .feature, the principle, of 'displaying
> information to a User'."

He is right. I built `hwtest.py` + the `test-impulse-tracker` launcher as bare
tools and shipped them with NO `.feature` card. That violates Convey Principle 2
(*a unit emits its report card, born WITH the code; the card is the seed*). Every
other piece of the `features/` system has its card; the conveyance tool itself
did not. This card closes that — written from the principle Esa named: the
runner's job is **displaying information to a User** (and routing their verdict
back).

## What the runner is (the principle)

It is the human-facing **conveyance layer** of Convey:

1. Reads the generated situation (fork scenarios not yet `@hw-verified`).
2. **Displays** each to the tester — card, scenario, the steps to do, DOSBox status.
3. **Captures** the verdict: works / failed (+ how) / skip / back / quit, saved
   after every answer (resumable).
4. **Routes it back**: a "works" flips that scenario's `@hw-untested` →
   `@hw-verified` in the card itself (the source), then STATUS.md / HARDWARE-TEST.md
   regenerate. Failures become `HW-FAILURES.md` — the one thing sent back.

So the human's real-metal run becomes Convey-recorded truth with no hand-typed
status anywhere (Convey Principle 1) and near-zero chat.

## Decisions

- **Host-side tool, not a tracker feature.** It runs on the Mac (the DOS box can't
  run python), so the `@hw` floor does not apply. Tagged `@tool` and added to the
  `EXCLUDE` sets in `gen-status.py` / `gen-hwtest.py` / `hwtest.py` so it never
  lists ITSELF as a behaviour to hardware-test.
- **It edits the cards, not a status file.** Routing a pass means flipping the
  scenario's tag in its `.feature` (the source of truth), so the generated views
  follow — never writing "verified" into a view by hand.
- **Repo-anchored launcher.** `test-impulse-tracker` resolves the repo from its own
  path so it works from any cwd (fixes the `No such file` Esa hit running it in `~`).

## Honest grades

- `@build-verified` + `@runtime-verified`: the runner was actually run — it loaded
  93 fork scenarios, displayed them, and captured Esa's Alt-R "failed" verdict with
  a note. `@tool`: no hardware tier (it's not IT.EXE).
- The process honesty: this card is retroactive. The CODE is verified; the *Convey
  discipline* (card-first) was applied late, and that's recorded here rather than
  hidden.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/e86aa106-2936-452b-805c-e3418c03140c.jsonl
- Session ID: `e86aa106-2936-452b-805c-e3418c03140c`
- Resume: `claude --resume e86aa106-2936-452b-805c-e3418c03140c`
- Session timestamp: 2026-06-04 ~09:45 EEST

## Cross-links

- Spec leg: `features/convey-test-runner.feature`
- The methodology: `features/CONVEY.md`, `features/CONVEY-SITUATION.md`
- Innards: `features/hwtest.py`, `test-impulse-tracker`, `gen-status.py`, `gen-hwtest.py`
