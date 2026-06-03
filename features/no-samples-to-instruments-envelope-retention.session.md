# Session — no-samples-to-instruments-envelope-retention

> Thinkspace leg of the triad. Why the Samples->Instruments envelope-retention
> feature is OUT for good, and how the removal was done. Faithful, not flattering.

## The request (verbatim)

Esa, 2026-06-03:

> "Please reinstate PR2 removal, meaning, that PR2 that removes this 'samples to
> instruments' is re-instated, i.e. re-put-in. i want it to be the defacto thing.
> this is the brittlest feature and i dont want anything brittling anything up
> anymore. losing envelope-retention across the flip is perfectly 100% fine.
> having a crashprone IT.exe IS NOT FINE."

## The history this closes

- `d8ec842` (+ `4e4eb9a`/`ed10913`/`3d2412b`) ADDED F12 Samples->Instruments
  "preserve drawn envelopes": skip clearing slots whose envelope bytes differed
  from the template. **Garbage slots** (from sample-only loads and Shift-Enter
  bulk-load) "differed", got preserved, and were fed to the envelope renderer ->
  unbounded node loop -> **EMM386 #12 wild write** = hard crash. Only reproduces
  on real DOS+EMM386; DOSBox-X can't trigger it.
- **PR #2 `b5a0c66`** REMOVED it: F_SetControlInstrument restored to upstream
  unconditional `Music_ClearAllInstruments` + clean remap; deleted the helper;
  kept the `I_MapEnvelope` MaxNode<=25 clamp. (Title said DO NOT MERGE; merged.)
- **PR #3 `c2094e6`->`a44a607`->`9a1142c`** RE-ADDED it on a better signal
  (`Music_InstrumentIsReal` = IMPI magic; clear only non-IMPI slots, never touch
  130h+). Cleaner, but STILL the same feature, and merged **2026-06-03 without
  the real-hardware verification its own body demanded.**
- **This commit** reinstates PR #2's removal as the de-facto behaviour.

## What was done (mechanics)

1. `git checkout b5a0c66 -- IT_F.ASM`. Safe because `git log b5a0c66..HEAD --
   IT_F.ASM` showed ONLY PR #3's two commits had touched the file -> the b5a0c66
   version is exactly "current minus PR #3". (First checkout attempt didn't
   persist -- working tree still showed `IsReal`; re-ran and verified `grep -c
   Music_InstrumentIsReal IT_F.ASM` == 0 before proceeding.)
2. IT_MUSIC.ASM had MANY unrelated commits since b5a0c66 (WAV render,
   multitimbral, report-card back-links), so NO whole-file revert. Instead:
   surgically deleted the `Music_InstrumentIsReal` proc (replaced with a
   tombstone) and removed its `Global` decl. Verified it had no other caller
   (only F_SetControlInstrument, now reverted) -> link stays clean.
3. Build: BUILDALL clean, IT_F.asm + IT_MUSIC.asm "Error/Warning: None", tlink
   3.01 linked with no undefined symbol (proves IsReal had no other caller).

## Decisions / nuances surfaced

- **Dialog default focus reverts to OK (CX=3).** PR #2's version focuses the OK
  button on the "Initialise Instruments?" prompt (upstream IT2.15). The later
  "default to No" (CX=4) was an independent dataloss-nicety tied to the envelope
  feature. Reinstating PR #2 *faithfully* restores CX=3. This is NOT a crash --
  it just means an accidental Enter on that dialog now wipes+remaps instruments
  (upstream behaviour). Flagged to Esa; trivial to flip back to CX=4 if wanted.
- **Kept:** the `I_MapEnvelope` MaxNode<=25 clamp -- pure defensive insurance,
  independent of this feature.
- **Left in place:** `RETAIN-ENVELOPES-SAMPLES-TO-INSTRUMENTS-NOTES.md` (PR #3's
  notes) and `PR2-PR3-STUDY-2026-06-03.md` as historical record; this card now
  supersedes them as the live policy.

## Honest grade

`@build-verified` (BUILDALL clean, links clean). `@runtime-untested` for the
no-crash claim -- the EMM386 #12 crash can't be reproduced under DOSBox-X, and
the point of the removal is precisely that the crash-prone path no longer exists.
The behaviour restored IS upstream IT2.15, which is the most-proven code in the
tree, so confidence is high; but I did not drive a live F12 YES on hardware.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work/442513b6-4d90-4fef-959c-1ac9d79e8ec0.jsonl
- Session ID: `442513b6-4d90-4fef-959c-1ac9d79e8ec0`
- Resume: `claude --resume 442513b6-4d90-4fef-959c-1ac9d79e8ec0`
- Session timestamp: 2026-06-03 ~21:39 EEST (run `date` to confirm)
- CWD: /Users/esaruoho/work (repo at /Users/esaruoho/work/impulse-tracker)
