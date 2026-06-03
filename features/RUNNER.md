# The Runner — making report cards executable

> Esa, 2026-06-03: "make this a runnable system that we can run on anything at all,
> by being able to run it locally and use Apple Foundation Models on the Mac Mini
> to be able to get the results in, i.e. the analysis of the image."

This is the answer to the caveat written into every card so far — *"16-bit TASM has no
test runner, so claims are verifiable-in-principle."* The runner removes the
"-in-principle." A scenario's `Then` stops being a human checklist item and becomes a
machine-graded result.

## Why this forces features to be granular (the split rule)

A runnable scenario is: **arrange a known state → perform the keys/MIDI → capture ONE
screen → grade the screen against the `Then`.** That only works if the feature fits in a
single screen-state. A grab-bag spanning F2 + F3/F4 + F9 (the old `navigation-and-persist`)
cannot be captured in one screenshot, so it cannot be one runnable unit. That is the
architectural reason `navigation-and-persist` was split into `f2-pattern-editor-defaults`,
`f4-f3-cursor-translate`, `f9-bulk-load-samples`. **One feature = one screen-state = one
gradeable assertion.** Granularity is not tidiness; it is what makes a card executable.

## The loop (per scenario)

```
card scenario  ──►  RUNNER  ──►  graded result back into the card
   Given            1. boot IT.EXE in DOSBox-X with the Given's module/state
   When             2. drive the When: inject keystrokes (+ MIDI bytes if needed)
   Then             3. capture the screen (PNG)
                    4. Apple-native analysis on the Mac Mini:
                         Vision OCR (on-device) -> screen text
                         Foundation Models -> "does this screen satisfy: <Then>?"
                    5. pass/fail + reason -> flip @hw-untested to @screen-verified,
                       append to a run log; the commit hash stays the trail
```

Runs **on anything**: DOSBox-X is cross-platform; the analysis is Apple-native and
on-device (no cloud). Routing to the Mini follows the standing rule — **Syncthing inbox,
not SSH** (robust wins over brittle): drop `{card-id, screenshot.png, Then-text}` into a
queue folder; the Mini analyzes; the verdict syncs back.

## Mapping to the four properties

- **Verifiable claims** — already Given/When/Then; the runner is what verifies them.
- **Honestly graded** — the grade stops being self-asserted. `@screen-verified` means a
  model read the actual screen. `@hw-untested` stays honest until the run happens.
- **Linked to innards** — unchanged; cite still points at proc+line+commit.
- **Two-way** — the run log is a new back-link layer: screenshot ⇄ scenario ⇄ source.

## The honest hard parts (in build order)

1. **Keystroke injection.** DOSBox-X has an `autotype` console command; F-keys and
   Alt/Ctrl/Shift combos and inter-key timing are fiddly. Pure-keyboard, text-screen
   scenarios are the easy first target (e.g. `f2-pattern-editor-defaults`: press F2 F2,
   read the default-length field off the config screen).
2. **Deterministic Given.** The arrange step must load a known module so the screen is
   reproducible run to run. Ship a tiny fixture .IT per scenario family.
3. **Screen reading.** IT is mostly a text UI → Vision OCR is reliable for fields,
   counters, filenames. Graphical states (VU meters, order-list highlight, the scope)
   are weaker — grade those from OCR'd text where possible, full-vision later.
4. **MIDI injection (high value, more setup).** The `midi-realtime-sync` card's live
   scenarios are all `@hw-untested` precisely because DOSBox-X can't be fed MIDI by hand.
   Fix: a virtual MIDI bus (macOS IAC) → DOSBox-X MIDI-in → a byte-sender script emits
   FA/FB/FC/F8. This is what would finally turn those grades into `@screen-verified`
   (watch the Shift-F1 MIDI Monitor counters tick, OCR them, confirm).
5. **Model capability check.** Foundation Models needs a recent macOS + Apple-Intelligence
   hardware. Confirm the Mac Mini qualifies before committing; otherwise fall back to
   Vision OCR + a local text model for the grading step.

## First runnable target (proposed)

`f2-pattern-editor-defaults` — pure keyboard, pure text screen, no MIDI, no graphics. It
exercises the whole loop (boot → autotype F2 F2 → screenshot → OCR the default-length
field → Foundation Models grades "default pattern length shows N") with the least moving
parts. Prove the loop there, then add MIDI injection to unlock the sync card.

