# Impulse Tracker — esaruoho fork (v2.354)

> Active fork of [jthlim/impulse-tracker](https://github.com/jthlim/impulse-tracker).
> Upstream is read-only ("no active development, and changes/fixes will not be
> merged other than issues preventing build"). New features land here on
> [esaruoho/impulse-tracker](https://github.com/esaruoho/impulse-tracker).
> Current version: **2.354** — `(C) 1995-2000 Jeffrey Lim, (C) 2026 Esa Juhani Ruoho`.
> See [Changelog](#changelog) for week-by-week history and [Fork Changes](#fork-changes-v2354) for the v2.354 feature set.

Full source code for Impulse Tracker, including sound drivers, network drivers,
and some supporting documentation

This was originally released on BitBucket in 2014 alongside an article series
titled "20 years of Impulse Tracker", but BitBucket sunset mercurial
repositories, and so this is now made available on GitHub.

- [First Article](https://roartindon.blogspot.com/2014/02/20-years-of-impulse-tracker.html)
- [Second Article](https://roartindon.blogspot.com/2014/03/20-years-of-impulse-tracker-part-2.html)
- [Third Article](https://roartindon.blogspot.com/2014/10/20-years-of-impulse-tracker-part-3.html)
- [Fourth Article](https://roartindon.blogspot.com/2014/12/20-years-of-impulse-tracker-part-4.html)

Note that this repository is purely sharing what used to be -- there is no
active development, and changes/fixes will not be merged other than issues
preventing build.

## What This Fork Lets You Do

A musician-facing tour of the additions, written for people who make tracks rather than read assembly. Engineering details and commit hashes are in the [Changelog](#changelog) below and in [Fork Changes (v2.354)](#fork-changes-v2354) further down.

**Logic (or any DAW) can now drive Impulse Tracker.** Hit Play in Logic, IT starts. Hit Stop, IT stops. Press the transport on a hardware drum machine or a Beatstep, same deal. Before this you had to manually press F6 in IT and pray you'd hit it on the downbeat. Now the DAW is the master clock for your whole rig, IT included, and IT joins the bar like every other device in the chain.

**External tempo follow.** If your DAW is at 92 BPM, IT plays at 92 BPM. Change Logic to 124, IT slides over to 124 with it. You no longer have to manually keep the IT tempo field in sync with whatever you're working on outside. Useful when you're using IT alongside a DAW for resampling chops, or when you're jamming IT against a drum machine and the drum machine swings around.

**Two independent toggles for when sync goes wrong.** Real talk: some DAWs and old gear send filthy MIDI clock. Logic 5.5.1 sending 125 BPM makes IT bounce between 121 and 136 BPM because the clock ticks aren't perfectly even. So we split it into two switches on the Shift-F1 screen: one for transport (Start/Stop), one for clock (tempo follow). Now you can have Logic start IT on the downbeat while IT keeps its own rock-solid tempo, or have IT inherit Logic's tempo while ignoring its Play button. Mix and match per session.

**Shift-F1 MIDI watcher.** A little dashboard that counts the MIDI Start, Stop, Continue and Clock messages as they come in, plus the last one received. When sync isn't working, this tells you instantly whether the cable is the problem, the driver is the problem, or the toggle is off. No more "is anything actually arriving?" guessing.

**Real-time MIDI works on every sound card in the fork.** Before this, even with the MIDI sync code in place, half the sound cards silently dropped Start/Stop/Clock bytes — they were getting filtered out before IT ever saw them. We fixed that across all sixteen cards that have MIDI input (SB16, AWE32, GUS PnP, the ES1868 family, the Pro Audio Spectrums, etc.). Sync now works on whatever hardware you're actually using, not just the pure MPU-401 driver.

**Ctrl-O turns the current pattern into a sample, one keystroke.** You're working on a pattern, you like it, you want to chop it / pitch it / play it on another channel / use it as a drum hit. Ctrl-O renders the pattern to WAV in your sample directory, loads it as the next free sample slot, and parks the cursor on it ready to play. Vanilla IT could only render the whole song through the WAV driver via a three-screen detour and a sound-card switch; this is one key. The slot it picks is always free (it scans past your highest sample AND highest instrument), the filename is always unique (`REN001.001`, `REN002.001`, etc., never overwrites), and there's a 1 MB safety cap so you don't accidentally render a 90-second sustain into oblivion.

**Quicksave with Alt-W.** Iteration killer in vanilla IT: every save asks you for a path. So you save less than you should, and one day you lose work. Shift-Alt-W memorizes the folder you're in as your Quicksave folder, then forever after Alt-W writes your tune there using its existing filename, no prompt. Hammer Alt-W every minute. The folder is shown and editable on the F12 config screen and persists across launches.

**F12 directory picker.** Pressing Enter on the Module Directory or Quicksave Directory field in F12 opens the F9 file browser as a folder picker. Navigate, hit Enter, the path drops in. DOS path typing minimized.

**F3 / F4 cursor stays where you put it.** In vanilla IT, jumping from the instrument list (F4) back to the sample list (F3) resets the sample cursor to slot 1 every time. Annoying when you're working on instrument 17 which points at sample 23 — you have to scroll back. Now F3 from F4 lands on the sample bound to your current instrument (note 60 first, then any other note that has a sample). Round-trip preserves context.

**Alt-R Replicate at Cursor.** Stolen from Paketti / zTrackerPrime. You've got a 4-row groove at the top of a pattern, cursor at row 4. Hit Alt-R, IT tiles rows 0-3 down the rest of the pattern. Single channel, mirror-fills empties. Faster than copy-paste-paste-paste for any repeating motif. The original Alt-R ("clear all track views") moved to Shift-Alt-R so muscle memory still works.

**Keyjazz-preview samples without stopping the song.** This is the big one for sound-design flow. You're playing a tune. You open the F9 file browser, navigate to a folder of kicks (or hi-hats, or stabs — anything). You keyjazz a sample to audition it. In vanilla IT, the song stops dead, you lose your context, you have to restart it just to compare the next kick. In this fork, the song keeps going. Keyjazz mutes only the one preview voice and plays the new sample over the running pattern. You can A/B kicks against a live drum loop, find one that sits right, drop it in. Closest thing to a modern sampler-browser workflow we can get out of a 1995 DOS tracker.

**Loading a sample into a slot doesn't stop the song either.** Same fix, different keystroke. Pressing Enter on a sample file in the F9 loader replaces the current sample slot's contents. In vanilla IT this brute-stopped playback. Now only the voices currently mixing that specific slot fall silent for the duration of the file read; everything else keeps playing. Next pattern hit on the replaced slot triggers the new sample cleanly.

**Stop wiping envelopes by accident.** Drawing an envelope while you're in Sample mode, then switching to Instrument mode, used to silently nuke every envelope you'd drawn — the "Initialise instruments?" prompt defaulted to Yes and accidentally pressing Enter wiped them. Default is now No. Your envelopes survive the mode switch unless you explicitly Tab to OK.

**Shift-1..9 saves envelope presets.** The 0-9 load-envelope-preset feature was already in upstream IT, but undocumented and not visible — most people don't know it exists. Saves were on Alt-1..0 which clashed with muscle memory elsewhere. Now Shift-1..9 saves the current envelope shape to one of nine slots, 0-9 loads, and the slots persist in `IT.CFG` across sessions automatically. Build up a library of go-to ADSR shapes, reuse them across instruments and across songs.

**Saved `.IT` files identify themselves as fork-built.** The tracker version field embedded in saved Impulse Tracker files is now `2354h` instead of upstream's `0215h`. Means a fork file is distinguishable from an original-IT2.15 file by any tool that reads the header (Schism, OpenMPT inspectors, your own scripts). Useful if you ever wonder which version of IT a given `.IT` came out of.

**Shift-Enter on a module file row in F9 bulk-loads all its samples.** Drop into the sample loader, navigate to a `.IT` / `.S3M` / `.XM` / `.MOD` / `.MTM` / `.669` / `.PTM` / `.FAR` file, hit Shift-Enter (instead of Enter) — every sample inside that module lands in your slot list, starting at your current cursor. Plain Enter still drills into the module to pick samples one-by-one; Shift-Enter just takes the lot. In Instrument mode, each loaded sample also gets a new instrument header so you can play them immediately. Stops cleanly at slot 99 and skips empty slots in the source module. Song keeps playing while it loads.

**Switching Samples mode → Instruments mode now keeps your envelopes.** Old behaviour: pressing F12, picking Instruments, and clicking "Initialize Instruments = YES" wiped every Vol / Pan / Pitch / Filter envelope you'd drawn. Insidious, because Sample-mode envelope-drawing was silent (envelopes don't audibly play in Sample mode), so people would spend minutes shaping a 16-node Vol curve only to nuke it the moment they flipped modes. Now the mode-flip walks every instrument and only resets the truly-blank ones; anything with custom envelope data is left alone entirely. Pick YES on the dialog without fear.

**Ctrl-O renders go to your Quicksave folder, not the Sample folder.** Made for the cross-machine workflow. Point Quicksave at a shared drive / mounted volume / SMB share visible from your DAW box. Press Ctrl-O on the DOS PC, your rendered pattern lands in the shared folder, you drag-in to Logic / Bitwig / Ableton without ever touching the DOS PC's local filesystem. Falls back to the Sample folder if Quicksave isn't configured. Path validation: a bad Quicksave path aborts the render cleanly with "Render aborted: Quicksave folder invalid (check F12)" — never writes the file into a stale cwd and "loses" it.

**Shift-Ctrl-O = render to Quicksave, skip the auto-import.** Use this when you just want a WAV file for the DAW and don't want a new sample slot cluttering your IT sample list. Plain Ctrl-O still does render + auto-import-as-sample.

**Render diagnostics readable without a stopwatch.** When a Ctrl-O render fails on real hardware, IT used to flash debug markers across row 0 for a quarter second before the screen redrew them away. Now the failure path holds the screen up to 15 seconds OR until you press any key, whichever comes first. Markers at row 0 columns 25-27 tell you which validation check rejected the rendered WAV (`R` = RIFF magic, `W` = WAVE magic, `P` = PCM format code, `F` = fmt chunk size, `+` = all four passed). The 15-second cap is dismissable by any keystroke, so it's no longer indistinguishable from a hang.

**F11 order list got six new keys, all for working on whichever pattern is currently playing.**

- **Ctrl-O** in F11 — render the playing pattern + auto-import as next sample slot.
- **Shift-Ctrl-O** in F11 — render to Quicksave, no auto-import.
- **Shift-G** in F11 — same as Ctrl-O (render + auto-import). Plain `G` still goes to the pattern.
- **Ctrl-G** in F11 — same as Shift-Ctrl-O (render to Quicksave).
- **Alt-D** in F11 — clone the playing pattern into the next free slot. Doesn't overwrite anything; doesn't touch the order list (you wire the clone in yourself with F11 navigation).
- **Alt-E** in F11 — extend the playing pattern in place by doubling its row count. Rows 0..N-1 are kept, rows N..2N-1 are a copy. Safe to fire while the pattern is playing — the mixer is briefly paused under interrupts-masked, then resumes against the doubled buffer at the same row.
- **M** in F11 — toggle "Clone respects channel mutes" (default ON). When ON, Alt-D writes the canonical empty event on every muted channel and a note-cut (`^^^`) at row 0 of those channels, so lingering samples from the previous pattern can't bleed into the clone. The state of this toggle persists across IT launches.

**F11 cursor-keys at the edges of a pattern cell are repurposed for one-key gestures.** Each order-list cell is a 3-digit pattern number; the cursor lives at digit position 0 / 1 / 2 inside it. The natural wrap-around at the edges (Left at 0 jumps to 2, Right at 2 jumps to 0) is rebound:

- **Left at col 0** — clone playing pattern, verbatim. (Mute-wipe always OFF here, ignores the M toggle.)
- **Shift-Left at col 0** — clone with mute-wipe + `^^^` at row 0.
- **Right at col 2** — render + auto-import (same as Ctrl-O).
- **Shift-Right at col 2** — render to Quicksave (same as Shift-Ctrl-O).

Cursor navigation at the middle digit position is unchanged.

**Default pattern length is configurable.** Vanilla IT hardcodes new patterns to 64 rows. Now, sitting on an empty pattern and pressing F2-F2 opens the Pattern Edit Config dialog as usual — change "Number of rows in pattern" to 128 or 192 or whatever, click Done, and from that point on every fresh empty pattern auto-opens at that length. The choice survives IT restarts because it's persisted in `IT.CFG`. Same field, new semantics: whatever value you last set the pattern length to is the default for every empty pattern you enter from now on.

## Changelog

Newest first. Six weeks of active development since the fork resumed on 2026-04-22. Commit hashes link to the fork's `main` branch.

### 2026-05-20 (later) — Multi-WAV / Whole-Song Export, Shift+Alt keymap condition, F12 Sample+Instrument pickers, F10 WAV/MWAV buttons

- **`9fb5ac1`** — Multi-WAV state machine. `Music_StartMultiWAV` backs up `MuteChannelTable` into `WAV_MultiSavedMutes`, then chains per-channel renders via `Music_Poll`'s finalize hook: solo channel N → `Music_ToggleWAVRender` → `Music_PlayPattern` / `Music_PlaySong` → leave-mode → `WAV_MultiAdvance` → solo channel N+1. Auto-import suppressed for the whole sweep (`WAV_NoImport` re-armed per kick). Esc abort polled via `K_IsKeyDown(01h)` in `Music_Poll` (not `Int 16h` — IT's dispatcher consumes the keyboard queue first).
- **Shift-Alt-M** in F2 = per-channel render of the current pattern. `PE_ChannelIsEmpty` only counts notes 0..119 (note-cut `0FEh`, note-off `0FFh`, NONOTE `0FDh` don't count) — channels with only `^^^` are treated as silent and skipped. Also skips channels muted in the user's saved mix.
- **F10 "WAV" button** (SaveFormat=4) = whole song to a single WAV. **F10 "MWAV" button** (SaveFormat=5) = whole song per channel. Both honour the filename you type in F10's input: `D_CopyUserFilenameToFileName` copies `SaveFileName` into `FileName` and sets `WAV_UserFilenameSet`; `Music_ToggleWAVRender` skips its auto-rename when that flag is set. `RenderedFilename` mirrors `FileName` for the post-render status message so the displayed name matches the actual file on disk.
- **MWAV per-channel filename suffixing.** `WAV_BuildChannelFilename` parses `WAV_UserBase` (canonical Music-side copy of the user's typed name), truncates the base to 6 chars if needed so the final 8.3 filename fits, inserts the 2-digit 1-based channel number before the `.`, defaults extension to `.WAV` if the user didn't type one. `song.wav` → `SONG01.WAV`, `SONG02.WAV`, …, `SONG<NN>.WAV`.
- **Song-mode skip-only-on-mute.** When `WAV_MultiSongFlag` is set (= whole-song MWAV), `WAV_MultiAdvance` bypasses the `PE_ChannelIsEmpty` check entirely — that helper only sees the editor's currently-loaded pattern, and would wrongly skip channels that have notes elsewhere in the song. In song-mode, only `WAV_MultiSavedMutes[chan] != 0` decides the skip.
- **`WAV_SongMode` flag** swaps `Music_PlayPattern` for `Music_PlaySong(0)` in the enter-mode path. Filename extension is `.WAV` (not the 3-digit pattern number) when SongMode is set.
- **New `K_TranslateCondition11` for Shift+Alt** (`IT_K.ASM`). Upstream Conditions 0..10 cover Alt/Shift/Ctrl individually but explicitly reject Shift *combined with* Alt (Condition 5's `Test CH, Not 61h` fails when shift bits are set). Adds `Condition 11 = Shift + Alt (any Alt side)` with `Test CH, Not 67h; Test CH, 6; Test CH, 60h`. Plus a `DB 11; DW 3232h` row on the M scancode so Shift-Alt-M emits the fork-extension key word `3232h`, which the PE keymap routes to `PEFunction_StartMultiWAVKey`. **Corrects a long-standing wrong assumption** that Shift-Alt-letter worked through Condition 5 — testing on dosbox-x confirmed it didn't emit any key word at all without Condition 11.
- **F12 Sample / Instrument / Quicksave rows now Enter-pickable** via unified `D_PickDir_Common` helper. Each `Pick*` proc sets `DirectoryPickerTarget` to its own buffer offset (`SampleDirectory` / `InstrumentDirectory` / `QuickSaveDirectory`), backs up `SongDirectory` into `QuickSaveBackup`, copies the target in so F9 opens at the right place, posts a 10s guidance info-line (`"Navigate to target folder, press Esc to commit (Enter on file = LOAD!)"`), and tail-jumps to `Glbl_F9`. `D_PickerEsc` reads `DirectoryPickerTarget` and commits the picker's working `SongDirectory` back to the target on exit. Module-directory row keeps its in-place behaviour (target = 0).
- **F10 dispatch fixes.** Three sites needed teaching about `SaveFormat 4/5`: `D_SaveModule` (default-extension append), `D_PostFileSaveWindow3` (actual format dispatcher reached via `D_SaveModule`'s Jmp), `D_SaveSong` (Ctrl-S path). Missing any one silently routed WAV/MWAV through the IT-module save path with a `.WAV` extension — what the user actually saw the first time before this was fully wired.

### 2026-05-20 — F11 clone auto-insert + cursor advance, runtime status messages, F12 Quicksave Enter, crash hunt

- **F11 Left / Shift-Left clone now auto-inserts into the order list and advances the cursor.** After the clone completes (`PEFunction_StorePattern` returns), `PE_OrderList_ClonePattern_Body` shifts orderlist bytes `[Order+1..510]` down by one (same `StD` / `Rep MovsB` pattern as the existing Ins-key handler `PE_PostOrderList19`), stamps the cloned pattern number into slot `Order+1`, then bumps `[Order]` so the F11 cursor lands on the new row. Mirrors what musicians actually want when they ask the tracker to "duplicate the current pattern": the new pattern is in the song flow ready to edit, not stranded as an orphan slot you have to manually wire in.
- **Runtime status messages** now show real data instead of static templates. The clone path builds `"Dup pat NNN to orderlist YYY"` at runtime in `PE_CloneRunMsg` via a new `PE_FormatU16Dec3` Near proc (3-digit decimal conversion). The Shift-Ctrl-O / Shift-Right no-import path builds `"Saved pat NNN as <filename>"` in `WAV_NoImportRunMsg` from `WAV_PendingPattern` + the already-built `RenderedFilename`. Both replace the previous static-text `0FDh,'D'` substitution which only supported one number per message.
- **5-second info-line hold on success** (`PE_HoldInfoLine` Far). `Int 1Ah` BIOS-tick busy-wait with `Int 16h AH=01h` keyboard peek bail-out and `Int 16h AH=00h` keystroke eat so the held line doesn't leak into the next event. 91 ticks ≈ 5 s @ 18.2 Hz. The previous 15 s budget was too long; 5 s is enough to read a 30-character info line without feeling like a hang.
- **F12 Quicksave directory row is now Enter-able.** New `D_PickQuickSaveDir` Far proc backs up `SongDirectory` into `QuickSaveBackup`, copies `QuickSaveDirectory` into `SongDirectory`, sets `DirectoryPickerActive` + a new `QuickSavePickerActive` flag, and tail-jumps to `Glbl_F9`. `D_PickerEsc` checks `QuickSavePickerActive` on exit: if set, copies the picker's working `SongDirectory` back into `QuickSaveDirectory` and restores `SongDirectory` from `QuickSaveBackup`. Wired into `QuickSaveDirectoryInput` in `IT_OBJ1.ASM` (was `DD 0`, now `DD DWord Ptr D_PickQuickSaveDir`). Mirrors how the existing Module-directory row works via `D_PickModuleDir`.
- **`PATLOG.TXT` audit trail** for every F11 clone op (Alt-D / Left / Shift-Left), `EXTEND` op (Alt-E), and Ctrl-O render. One-line summary per op (`CLONE  src=NNNN dst=NNNN wipe=NNNN`, `EXTEND pat=NNNN rows=NNNN`). Lives in the active render directory (Quicksave folder if configured, else SampleDirectory, else cwd). Per-stage breadcrumb logging was tried and removed — each open+seek+write+close in DOSBox-X added ~1 s, making a single clone feel like a 30 s hang.
- **Crash hunt:** found and fixed a register-restore order bug in `PE_OrderList_ApplyMuteWipe`'s epilogue (one missing `Pop DS` left every subsequent `Pop` shifted by a slot and `Ret` jumped to garbage — hard "Illegal Interrupt 6" crash on Shift-Left). Found and fixed a `DS`-segment-mismatch bug where `[PE_CloneTargetPat]` reads in the clone body's tail (after `NewPattern` / `StorePattern` clobbered `DS`) returned the wrong segment's bytes (`src=0501 dst=0200` style garbage in the audit log + wrong target byte written into the orderlist). Both fixed by re-establishing `DS=Pattern` at each read site (and `CS:` override for the byte read).

### 2026-05-19 — F11 order-list power tools, Ctrl-O Quicksave routing, envelope preservation final pass, persisted IT.CFG ext block

- **`068648f`** — Default new-pattern row count is configurable via F2-double-press. The existing Pattern Edit Config dialog field for "Number of rows in pattern" now persists into a new `IT.CFG` extension block; the same value is used as the default for FUTURE empty patterns. `NewPattern_ApplyDefaultLength` in `IT_PE.ASM` checks the pattern entry table at `SongData+63912`: if the type byte is 0 (slot was empty, `DecodePattern` just pulled in `EmptyPattern`'s baked-in 64 rows), `MaxRow` is overridden from `DefaultNewPatternLength` (clamped 32..200). Same commit persists the `M` toggle (`ClonePatternMuteWipe`) in `IT.CFG`. Both values live in a new 16-byte `PE_ForkExtConfig` block appended after the Quicksave Directory block; backward-compatible with older `IT.CFG` files via short-read fallback to static defaults.
- **`5ece809`** — `BACKLOG.md`: moved both deferred items to Implemented.
- **`ecc745b`** — `BACKLOG.md`: living brainstorming surface for "what I want for this tracker" with sections for in-flight, scoped deferrals, freeform wishlist, shipped features (with SHAs), and rejected ideas.
- **`90cfd04`** — F11 cursor-key edge gestures: `OrderCursor` at digit position 0 + Left = clone verbatim (`PE_OrderList_LeftDispatch` tail-jumps to `PE_OrderList_ClonePatternModal` with BL=0); position 0 + Shift-Left = clone with mute-wipe (BL=1); position 2 + Right = render + auto-import (tail-jumps to `PE_OrderList_RenderDispatch`); position 2 + Shift-Right = render to Quicksave. Cursor navigation through middle positions falls through to the original `PE_PostOrderList7` / `PE_PostOrderList9` wrap handlers. Mute-wipe writes `^^^` (note-cut `0FEh`) at row 0 of every muted channel + `NONOTE` elsewhere — prevents lingering-sample bleed from the previous pattern into the clone. Single-row patterns take the `PE_OrdWipe_OneRowOnly` fast-path.
- **`1a7aa16`** — F11 order list ops: `Ctrl-O` (render + auto-import), `Shift-Ctrl-O` (render to Quicksave, no import), `Ctrl-G` (Quicksave shortcut), `Shift-G` (auto-import shortcut), `Alt-D` (clone), `Alt-E` (extend = double rows in place), `M` (toggle clone-respects-mutes). New `PE_OrderList_ResolvePattern` helper resolves "active pattern" — engine's `CurrentPattern` when `PlayMode != 0`, else the order-cursor's pattern byte at `SongData+256+Order`. New `Music_FindFreePattern` Far helper walks the 200-slot pattern entry table for the first slot with type byte 0. New `Music_GetMuteChannelTable` cross-segment accessor returning `ES:DI -> MuteChannelTable`. Clone + extend use the existing `PE_SaveCurrentPattern` / `NewPattern` / `PEFunction_StorePattern` pipeline — `ClI/StI` bracket around `Music_ReleasePattern` + `Music_AllocatePattern` + `EncodePattern` makes mid-playback safe. Wipe-mode latched into `PE_CloneWipeMode` static byte at proc entry; survives intermediate `PE_SaveCurrentPattern` / `NewPattern` register trashing.
- **`18e8da4`** — Ctrl-O diagnostic markers: per-validation marker letters at row 0 col 27 (`R` / `W` / `P` / `F` / `+`) before the conditional jump for each of the 4 header checks; render-dir cd markers at cols 25-26 (`d` = attempted, `e` = succeeded). `WAV_HoldForMarkers` now polls `Int 16h AH=01h` every loop and bails on any keystroke, with a 15-second timeout. "Rendering pattern to WAV ..." info-line message fires at Ctrl-O enter-mode so long renders don't look frozen. F2 Ctrl-O dispatcher also gains its own markers (cols 40-42: `X` = dispatcher entered, `p`/`s` = plain/shift branch, `L`/`R`/`-` = which shift key was held) so Shift-Ctrl-O detection failures can be diagnosed at the keymap level.
- **`a98a37c`** — Shift-Ctrl-O = render to Quicksave WITHOUT auto-import (file lands for cross-machine pickup, no IT sample slot consumed). Plumbing: `WAV_NoImport` flag armed by dispatcher in `IT_PE.ASM`, latched into `WAV_SessionNoImport` at enter-mode, consumed at leave-mode. `D_GotoRenderDirectory` rewritten with inline `Int 21h AH=3Bh` chdir + drive-letter parse (the previous version delegated to `D_SetDriveDirectory` which swallowed the chdir error). `Music_ToggleWAVRender` now runs a pre-flight chdir BEFORE touching audio state — bad Quicksave path aborts cleanly without sound glitch. WAVI_FailedTail invokes `WAV_HoldForMarkers` before stashing the error message.
- **`97712ce`** — Ctrl-O routes renders to the Quicksave folder instead of `SampleDirectory`. New `D_GotoRenderDirectory` Far helper: Quicksave if configured, else SampleDirectory, else cwd no-op. Called at enter-mode AND again right before the import `Int 21h Open` — the driver swap in `WAV_LeaveMode` (`Music_AutoDetectSoundCard` etc.) was leaving us in a stale cwd between WAVDRV's write and the import's read, masquerading as "cannot open .NNN file".
- **`d8ec842`** — F12 Samples → Instruments mode flip preserves drawn envelopes for real this time. The prior `4e4eb9a` fix defaulted the dialog focus to "No" but didn't gate the destructive `Music_ClearAllInstruments` path itself. Now `F_SetControlInstrument` walks instruments 0..98 and calls a new `Music_InstrumentHasEnvelopes` Far proc per slot, comparing bytes `130h..554` (the Vol/Pan/Pitch/Filter envelope section, 250 bytes) of each live instrument against the default `InstrumentHeader` template. Slots whose envelope bytes differ from default are preserved entirely; only default-blank slots get the original clear + sample-name copy + 120-note keymap fill. "Initialize Instruments = YES" now means "fill in blank instruments, leave my work alone."
- **`054f1f0`** — `.gitignore` for repo-root `IT.CFG`. The fork bundles `IT.CFG` into every `IT2354-esaruoho-<sha>.zip` release for drop-in installs; the canonical copy lives on a portable volume, mirrored into the repo root for zip staging, gitignored to keep personal config (MIDI ports, Quicksave path) out of public history.
- **`f541198`** — Shift-Enter on a module file row in the F9 sample loader bulk-loads every sample from that module into consecutive sample slots starting at the current F3/F4 cursor. Works on `.IT` / `.S3M` / `.XM` / `.MOD` / `.MTM` / `.669` / `.PTM` / `.FAR`. In Instrument mode, each loaded sample is also auto-assigned to an instrument via `Music_AssignSampleToInstrument`. New `LSWindow_ShiftEnter` proc in `IT_DISK.ASM` reuses the per-format `LoadSamplesInModuleTable` loaders + the existing `LoadSample` proc in a loop, gated by `MIDI_SetLoaderSuppress` so an FA/FB/FC byte buffered during any per-call `Music_SilenceSampleVoices` Cli window cannot restart playback into a half-loaded slot. New keymap entry `DB 4 / DW 11Ch / DW LSWindow_ShiftEnter` uses type-4 (Shift modifier) dispatch so plain Enter on a module row is unchanged.

### 2026-05-18 — Playback-safe sample reload, dual MIDI toggles, envelope dataloss fix

- **`f10e961`** — Envelope preset save accepts Shift-1..Shift-9 (the original Alt-1..Alt-0 still works). Load with 0..9 in the envelope edit screen. Presets persist in `IT.CFG` automatically. The feature was already wired up in upstream (`ENABLEPRESETENVELOPES=1`); only the modifier was widened.
- **`4e4eb9a`** — Sample→Instrument mode-switch prompt ("Initialise instruments?") now defaults focus to **No**, so accidental Enter no longer wipes envelopes via `Music_ClearAllInstruments`. OK is still one Tab away if you actually want to re-init.
- **`731e168`** — **MIDI Transport (FA/FB/FC)** toggle added on Shift-F1 alongside the existing **MIDI Sync (F8 Clock)** toggle. Independent gates: turn off transport response while keeping tempo sync, or vice versa. Solves Logic 5.5.1's clock jitter making IT fluctuate 121-136 BPM around a 125 BPM target.
- **`a44c41b`** — New `Music_SilenceSampleVoices Far` proc in `IT_MUSIC.ASM`. Loading a sample (Enter on the sample list, or keyjazz preview inside the F9 file browser) no longer brute-stops the whole song — it silences only the slave channels currently reading the target slot. Mixer's `Word Ptr [SI] = 200h` sentinel is documented and reused; the same primitive is folded into `Music_ReleaseSample` for safety.
- **`16d89da`**, **`e3e6940`** — `CLAUDE.md` gains a User-Facing Keyboard Reference table grounded in `IT.TXT` line numbers, and a Mixer & Slave Channel Layout section drawn from `SoundDrivers/MIX.INC` and `IT_MUSIC.ASM`. Future contributors stop guessing offsets and key bindings.

### 2026-05-13 — Release workflow

GitHub Actions release pipeline that produces a DOS-installable ZIP on dispatch.

- **`2eb6088`** default version 2.354 + overwrite-existing-release behaviour.
- **`e4fafa6`** simplify dispatch UI to a single version input.
- **`400ea5b`** fix `.DRV.DRV` double-extension when source extension was uppercase.
- **`c599007`** swap in TLINK 3.01 at runtime (the GitHub-runner toolchain ships TLINK 7.1).
- **`fe1df01`** dump diagnostics + upload logs on driver-build failure.
- **`141893b`** handle lowercase `.drv` / `.net` artifacts from DOSBox-X on Linux.
- **`62e6991`** replace heredoc with echo block to fix YAML indent.
- **`8d80eff`** initial `release.yml` — DOS-installable zip workflow.

### 2026-05-12 — Alt-R Replicate at Cursor (Paketti port), F3 loader hang fix

- **`0afd402`** — `SKILL.md`: architectural reference companion to `CLAUDE.md`, lives at `~/.claude/skills/impulse-tracker/`.
- **`aaada5e`** — Alt-R row-0 boundary: when cursor is at row 0, tile row 0 down the whole pattern instead of no-op. **Shift-Alt-R** now hosts the original Alt-R "Clear all track views" behaviour via runtime modifier disambiguation through `K_IsKeyDown`.
- **`d506486`** — **Alt-R = Replicate at Cursor** in the pattern editor. Port of the Paketti / zTrackerPrime feature: takes rows `0..cursor-1` as the source chunk and tiles them down to `MaxRow`. Mirror semantics (empty events copy verbatim). Undo slot 23. Networked to peers via `NetworkPatternBlock`.
- **`64fa1ce`** — F3 loader keyjazz hard hang fixed. `MIDISend`'s FA/FB/FC callbacks are suppressed during `LoadSample → Music_PlaySample` via the new `MIDISyncLoaderSuppress` flag, set/cleared by Far helpers from `IT_DISK.ASM`. Closes the race where an external clock's MIDI Start, buffered during `Music_Stop`'s Cli window, would re-enter playback mid-sample-load and trash EMS pointers.
- **`ec91331`** — Loader keyjazz path instrumented with VRAM markers (`D_DebugMark` cols 30-39) before the targeted fix. Markers stay in tree.

### 2026-05-04 — MIDI sync hardening, monitor, driver fixes

- **`3537c0d`** — Ctrl-O WAV leave/import paths instrumented with VRAM markers (`WAV_DebugMark` cols 1-28). Establishes the standard hard-hang triage primitive.
- **`78fb72d`**, **`4ebf849`** — All 16 sound drivers with MIDI-in (`GUSMIXDR`, `IWDRV`, `SB16*`, `AWE32*`, `ES1868`, etc.) stop filtering MIDI System Real-Time bytes (`F8-FF`). The pre-fork filter dropped every byte ≥ `0xF0` intending to skip SysEx, but caught Start/Stop/Continue/Clock too. The pure `MIDIDRV.ASM` was always clean.
- **`95f628a`** — Shift-F1 MIDI screen now shows live RT-byte counters (Start / Continue / Stop / Clock + last-RT-byte and DOS-tick of last RT message). Diagnostic for "are bytes even arriving."
- **`7163709`** — MIDI Sync toggle moved from Alt-F12 to a Shift-F1 button. Alt-F12 collided with the F5 spectrum analyzer.
- **`8ca7078`** — F12 Module Directory field's Enter now opens F9 as a directory picker (sets a transient flag so the save handler returns the picked dir instead of loading the highlighted file).
- **`8f11aa6`** — F12 directory inputs translate `/` to `\` so muscle-memory Unix slashes don't break.
- **`ad5d840`** — MIDI Sync now default ON. Alt-F12 hotkey added (later moved to Shift-F1 button).
- **`2051b90`** — README documents the v2.354 feature set (MIDI sync, P3 render, quicksave, build infra).
- **`7df9edf`** — Tracker version bumped to **2354h**. Esa Juhani Ruoho 2026 copyright line added.
- **`34b725d`** — `.gitignore` covers `CACHE.ITS` and rendered `004_*.001` sample dumps so working trees stay clean.

### 2026-05-01 — Pattern-to-Sample (P3), quicksave, F4↔F3, MIDI clock tempo sync

The bulk of the feature work. P3 in particular went through ~20 iterations in a single day.

- **`7fd1abc`** — F12 config screen: Quicksave directory input row.
- **`6464e15`** — Quicksave folder: **Alt-W** saves there, **Shift-Alt-W** memorizes target.
- **`0c02662`**, **`d13a849`**, **`81c78aa`**, **`9bd18d1`**, **`64b853b`**, **`bb5e5ea`**, **`09d7e7d`**, **`f136a7b`**, **`e3f5815`**, **`b0690a4`**, **`ce3fb79`**, **`3a626b4`**, **`4d5e9da`**, **`9ed42ed`**, **`1d7910e`** — P3 ("Pattern-to-Sample") hardening pass: 1 MB safety cap, configurable loop-on-render, IMPS filename field, cwd reentrancy gate, WAV validation, unique `REN<NNN>.<PPP>` filenames, target-slot calculation, alloc-fail cleanup, granular failure messages, page-counter / off-by-one fixes, auto-select imported sample, status-message timing.
- **`af03f96`** — Ctrl-O auto-imports the rendered pattern as a new sample.
- **`089119a`** — Ctrl-O toggles the active driver to `ITWAV.DRV` to do the render (P2a).
- **`35732c3`** — Ctrl-O renders current pattern, phase 1 (no auto-import yet).
- **`e4c9b4a`** — P2/P3 deep-dive findings document.
- **`fc92c77`** — `.gitattributes` locks `*.ASM` / `*.INC` to ISO-8859-1 + CRLF so modern editors don't UTF-8-mangle the CP437 box-drawing characters.
- **`0a82cb3`**, **`03b0a6d`** — MIDI Clock 0xF8 external tempo sync (24 PPQ → DOS-tick-delta → BPM). Default off; sanity-filtered against absurd deltas.
- **`9d626b0`**, **`672273b`** — F4 → F3 cursor translation. Pressing F3 from the instrument list jumps the sample cursor to the sample bound to the currently-highlighted instrument (note 60 first, then scan all notes), with bounds checks.
- **`1b2bcf1`** — Skip-stubs for 13 sound-driver build batches that need TASM32 or have missing sources.

### 2026-04-30 — TLINK 3.01 unlock + first Ctrl-O render

- **`be79b3c`** — TLINK 3.01 unlock. The `zajo/TASM` mirror ships TLINK 7.1, which rejects every sound driver with `Fatal: No program entry point`. Dropping in TLINK 3.01 (1990) builds all 42 drivers + `IT.EXE` + `ITIPX.NET` in ~57 seconds inside DOSBox-X.
- **`5bd73ed`** — `CLAUDE.md`, `BUILDALL.BAT`, and `buildall.conf.sample` for one-shot full rebuilds on a modern Mac.

### 2026-04-22 / 04-23 — CI + the original MIDI Start/Stop intercept

- **`1fa031c`** — GitHub Actions workflow: build `IT.EXE` and all drivers via DOSBox-X under xvfb on every push/PR, with TASM/TLINK/MAKE reassembled from 13 base64 secrets.
- **`ec42bd1`** — Seed commit. `IT_K.ASM` `MIDISend` intercepts `0xFA` (Start) and `0xFC` (Stop) System Real-Time bytes, routing them to `Music_PlaySong` / `Music_Stop`. Every sound driver with a MIDI-in hook gains transport sync at the single host-side intercept point. Everything else in this changelog grew from this one proc.
- **`aa311f5`** — `.gitignore` for macOS `.DS_Store` files.

## Pre-Requisite Software

To build Impulse Tracker, you will need:

- Turbo Assembler v4.1

- Turbo Link v3.01

- Borland MAKE v4.0

- A DOS environment

Once you have these, building IT.EXE should be just a single call to `MAKE`

Sound drivers are build individually via M\*.BAT files inside the SoundDrivers
subdirectory

## Building on macOS / Linux (esaruoho fork)

This fork (`esaruoho/impulse-tracker`) builds `IT.EXE` **and all 42+ drivers**
cross-platform via DOSBox-X. The required Borland binaries are not
redistributable, but two public GitHub mirrors cover the toolchain:

- **TASM 4.1 + Borland MAKE 4.0** from [zajo/TASM](https://github.com/zajo/TASM).
  The 16-bit DPMI variant `TASMX.EXE` is required for `IT_MDATA.asm` (the stock
  `TASM.EXE` runs out of memory on its large data tables); rename `TASMX.EXE`
  to `TASM.EXE` in your toolchain directory.
- **TLINK 3.01** from [nolanvenhola/zeliard2026](https://github.com/nolanvenhola/zeliard2026)
  at `3_Assembly/tasm/tool/tasm201/TLINK.EXE` (53,510 bytes, 1990 Borland).
  Skip the TLINK 7.1 that ships with `zajo/TASM` — it rejects driver objects
  with `Fatal: No program entry point`. TLINK 3.x links both `IT.EXE` and every
  driver without modification. (Alternate source:
  [darkhani/kstools](https://github.com/darkhani/kstools).)

Drop both into `tools-local/` (gitignored) and run `BUILDALL.BAT` from the repo
root inside DOSBox-X. The `buildall.conf.sample` file ships a working DOSBox-X
config — copy it to `buildall.conf` (also gitignored), then:

```
dosbox-x -conf buildall.conf -fastlaunch -exit -nogui -nomenu
```

Total wall time: ~57 seconds on an M1 Mac. Outputs: `IT.EXE` (462 KB), 42
sound drivers (`IT*.DRV`), `ITIPX.NET`, plus `MAKE.LOG`, `DRV_SND.LOG`,
`DRV_NET.LOG`.

See [CLAUDE.md](CLAUDE.md) for full architecture / patch / contribution
documentation.

GitHub Actions CI: see `.github/workflows/build.yml`. Requires the toolchain
to be uploaded as 13 base64-chunked repo secrets `TASM_TOOLCHAIN_B64_01`
through `TASM_TOOLCHAIN_B64_13` (single-secret 48 KB limit forces chunking).
Bundle TASM, TASMX (renamed to TASM), MAKE, **and TLINK 3.01** into the ZIP.

## Fork Changes (v2.354)

Why fork at all: Impulse Tracker 2.15 (the last upstream release) is a beautifully
finished DOS tracker, but it's MIDI-out-only (no external sync), it can't render
its own patterns to disk as samples for resampling/chopping, and a few
modern-workflow conveniences (quick-save folder, F4↔F3 cursor parity) are
missing. This fork adds those without changing the on-disk `.IT` file format.

The version field embedded in saved `.IT` files (`SWITCH.INC` →
`TRACKERVERSION`) is **2354h**, distinguishing files written by this build from
upstream-2.15 (`0215h`) and from the prior fork interim (`217h`).

### MIDI sync from external clocks (Features 1 + 4)

Upstream IT consumes MIDI input only for live note entry into the pattern
editor. This fork intercepts MIDI System Real-Time messages (`0xF8`/`0xFA`/
`0xFB`/`0xFC`) at the single host-side `MIDISend` proc in `IT_K.ASM`, so
**every sound driver with a MIDI-in hook gains sync without driver
modifications** (Sound Blaster 16's MPU-401 UART, the dedicated MPU-401
driver, etc.).

- `0xFA` MIDI Start  → `Music_PlaySong` from order 0
- `0xFB` MIDI Continue → resumes from current position
- `0xFC` MIDI Stop  → `Music_Stop`
- `0xF8` MIDI Clock (24 ppq) → external tempo sync with delta-time sanity
  filtering. Off by default; enable via the config flag described in
  `IT_MUSIC.ASM`.

`MIDISend` runs in main-loop context (drivers buffer the IRQ-time bytes), so
calling playback procs directly from the intercept is safe.

### Pattern-to-Sample render (Feature 3, "P3")

Upstream renders only via the explicit "Save WAV" disk-writer driver workflow
(switch sound card → render full song → switch back). This fork adds in-place
pattern rendering bound to **Ctrl-O** in the pattern editor:

1. Ctrl-O switches the active sound driver to `ITWAV.DRV`, plays the current
   pattern once (or loops, configurable), and writes a WAV.
2. Render output goes to the user's `SampleDirectory` with a unique
   `REN<NNN>.<PPP>` filename (no overwrites of prior renders).
3. The rendered sample is auto-imported into the next free slot — computed as
   `max(highest sample, highest instrument) + 1` — and the cursor lands on it
   so the next Enter plays it back.
4. Hardening: cwd reentrancy gate, WAV header validation, 1 MB safety cap with
   user warning + length adjust, alloc-fail clears the dirty slot, IMPS
   filename field (+4..+15) populated with the rendered `.NNN`.

### Quick-save folder (Alt-W / Shift-Alt-W + F12 row + Enter to pick)

- **Shift-Alt-W** — memorize the current load/save directory as the "Quicksave
  folder."
- **Alt-W** — save the current module to that folder, no prompt, using the
  module's existing filename.
- **F12 config screen** — Quicksave directory is an editable input row,
  persisted across sessions. **Enter on the row** opens an F9-style folder
  picker rooted at the current Quicksave path; navigate as usual and press
  **Esc** to commit. (Same mechanism the Module-directory row uses, just
  re-targeted at `QuickSaveDirectory`.)

### Multi-WAV / Whole-Song Export (Shift-Alt-M + F10 WAV / MWAV)

Render each channel of a pattern (or the whole song) to its own WAV file — for DAW import as stems.

- **Shift-Alt-M** in F2 = per-channel render of the **current pattern**. Skips channels with no playable notes (note-cuts `^^^` don't count as triggers) and channels muted in the mix.
- **F10 "WAV" button** = whole song to a single WAV. Honours the filename you type in the F10 input (`song.wav` → `SONG.WAV`).
- **F10 "MWAV" button** = whole song with each unmuted channel rendered to its own WAV. `song.wav` → `SONG01.WAV`, `SONG02.WAV`, …, `SONG<NN>.WAV` — one file per channel.
- **Esc aborts** an in-flight Multi-WAV sweep — finishes the current channel, restores the mute state, exits the chain.

Implementation note: required adding **Condition 11 (Shift+Alt)** to IT's keymap dispatcher in `IT_K.ASM`. Upstream Conditions 0..10 covered Alt, Shift, Ctrl individually but explicitly rejected Shift *combined with* Alt — so Shift-Alt-letter combos didn't emit any key word at all. The new condition (and a `DB 11; DW 3232h` row on the M scancode) finally make Shift-Alt-M dispatch properly, and the same mechanism opens up the rest of the Shift-Alt-X space for future bindings.

### F11 clone with auto-insert (Left / Shift-Left at orderlist column 0)

In F11 with the cursor on the leftmost digit of an orderlist row, **Left**
clones the active pattern (the one playing, or the one at the cursor row when
stopped) into the next free slot, **inserts it into the orderlist below the
current row**, and advances the F11 cursor onto that new row. **Shift-Left**
does the same but wipes events on currently-muted channels (with a `^^^`
note-cut at row 0 so any sample still ringing from the previous pattern is
silenced cleanly when the clone starts playing).

Status line shows `Dup pat NNN to orderlist YYY` for ~5 s after the op so you
can see exactly which slot got the clone and where it landed in the orderlist.
Press any key to dismiss the held message early. Audit trail in
`PATLOG.TXT` (in the Quicksave folder, or wherever your render dir resolves
to) records `CLONE src=NNNN dst=NNNN wipe=NNNN` per op.

### F4 → F3 cursor translation (Feature 2)

Pressing **F3** from the instrument list (F4) now jumps the sample-list cursor
to the sample bound to the currently-highlighted instrument (note 60 first,
falling back to a scan of all notes), instead of resetting to sample 1.

### Build / CI infrastructure

- **TLINK 3.01 unlock** — drivers refused to link with the modern TLINK 7.1
  shipped by `zajo/TASM` (`Fatal: No program entry point`); switching to
  TLINK 3.01 (1990) builds all 42 drivers + IT.EXE + ITIPX.NET in ~57 s.
- **`BUILDALL.BAT`** at the repo root invokes the main `MAKEFILE.MAK` plus the
  per-subdirectory `BUILDALL.BAT`s under `SoundDrivers/` and `Network/` for a
  one-shot full rebuild.
- **`buildall.conf.sample`** — DOSBox-X config that mounts the repo and
  `tools-local/`, runs `BUILDALL.BAT`, and exits. One-line full-rebuild on
  a modern Mac.
- **GitHub Actions CI** (`.github/workflows/build.yml`) — builds everything on
  push/PR via DOSBox-X under xvfb, with the toolchain reassembled from 13
  base64-chunked repo secrets.
- **`.gitattributes`** locks `*.ASM`/`*.INC` working-tree-encoding to
  ISO-8859-1 + CRLF so modern editors don't UTF-8-mangle the CP437
  box-drawing characters in the original Borland-era source comments.

## Quick File Overview

- IT.ASM:
  Startup routines
- IT_DISK.ASM:
  Disk IO Routines. Uses IT_D\_\*.INC files

- IT_DISPL.ASM:
  Display routines for the Playback Screen (F5)

- IT_EMS.ASM:
  EMS memory handling routines

- IT_F.ASM:
  Collection of functions used by the object model

- IT_FOUR.ASM:
  Fast Fourier routines. Used by the graphic equalizer (Alt-F12).
  Not available on all all sound cards

- IT_G.ASM:
  Global key handler functions

- IT_H.ASM:
  Help Module (F1)

- IT_I.ASM:
  Sample list (F3) and Instrument list (F4) module

- IT_K.ASM:
  Keyboard module

- IT_L.ASM:
  Information line code

- IT_M.ASM:
  Main message loop/dispatcher

- IT_MDATA.ASM:
  Global music variable data

- IT_MMTSR.ASM:
  Sample compression/decompression routines

- IT_MOUSE.ASM:
  Mouse handling code

- IT_MSG.ASM:
  Message editor module (Shift-F9)

- IT_MUSIC.ASM:
  Module playback code. Also uses IT_M_EFF.INC

- IT_NET.ASM:
  Network code

- IT_OBJ1.ASM:
  UI object definitions

- IT_PE.ASM:
  Pattern Editor module (F2)

- IT_S.ASM:
  Screen functions, including character generation

- IT_TUTE.ASM:
  Interactive Tutorial module

- IT_VESA.ASM:
  VESA code for graphic equalizer

- SWITCH.INC:
  High level switches for the program

## Frequently Asked Questions

Q: "What are all those funny characters in the source code?"

A: I wrote the original source code using DOS characters, with characters drawing borders/boxes in
comments in the source code. In the interests of posterity, I have left the code intact as it was.

Q: "Why didn't you use STRUCs or ENUMs" in your ASM source?

A: Simply because I didn't know about them at the time. I wish I did. There's a InternalDocumentation
folder that I've included in the repository that details what some of the magic numbers appearing
through the code might mean.

Q: "Flow in some functions seems to jump all over the place. Why?"

A: The original code was compatible all the way back to an 8086 machine. 8086 would allow you to do
conditional jumps only within +/-128 bytes, so I spent too much time shuffling code around to meet
this restriction. When I shifted away from this 8086 restriction, I never went back to update the
code that was mutilated by it.

## License

BSD 3-clause license can be found in [LICENSE](LICENSE).
