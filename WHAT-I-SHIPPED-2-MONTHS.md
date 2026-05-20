# Impulse Tracker — esaruoho fork

**Started**: 2026-04-22 · **Through**: 2026-05-20 (4 weeks) · `esaruoho/impulse-tracker` · upstream `jthlim/impulse-tracker` is read-only.

## Build / release

- Can build Impulse Tracker for DOS from a modern macOS or Linux machine and drop the resulting `IT.exe` + drivers onto a USB stick for any DOS PC.
- GitHub Action Workflows build IT.exe + drivers and publish a DOS-installable `.zip` release on every tag.

## MIDI sync

- MIDI Start / Stop / Continue (FA / FC / FB) drives IT's transport from Logic / hardware sequencers.
- MIDI Clock (F8, 24 ppq) external tempo sync.
- Independent toggles for Transport (FA/FB/FC) and Sync (F8) on Shift-F1.
- MIDI Monitor on Shift-F1 with live real-time-byte counters.
- 16 sound drivers stopped filtering F8-FF so real-time bytes actually reach IT.

## Multi-WAV / Whole-Song Export

Render each non-empty / non-muted channel to its own WAV file — for stem-based DAW import.

- **Shift-Alt-M** in F2: per-channel render of the **current pattern**. Skips channels with no playable notes in that pattern, skips channels the user has muted in the mix.
- **F10 "WAV" button**: whole-song render to a single WAV. Honours the filename you type in the F10 input — `song.wav` produces `SONG.WAV`.
- **F10 "MWAV" button**: whole-song per-channel render. `song.wav` produces `SONG01.WAV`, `SONG02.WAV`, …, `SONG<NN>.WAV` — one file per unmuted channel, each containing the full song with that channel solo'd. 8.3-safe name truncation; default `.WAV` extension if you don't type one.
- **Esc aborts** an in-flight Multi-WAV sweep cleanly — finishes the current channel, restores mute state, exits the chain.
- Built on a state machine: solo channel N → render → finalize via `Music_Poll` auto-finalize hook → advance to N+1. Auto-import is suppressed for the whole sweep (no sample-slot allocations).

Required adding **Condition 11 (Shift+Alt)** to IT's keymap dispatcher in `IT_K.ASM` — upstream had Conditions 0..10 (Alt, Shift, Ctrl, Left-Alt, Right-Alt etc.) but explicitly rejected any combo of Shift *with* Alt. New `K_TranslateCondition11` plus a `DB 11; DW 3232h` entry on the M scancode unlocks Shift-Alt-M (and any future Shift-Alt-X) properly.

## Pattern to Sample Render

Render the current pattern to a WAV file, optionally auto-imported as a sample. Available from:

- **Ctrl-O** (global): render + auto-import as next free sample slot, cursor lands on it.
- **Shift-Ctrl-O** (global): render to Quicksave folder only, no sample slot consumed (for cross-machine pickup).
- **Right** at F11 column 2: same as Ctrl-O.
- **Shift-Right** at F11 column 2: same as Shift-Ctrl-O.
- **Ctrl-G** at F11: Quicksave-only shortcut.
- **Shift-G** at F11: auto-import shortcut.

Plus:

- Unique filenames per render: first 3 chars of the song name (uppercased, non-alphanumeric → `X`), or `PTN` if the song has no name → `<PFX><NNNN>.<PPP>`. Nothing ever overwrites a prior take.
- Auto-imported sample is capped at 1MB (IT's per-slot sanity limit, only applies to the auto-import path — disk render itself is unbounded). Alloc-fail clears the dirty slot, IMPS filename field populated for traceability.

## F11 orderlist power tools

- **Left** at column 0: clone active pattern verbatim → insert at orderlist+1 → cursor advances.
- **Shift-Left** at column 0: clone with muted channels wiped (`^^^` note-cut at row 0) → insert → cursor advances.
- **Alt-D**: clone current pattern.
- **Alt-E**: double pattern length in place.
- **M**: toggle "clone respects channel mutes" (persisted in IT.CFG).
- **PATLOG.TXT** audit trail per F11 op.

## Quicksave folder

- **Alt-W**: save module to Quicksave folder, no prompt.
- **Shift-Alt-W**: memorize current folder as Quicksave.
- **F12 Quicksave row**: editable, persisted in IT.CFG.
- **Enter on F12 Quicksave row**: F9-style folder picker (with on-screen hint).
- Ctrl-O renders go straight into a sample slot (auto-import) — they don't accumulate as files in the Quicksave folder.
- Shift-Ctrl-O renders go to the Quicksave folder ONLY (no sample slot consumed) — the cross-machine pickup path.

## F12 directory pickers

- Enter on **Module / Sample / Instrument / Quicksave** rows opens an F9-style folder picker.
- Picker shows on-screen hint: `Navigate to target folder, press Esc to commit (Enter on file = LOAD!)`.
- Esc commits the navigated path back to the row.
- Unified `D_PickDir_Common` helper handles all four rows — each Pick* proc sets `DirectoryPickerTarget` to its own buffer offset, backs up SongDirectory, swaps the target in, jumps to F9. On Esc, the saved SongDirectory is restored and the picker's working path commits to the target.

## Loader

- **Shift-Enter** on a module file in F9: bulk-load all samples into consecutive slots. Auto-binds to instruments in Instrument mode. Works on `.IT` / `.S3M` / `.XM` / `.MOD` / `.MTM` / `.669` / `.PTM` / `.FAR`.
- F3 keyjazz inside F9 no longer kills the song (silences only the preview slot).
- F4 → F3 cursor translation: F3 from instrument list jumps the sample cursor to the instrument's bound sample.

## Editor

- **F2 double-press** pattern-length value also becomes the default for FUTURE empty patterns (persisted in IT.CFG).
- F12 Samples → Instruments mode flip preserves drawn envelopes.
- **Alt-R**: Replicate at Cursor (Paketti port). Shift-Alt-R: original Clear-all-track-views.
- Envelope preset save accepts Shift-1..9 (was Alt-only).

## Persistence

- `IT.CFG` gained a 16-byte `PE_ForkExtConfig` block (default pattern length + M-flag), backward-compatible with older configs.

## Docs

- README.md: musician-facing "What This Fork Lets You Do" + week-by-week changelog + engineering "Fork Changes (v2.354)" section.
- CLAUDE.md: keyboard reference grounded in IT.TXT line numbers + mixer / slave-channel layout.
- SKILL.md: architectural companion.

---

**Release**: <https://github.com/esaruoho/impulse-tracker/releases/tag/v2.354>