## Building blocks already on hand

- `apple` skill + `vision-ocr` slash command — on-device Vision OCR.
- `cloudcity` / `bbs` skills — the Syncthing inbox/result pipeline to the Mini.
- `buildall.conf` + DOSBox-X — already builds + can run IT.EXE headless here.

## Verification result (2026-06-03) — GO

Read robustly over Syncthing (machine card + fm-outbox), no SSH, no command exec:

- **Mini = Apple M2 Pro · 32 GB · macOS 26.3 Tahoe (25D125) · 10-core.** macOS 26 ships
  the FoundationModels framework; M2 Pro is Apple-Intelligence-capable. Prerequisite MET.
- **A Foundation Models worker is ALREADY LIVE on the Mini** (`fm-worker-heartbeat.json`
  fresh; `fm-outbox/` has real results from 12:32 today, `model_ms` 3034 and 9914). It
  already summarized a feature card in ~10s — exactly the analysis step we need.
- **Robust channel proven**: drop request → `~/work/comms/queue/fm-inbox/`, read verdict
  → `fm-outbox/{id}.json` (Syncthing-mediated). Result shape:
  `{id, ok, rc, out, err, model_ms, host, ts, from}`.
- Fallback if ever needed: the card's `ai` block says the Mini runs local quantized LLMs
  (7b q4 ~50 tok/s, fits up to 34b q4).

### The one hard constraint discovered
The on-device Apple model is **safety-tuned and refuses agentic framings**. A real
fm-outbox example: asked to "run a script," it replied *"I cannot run scripts or perform
actions that require system access."* So the grader prompt MUST be pure text
classification — *"Below is text from an IT screen. Does it show <Then>? Answer
VERDICT: PASS|FAIL + one sentence."* — never "run/execute/do." Analysis framings work;
execution framings get refused.

## Runner skeleton — the plan

A single orchestrator, `run-scenario <feature> <scenario>`, with 7 phases. v0 runs DOSBox
+ OCR on the laptop and uses the Mini only for the text-grade step (keeps the build loop
local; one network hop, over Syncthing).

```
0. PREFLIGHT  assert fm-worker-heartbeat fresh (< ~15 min) and IT.EXE present
1. ARRANGE    launch DOSBox-X with a per-scenario .conf that auto-loads a fixture .IT
              and lands on the target screen (the Given)
2. ACT        drive the When via DOSBox-X `autotype` (e.g. "autotype -w .2 f2 f2")
3. CAPTURE    screenshot the DOS screen to PNG (DOSBox-X captures dir, or macOS
              screencapture of the window)
4. READ       Vision OCR the PNG -> screen text   (on-device, local, Apple-native)
5. GRADE      drop {prompt: classification framing, screen text, Then} into fm-inbox;
              poll fm-outbox/{id}.json -> parse "VERDICT: PASS|FAIL"
6. RECORD     append run log (png, ocr, verdict, model_ms, ts); flip the scenario tag
              @hw-untested/@build-verified -> @screen-verified (or @screen-failed)
```

Two-stage analysis is deliberate: **Vision OCR turns the image into text (the model is
text-only); Foundation Models grades the text.** Never ask fm to "look at an image."

### First target: `f2-pattern-editor-defaults`
Pure keyboard, pure text screen, no MIDI, no graphics — exercises all 7 phases with the
fewest unknowns. Scenario: boot → `autotype f2 f2` → land on Pattern Edit Config →
screenshot → OCR → grade "the default new-pattern length field shows <N>".

### Honest open questions (need a spike each, in build order)
1. **Keystroke fidelity** — does DOSBox-X `autotype` land F2/F2 and (later) Alt/Ctrl/Shift
   combos reliably, with correct timing? Smallest spike; do first.
2. **Screenshot mechanism** — DOSBox-X captures-dir trigger vs macOS `screencapture` of
   the window; which is scriptable headless-ish on this Mac?
3. **fm-inbox request schema** — confirm the exact JSON the worker expects (read the `fm`
   skill / an inbox example) before wiring phase 5.
4. **OCR fidelity on VGA text** — Vision on IT's text UI should be strong; confirm on a
   real IT screenshot before trusting verdicts.
