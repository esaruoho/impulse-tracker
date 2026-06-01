# Crash diagnosis — Shift-Enter bulk-load → F12 "Samples to Instruments" → hard DOS lockup

Date: 2026-06-01. Reporter: Esa. Status: **ROOT CAUSE FOUND + FIXED (builds clean; live repro on the specific module still pending).**

## RESOLUTION (2026-06-01) — the crash was NOT the loader stale-state theory below

The stale-`NumSamples` / loader-directory theory in the rest of this doc was a real
latent bug but is **not** the crash. The crash is an **uninitialised envelope node
count fed to the instrument-mode renderer**:

1. The instrument slots hold uninitialised / leftover-garbage header bytes (after a
   sample-mode load, or after bulk-loading samples which never touches instruments).
2. F12 "Samples to Instruments + Initialize = YES" runs `F_SetControlInstrument`. The
   fork version no longer calls `Music_ClearAllInstruments` first; instead
   `Music_InstrumentHasEnvelopes` compares each slot's envelope bytes to the template,
   sees the garbage differs, concludes "user drew envelopes — preserve," and **skips
   the per-slot clear**. The original always normalised every slot, so the renderer
   never saw garbage.
3. The instrument screen then draws via `I_MapEnvelope` (`IT_I.ASM:6908`), which reads
   the envelope **node count** from `[SI+1]` into `MaxNode` and runs an **unbounded
   node-draw loop**. A garbage count (> 25, impossible in a real IT envelope, max 25)
   walks far past the 82-byte envelope struct and writes through a wild pointer →
   `EMM386 has detected error #12` GP fault / hard hang. (Matches the photo: 80CB:743E.)

### Fix shipped
- **`IT_I.ASM` `I_MapEnvelope`** — clamp `MaxNode` to ≤ 25 before the draw loop. Universal
  crash-proof: a corrupt node count can never drive an unbounded loop, via ANY path.
- **`IT_MUSIC.ASM` `Music_InstrumentHasEnvelopes`** — reject a structurally-invalid slot
  (any of the three envelope node counts at +131h/+183h/+1D5h > 25) before the template
  compare, returning "default" so `F_SetControlInstrument` clears it to the template
  instead of preserving garbage. Restores the original's safety while keeping the
  envelope-preservation feature for genuinely edited (≤ 25-node) instruments.

Both confirmed to assemble + link clean (IT.EXE 475,551 bytes, 0 errors/warnings).
Live verification on the exact module that crashed is still the last step.

---

## (Original investigation notes — loader stale-state, a separate latent bug)


## Repro (CORRECTED by Esa — it is F12, not F4)
1. Run IT.EXE. Press **F3** (sample list). Press **Enter** to open the sample-loader file browser.
2. Navigate to the first **.IT** module file and press **Shift-Enter** to bulk-load all of its samples into consecutive sample slots. (Done in **sample mode**, so the instrument-assign branch `LSBulkInstMode` is NOT taken — `Music_AssignSampleToInstrument` is never called during the load.)
3. Press **F12** (config screen) and choose **"Samples to Instruments"** / "Use Instruments" with **Initialize Instruments = YES**.
4. The whole DOS PC locks up (real-mode crash, not a graceful error).

## The crash site is the F12 conversion, not F4
The earlier F4 theory was wrong. The conversion that runs on "Samples to Instruments + Initialize = YES" is the fork's envelope-preserving proc **`F_SetControlInstrument` (`IT_F.ASM:4912-4974`)**. Its loop walks slots DX=0..99: `Music_InstrumentHasEnvelopes` → if default, `Music_ClearInstrument`, then `SI=[DS:BX+64912]` (sample offset), `DI=[DS:BX+64712]` (instrument offset), copy 26-byte name (SI+14h→DI+20h), then `Add DI,7` and fill 120 keymap entries (StosB+IncDI), writing slot+1 as the sample number.

`64712`/`64912` are SongData base-offset tables valid for all 100 slots, and the 120-entry keymap fill lands within the 554-byte instrument block (ends at base+0x137), so the indexing/extent of `F_SetControlInstrument` is NOT itself out of bounds. The fault therefore comes from **state the bulk-load left inconsistent** that this conversion (or the F12 mode-switch preceding it) reads — under active investigation.

## Code paths (verified by reading source)

