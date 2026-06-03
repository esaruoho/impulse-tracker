# Session — shift-enter-bulk-load-from-module

> The thinkspace leg of the `shift-enter-bulk-load-from-module` report-card
> triad. Faithful, not flattering. The crash report, the root-cause trace, and
> why the fix is shaped the way it is.

## The request (verbatim)

Esa, 2026-06-03:

> "i was loading a .mod with shift-enter from F3 Sample List Load Sample, and the
> whole thing yanked completely. .. Feature: Shift-Enter Load from Sample List /
> Given that the User is in the Sample List / And they have selected a Module /
> When they press Shift-Enter on it / Then the samples of the module are loaded /
> And they display one sample at a time per row / With the original names of the
> Module Samples. And the Loop Modes store this as a .feature demand and then
> address it and update the scorecard."

So: (1) store the demand as a .feature, (2) fix the crash, (3) update the card.

## The investigation (how the root cause was found, by static trace)

1. The Shift-Enter handler is `LSWindow_ShiftEnter` (IT_DISK.ASM), bound in
   `LSWindowKeys` as cond 4 (Shift) / key 11Ch, sitting next to plain Enter
   (`LSWindow_Enter`). It only takes the bulk branch when the row type byte
   `[cache+88]` is >= 20h (a module file).
2. It sets up `InSampleFormat`/`InSampleChannels`/`InSampleDateTime`/
   `InSampleFileName`, opens the module, and calls the per-format loader from
   `LoadSamplesInModuleTable` — for .MOD that is `LoadMODSamplesInModule`
   (IT_D_RIS.INC). This loader populates the DiskDataArea cache, one ITS-format
   entry per sample at offset `sample*96`. Verified the entry layout by counting
   the StosB/StosW/StosD chain: filename at +4, flags at +12h, length at +30h,
   the sample file offset (EBP) at +48h — exactly what `LoadSample` reads.
3. The loader and `LoadSample` are SHARED with the stock path (plain Enter on a
   module -> `LSViewWindow_Enter2` -> browse the module's samples one per row ->
   Enter on one -> `LoadSample`). That stock path does NOT crash. So the MOD
   loader and `LoadSample` are not the culprit.
4. Diffed the fork bulk path against the stock single-load path. The ONE
   material difference: after the loader runs, the stock path
   (LSViewWindow_Enter2, ~7620-7639) finalises the cache:
     - writes cache **entry 0** = `ExitLibraryDirectory` (the navigational
       "exit module" row),
     - sets `SampleCacheFileComplete=1`, `SamplesInModule=1`,
       `SampleInMemory=0FFFFh`, `SampleCheck=0FFFFh`,
       `LoadSampleNameCount=NumSamples`.
   The fork bulk path skipped ALL of that and went straight to the loop +
   `Jmp Glbl_F3`. The loader cache was therefore left malformed: entry 0 never
   written, module-state globals stale.

## Root cause

On the screen transition (`Jmp Glbl_F3`) the loader's teardown/redraw walks the
cache — and on the no-samples branch it returns to the loader still showing it.
With entry 0 unwritten and `SamplesInModule`/`SampleCacheFileComplete` stale, that
walk reads garbage and hard-hangs ("yanked completely"). Single-loads never hit
this because the stock browse setup always leaves a consistent cache first.

## The fix

Insert the stock finalisation into the bulk path immediately after the loader
runs and BEFORE the `Cmp NumSamples,2` / loop — verbatim mirror of
LSViewWindow_Enter2's block (Xor DI,DI / Rep MovsB ExitLibraryDirectory / date /
the five globals). ES is still DiskDataArea from before the loader call, so the
entry-0 write needs no extra segment setup. Result: the bulk path's cache state
is byte-for-byte the proven stock module-browse state before anything else
happens, so both the loop and the teardown operate on a consistent cache.

Why this shape and not a rewrite: combine two already-proven-safe operations
(stock browse setup + stock single-load, which the loop is N copies of) instead
of inventing new teardown logic. Minimal, and it can't regress the stock paths
because it only touches LSWindow_ShiftEnter.

## The honest grade

`@build-verified` + `@fixed-pending-verify`.

- Build: real. `dosbox-x -conf buildall.conf` 2026-06-03 13:28 EEST. IT_DISK.asm
  "Error messages: None / Warning messages: None"; tlink 3.01 linked; IT.EXE
  476375 -> 476535 (+160).
- Runtime: NOT confirmed. I did not launch IT.EXE, open the Load Sample browser,
  Shift-Enter a real .MOD, and watch it load without hanging. The root cause is
  well-supported by the static diff against the proven stock path, but the
  no-hang outcome is unverified until run live. Grading it @runtime-verified
  would be a lie. Needs a DOSBox-X MOD test: confirm no hang, samples land one
  per row, names + loop modes preserved.

## Open follow-ups

- Live DOSBox-X test with a real multi-sample .MOD (and an .IT/.S3M to confirm no
  regression on the formats that previously "worked" through this path).
- If the hang persists, next triage is VRAM debug markers around LSWS_Loop and
  the screen transition (the fork's standard hard-hang tool), since LoadSample
  already carries markers 31-36.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work/442513b6-4d90-4fef-959c-1ac9d79e8ec0.jsonl
- Session ID: `442513b6-4d90-4fef-959c-1ac9d79e8ec0`
- Resume: `claude --resume 442513b6-4d90-4fef-959c-1ac9d79e8ec0`
- Session timestamp: 2026-06-03 ~13:29 EEST (run `date` to confirm)
- CWD: /Users/esaruoho/work (repo at /Users/esaruoho/work/impulse-tracker)
