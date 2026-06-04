# Impulse Tracker 2.354 — what's new since IT 2.15

**Repo**: [`esaruoho/impulse-tracker`](https://github.com/esaruoho/impulse-tracker) · forked from upstream `jthlim/impulse-tracker` (read-only since 2014).
**Started**: 2026-04-22 · **Latest release**: [v2.354](https://github.com/esaruoho/impulse-tracker/releases/tag/v2.354) · **License**: BSD-3-Clause.

A 12-years-frozen DOS tracker, re-opened for active development and given the integrations modern producers expect — external sync, render-to-sample, stem export, cross-machine workflow — without changing the on-disk `.IT` file format.

---

## Build and release

- Build IT.EXE + 42 sound drivers + 1 network driver **for DOS, from a modern macOS or Linux machine** — drop the resulting binaries onto a USB stick and run them on any DOS PC.
- **GitHub Actions** builds the whole tree and publishes a DOS-installable `.zip` release on every tag push.
- One-line full rebuild locally via `BUILDALL.BAT` in DOSBox-X, ~57 seconds on M1.

## MIDI sync — Logic / hardware sequencers drive IT now

- **MIDI Start (FA)** → IT plays from order 0.
- **MIDI Continue (FB)** → resumes from current position.
- **MIDI Stop (FC)** → IT stops.
- **MIDI Clock (F8, 24 ppq)** → external tempo sync with delta-time sanity filtering.
- **Transport (FA/FB/FC) and Sync (F8) are independent toggles** on Shift-F1. Keep tempo sync but kill transport response, or vice versa. Solved Logic 5.5.1's clock jitter that made IT swing 121-136 BPM around a 125 BPM target.
- **MIDI Monitor** on Shift-F1 with live real-time-byte counters — see exactly what your DAW is sending.
- 16 sound drivers patched to stop filtering F8-FF in their IRQ handlers, so real-time bytes actually reach IT.

## Pattern to Sample Render — Ctrl-O

Render the current pattern to a WAV file and optionally auto-import it as the next sample. Five entry points:

| Trigger | Behavior |
|---------|----------|
| **Ctrl-O** (global) | Render + auto-import as next free sample slot, cursor lands on it |
| **Shift-Ctrl-O** (global) | Render to Quicksave folder ONLY, no sample slot consumed |
| **Right** at F11 column 2 | Same as Ctrl-O |
| **Shift-Right** at F11 column 2 | Same as Shift-Ctrl-O |
| **Ctrl-G** at F11 | Quicksave-only shortcut |
| **Shift-G** at F11 | Auto-import shortcut |

Filenames are unique per render: first 3 chars of the song name (uppercased, non-alphanumeric → `X`), or `PTN` if no song name → `<PFX><NNNN>.<PPP>`. Nothing ever overwrites a prior take. Auto-imported sample is capped at 1 MB (IT's per-slot sanity limit — disk render itself is unbounded).

## Multi-WAV / Whole-Song Export — for DAW stems

Render each unmuted channel to its own WAV, so a DAW can load the song as stems.

- **Shift-Alt-M** in F2: per-channel render of the **current pattern**. Skips channels with no playable notes (note-cut `^^^` doesn't count as a trigger), skips channels muted in the mix.
- **F10 "WAV" button**: whole-song render to a single WAV. Honors the filename you type — `song.wav` produces `SONG.WAV`.
- **F10 "MWAV" button**: whole-song per-channel render. `song.wav` produces `SONG01.WAV` … `SONG<NN>.WAV` — one file per unmuted channel, full song each, with that channel solo'd.
- **Esc aborts cleanly** mid-sweep — finishes the in-flight channel, restores mute state, exits.

Implementation note: required adding **Condition 11 (Shift+Alt)** to IT's keymap dispatcher. Upstream had Conditions 0..10 (Alt, Shift, Ctrl, Left-Alt, Right-Alt) but explicitly rejected any combo of Shift *with* Alt — so Shift-Alt-letter combos didn't emit any key word at all. The new condition + a `DB 11; DW 3232h` row on the M scancode unlock Shift-Alt-M (and the rest of the Shift-Alt-X space for future bindings).

## F11 orderlist — power tools

Live-performance pattern operations from the order list:

- **Left** at column 0: clone active pattern verbatim → insert at orderlist+1 → cursor advances onto the new row.
- **Shift-Left** at column 0: clone with muted channels wiped (`^^^` note-cut at row 0 silences ringing samples cleanly).
- **Alt-D**: clone current pattern (respects the M-toggle for mute-wiping).
- **Alt-E**: double pattern length in place.
- **M**: toggle "clone respects channel mutes" (persisted across sessions in IT.CFG).
- **PATLOG.TXT** audit trail in the active render directory — one line per clone / extend op.

## Quicksave folder — the cross-machine bridge

The pattern: tracker on the DOS box, DAW on the modern Mac, USB stick between them.

- **Alt-W**: save current module to the Quicksave folder, no prompt.
- **Shift-Alt-W**: memorize current load/save directory as Quicksave.
- **F12 Quicksave row**: editable, persisted in IT.CFG.
- **Enter on F12 Quicksave row**: F9-style folder picker with an on-screen hint so the "Load Module" title doesn't read as destructive.
- **Ctrl-O** renders go straight into a sample slot — they don't accumulate as files in the Quicksave folder.
- **Shift-Ctrl-O** renders go to the Quicksave folder ONLY (no sample slot consumed) — the cross-machine pickup path.

## F12 directory pickers — all four rows

Enter on **Module / Sample / Instrument / Quicksave** rows now all open an F9-style folder picker. Unified `D_PickDir_Common` helper: each row's Pick* proc sets `DirectoryPickerTarget` to its buffer offset, backs up `SongDirectory`, swaps in the target so the picker opens at the right place, posts the guidance hint, jumps to F9. Esc commits the working path back to the target and restores `SongDirectory`.

## Loader

- **Shift-Enter on a module file in F9**: bulk-load every sample from the module into consecutive sample slots starting at the cursor. Auto-binds to instruments in Instrument mode. Works on `.IT` / `.S3M` / `.XM` / `.MOD` / `.MTM` / `.669` / `.PTM` / `.FAR`.
- **F3 keyjazz inside F9 no longer kills the song** — silences only the preview slot, not the whole mix. Same fix folded into `Music_ReleaseSample` for safety.
- **F4 → F3 cursor translation**: F3 from the instrument list jumps the sample-list cursor to the sample bound to the highlighted instrument (note 60 first, then scan all notes).

## Pattern editor

- **F2 double-press** "Number of rows in pattern" value also becomes the default for FUTURE empty patterns (persisted in IT.CFG).
- F12 **Samples → Instruments mode flip preserves drawn envelopes** — walks instruments 0..98, preserves any with envelope bytes differing from the default template. "Initialize Instruments = YES" now means "fill in blank instruments, leave my work alone."
- **Alt-R**: Replicate at Cursor (Paketti port — tiles the source chunk through the rest of the pattern). Shift-Alt-R: original Alt-R Clear-all-track-views.
- Envelope preset save accepts **Shift-1..9** (was Alt-only).

## Persistence

`IT.CFG` gained a 16-byte `PE_ForkExtConfig` block (default pattern length + M-toggle), appended after the Quicksave Directory block. Backward-compatible with older configs via short-read fallback to static defaults.

## Documentation

- **README.md**: musician-facing "What This Fork Lets You Do" tour + week-by-week changelog + engineering "Fork Changes (v2.354)" section.
- **CLAUDE.md**: contributor guide with keyboard reference grounded in `IT.TXT` line numbers + Mixer & Slave Channel Layout drawn from `SoundDrivers/MIX.INC`.
- **SKILL.md**: architectural companion — keymap dispatch internals, Music_Stop's Cli window, the MIDISyncLoaderSuppress race-fix story, VRAM debug markers as triage tool.

---

**Release**: [v2.354 zip on GitHub](https://github.com/esaruoho/impulse-tracker/releases/tag/v2.354) — drop into a DOS PC and run.
**Source**: [github.com/esaruoho/impulse-tracker](https://github.com/esaruoho/impulse-tracker)