- **Bulk-load handler:** `LSWindow_ShiftEnter`, `IT_DISK.ASM:7762-7957` (commit `f541198`). Dispatched from loader keytable `IT_DISK.ASM:988-990` (modifier `4`=Shift, key word `11Ch`=Enter).
- **Exit:** `Jmp Glbl_F3` at `IT_DISK.ASM:7931`.
- **Normal "view module" path it should mirror:** `LSViewWindow_Enter2`, `IT_DISK.ASM:7574-7642`.
- **Normal single in-module sample load:** `LSWindow_EnterSample`, `IT_DISK.ASM:7646-7730` (also exits `Jmp Glbl_F3`).
- **F3→F4 switch:** `Glbl_F4` (`IT_G.ASM:328`) → `Glbl_SampleToInstrument` (`IT_G.ASM:1002`) → `I_MapEnvelope` (`IT_I.ASM:6908`), then builds the instrument screen objects and sets `CurrentMode=4`.

## The defect (high confidence this is A bug; medium confidence it is THE crash)

`LSWindow_ShiftEnter` populates the module sample cache (via `LoadSamplesInModuleTable`) exactly like `LSViewWindow_Enter2`, but then **skips the "Setup first directory" block** that `LSViewWindow_Enter2` runs at `IT_DISK.ASM:7620-7642`:

| State the normal path sets | Bulk path | Risk if left stale |
|---|---|---|
| cache entry 0 ← `ExitLibraryDirectory` (89 bytes) | not set | first directory row points at module-sample data, not an exit slot |
| `SampleCacheFileComplete = 1` | not set | loader thinks cache is mid-fill |
| `SamplesInModule = 1` | not set | inconsistent with the populated cache |
| `SampleInMemory = FFFFh`, `SampleCheck = FFFFh` | not set | stale "currently in memory" sentinels |
| `LoadSampleNameCount = NumSamples` | not set | name list count out of sync |
| `NumSamples` restored | **clobbered to module count at 7819, never restored** | `NumSamples` is the loader directory-entry count (set `5151`, used as cursor bound `5563`/`5667`) — left equal to the module's sample count against a file-browser cache |

`NumSamples` clobber confirmed at `IT_DISK.ASM:7819` (`Mov NumSamples, 1`), used as loop bound at `7837`/`7869`, never restored before `Jmp Glbl_F3` (`7931`).

## Open question (why this is "medium" not "high" confidence)

The F4 entry path (`Glbl_F4` → `Glbl_SampleToInstrument` → `I_MapEnvelope`) reads **instrument** data in the Inst/SongData segment, not the disk-loader state above. In sample mode the bulk-load does not touch instruments. So the loader-state inconsistency does not *obviously* explain a crash that fires specifically on the F4 switch. Possible reconciliations, each needs confirming with a DOSBox repro on the actual module:

1. The F3 redraw after `Jmp Glbl_F3` (or the subsequent F4 transition) reads `NumSamples`/cache state and walks past valid entries → wild pointer.
2. `LoadSample` driven from the bulk loop with the per-cache-entry offsets left a sample header / instrument-offset table partially written, so `I_MapEnvelope`'s node-count read (`MaxNode = [SI+1]`, `IT_I.ASM:6971`) becomes garbage and the node-draw loop scribbles VRAM.
3. A secondary off-by-one in `Music_AssignSampleToInstrument` BX convention (0-based vs 1-based: `IT_MUSIC.ASM:6597-6601` does `Dec BX`, the loader callers at `IT_DISK.ASM:7716`/`7909` do not) — only fires in **instrument**-mode bulk-load, so not this repro, but a latent second bug.

## Proposed fix (best-effort hardening; verify against real module before claiming closed)

Before `Jmp Glbl_F3` at `IT_DISK.ASM:7931`, run the same directory-state restore the normal path does at `7620-7642` (copy `ExitLibraryDirectory` into cache entry 0; set `SampleCacheFileComplete`/`SamplesInModule`/`SampleInMemory`/`SampleCheck`/`LoadSampleNameCount`; restore `NumSamples` to a sane value for the file-browser directory). This makes the bulk path leave exactly the loader state that viewing-then-loading would, which is correct regardless of whether it is the sole crash cause.

## To actually verify the fix
- Need the specific module the user bulk-loaded (sample count + format), to reproduce in DOSBox-X with a host MIDI/null setup, switch F3→F4, and confirm no lockup.
- Build is now CI-verifiable (build.yml fixed 2026-06-01 to use TLINK 3.01 + gate on 42 drivers), so the fix can at least be confirmed to assemble/link/build all drivers.
