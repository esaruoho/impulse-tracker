# Hardware Test Sheet — IT.EXE on real DOS metal

> **GENERATED** from the `.feature` cards by `features/gen-hwtest.py`. Do not hand-edit. A scenario is **🔴 RED-LINED** until its card is graded `@hw-verified`; flip the card tag (runtime→hardware) and regenerate.

**Build under test:** `v2.354-2026-06-04 @a317aa4`  ·  put this IT.EXE on the DOS machine and work the 🔴 list.

**Record results without burning chat:** run `./test-impulse-tracker` from the repo (works from any dir) — the TUI walks these, takes works/failed/notes, flips passes to `@hw-verified`, and writes `features/HW-FAILURES.md` (the only thing to send back).

**Focus order:** (1) 🔴 fork features below, DOSBox ✓ first (fast confirm), then DOSBox ✗ (never even emulated). (2) Stock/upstream last (low risk).

| | Count |
|---|---:|
| Total scenarios | 126 |
| 🔴 Need hardware test | 123 |
| ✅ Hardware-verified | 3 |


---

## 🔴 Fork features — test these on the metal


### `alt-r-replicate`
- ✅ OK [x] Alt-R and Shift-Alt-R are disambiguated by live shift state
- ✅ OK [x] Cursor above row 0 tiles the rows-above-cursor chunk downward  — _DOSBox ✓ (quick re-confirm on metal)_
- ✅ OK [x] Cursor on row 0 tiles row 0 down the whole channel  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] No-op at the pattern edges
- 🔴 [ ] Shift-Alt-R replicates the whole PATTERN at cursor  — _DOSBox ✗ — UNTESTED even in emulation_

### `f11-order-list`
- 🔴 [ ] Alt-D clones the current pattern to the first free slot
- 🔴 [ ] Alt-E doubles the current pattern's length by tiling
- 🔴 [ ] M toggles the clone mute-wipe mode
- 🔴 [ ] Ctrl-O renders the active pattern to WAV (Shift-Ctrl-O = no import)
- 🔴 [ ] Ctrl-G and Shift-G render variants
- 🔴 [ ] Cursor-key edge gestures clone (left) and render (right)

### `f12-song-variables`
- 🔴 [ ] A Quicksave directory row is on the F12 screen
- 🔴 [ ] Each directory row is Enter-pickable through a file browser
- 🔴 [ ] Samples->Instruments keeps drawn envelopes

### `f2-pattern-editor`
- 🔴 [ ] F2-F2 remembers the chosen pattern length for new patterns
- 🔴 [ ] A freshly-entered empty pattern uses the remembered length

### `f2-resize-tiles-pattern`
- 🔴 [ ] 64 -> 128 duplicates the 64 rows once  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] 64 -> 192 duplicates the 64 rows twice  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] Non-multiple lengths get a partial final copy ("until the end")  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] Shrinking the pattern does not tile
- 🔴 [ ] Scope is the F2 config path only
- 🔴 [ ] The tiled buffer persists via the working-copy model

### `f3-sample-list`
- 🔴 [ ] Previewing a sample in the loader does not stop the song
- 🔴 [ ] MIDI transport bytes can't restart the song mid-load
- 🔴 [ ] Shift-Enter bulk sample load is guarded the same way

### `f4-instrument-list`
- 🔴 [ ] The per-instrument MIDI-In Channel is edited on the Pitch tab

### `f6-play-from-order-list-row`
- 🔴 [ ] F6 loops the pattern at the selected order row  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] F6 outside the Order List keeps its stock "play current pattern"
- 🔴 [ ] A skip/end marker order slot is a no-op
- 🔴 [ ] F7 plays from the SELECTED order at the current edit row  — _DOSBox ✗ — UNTESTED even in emulation_

### `midi-in-multitimbral`
- 🔴 [ ] Output MIDI fields are independent of the input field  — _stock/upstream — low risk_
- 🔴 [ ] Each instrument can claim an incoming MIDI channel
- 🔴 [ ] First Shift-F4 maps current samples to MIDI-In 01-16
- 🔴 [ ] Second Shift-F4 replicates 01-16 across six banks (96 instruments)
- 🔴 [ ] Third Shift-F4 resets the six banks back to one 01-16 set
- 🔴 [ ] An incoming note on channel N triggers the matching instrument
- 🔴 [ ] Channel 1 note entry is unchanged when the router is off
- 🔴 [ ] The router on/off switch lives on the Shift-F1 MIDI screen

### `midi-realtime-sync`
- 🔴 [ ] Real-Time bytes are dispatched without disturbing running status
- 🔴 [ ] 0xFA Start plays the song from the top
- 🔴 [ ] 0xFC Stop halts playback
- 🔴 [ ] 0xFB Continue currently behaves as Start (known v1 limitation)
- 🔴 [ ] 0xF8 Clock derives IT tempo from the master at 24 PPQ
- 🔴 [ ] MIDI Transport can be switched off, swallowing FA/FB/FC
- 🔴 [ ] MIDI Sync (clock) can be switched off independently, ignoring F8
- 🔴 [ ] Loader keyjazz suppresses transport re-entry
- 🔴 [ ] Sound drivers pass F8-FF through to MIDISend
- 🔴 [ ] The MIDI Monitor shows live Real-Time byte counters

### `multi-wav`
- 🔴 [ ] Shift-Alt-M renders the current pattern per non-empty channel  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] F10 "WAV" renders the whole song to a single WAV  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] F10 "MWAV" renders the whole song as per-channel stems  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] The Shift+Alt keymap path exists (this part IS structural)

### `multitimbral-instrument-play-dots`
- 🔴 [ ] Stock IT hid the F4 dots whenever instrument mode was off  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] With the router on, F4 shows play dots even in Sample mode  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] Normal Sample mode (router off) is unchanged
- 🔴 [ ] The dot row is the routed instrument, not a sentinel

### `sample-amplify-keeps-playback`
- 🔴 [ ] Amplifying a sample mid-playback does not stop the song  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] Alt-M Maximize/Normalize during playback keeps playing through OK/Process  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] REGRESSION (reported 2026-06-03) - Alt-M still stopped F6 playback  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] Only the amplified sample's voices are silenced, not all channels
- 🔴 [ ] The mixer never reads the sample while it is being rewritten
- 🔴 [ ] AX (the sample number) survives the silence call

### `scrolllock-follow-from-lists`
- 🔴 [ ] Scroll Lock in the Sample List opens the Pattern Editor with Follow Mode on  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] Scroll Lock in the Instrument List does the same  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] Ctrl-F in the Sample List (F3) or Instrument List (F4)  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] Ctrl-F INSIDE the Pattern Editor (F2) toggles Follow Mode, not the config dialog  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] Ctrl-F on the Order List (F11) or Song Variables (F12) enters the editor  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] Follow Mode is forced ON, never toggled off, from the lists
- 🔴 [ ] The handler hands Glbl_F2 the dispatcher's own DS (no segment damage)

### `shift-enter-bulk-load-from-module`
- 🔴 [ ] Shift-Enter on a module bulk-loads its samples into consecutive slots  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] Loaded samples keep their original module names and loop modes  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] REGRESSION (reported 2026-06-03) - Shift-Enter on a .MOD hard-hangs IT

### `shift-enter-load-from-sample-list`
- 🔴 [ ] Shift-Enter on a module loads its samples one per row
- 🔴 [ ] Loaded samples keep their original names and loop modes
- 🔴 [ ] In Instrument mode each sample is also auto-assigned to an instrument
- 🔴 [ ] Samples->Instruments envelope retention does NOT clash with this

### `shift-f4-drumkit`
- 🔴 [ ] Shift-F4 Create builds the drumkit automatically, alongside 01-16  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] The drumkit maps each sample slot to a successive key  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] The drumkit responds to MIDI channel 10  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] Each pad plays its sample at fixed base pitch (C-5), not transposed  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] The 3-state Shift-F4 cycle never touches the drumkit  — _DOSBox ✗ — UNTESTED even in emulation_

### `shift-f4-enters-instrument-mode`
- 🔴 [ ] From Sample mode, Shift-F4 + confirm enters Instrument mode with 16 instruments  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] The mode switch is a direct flag set, NOT the F12 clear/remap path
- 🔴 [ ] Declining the prompt changes nothing

### `wav-render-quicksave`
- 🔴 [ ] Shift-Right at the order-list right edge renders to Quicksave only  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] Plain Right at the same edge renders AND auto-imports  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] A single-pattern Quicksave render is named by wall-clock time  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] The prefix is a static "LL" (Lackluster), not derived from the song
- 🔴 [ ] The extension is a real .WAV, not the 3-digit pattern number  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] The auto-import opens the exact file WAVDRV wrote  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] Multi-WAV, full-song, and user-named renders keep <PFX><NNNN>

### `wav-render-reentry-guard`
- 🔴 [ ] The old behaviour -- a second gesture tore the driver down mid-playback
- 🔴 [ ] Right starts the render, Shift-Right during it halts and finalizes  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] WAV_FinalizeRequest tells the genuine finalize apart from a re-press
- 🔴 [ ] The genuine auto-finalize is unchanged -- still leaves + imports
- 🔴 [ ] Early-stop reuses the existing safe finalize, not a new teardown  — _DOSBox ✓ (quick re-confirm on metal)_
- 🔴 [ ] All render entry points share the one central guard
- 🔴 [ ] Multi-WAV sweep finalize and chaining are untouched


---

## Stock / upstream behaviours (low priority — verify only if time)


### `f11-order-list`
- 🔴 [ ] F11 opens the order list with channel panning  — _stock/upstream — low risk_
- 🔴 [ ] A second F11 toggles to channel volume  — _stock/upstream — low risk_
- 🔴 [ ] Stock order-list editing keys  — _stock/upstream — low risk_

### `f12-song-variables`
- 🔴 [ ] F12 opens the song variables & configuration screen  — _stock/upstream — low risk_

### `f2-pattern-editor`
- 🔴 [ ] First F2 enters the pattern editor  — _stock/upstream — low risk_
- 🔴 [ ] Second F2 (already in the editor) opens Pattern Edit Config  — _stock/upstream — low risk_

### `f3-sample-list`
- 🔴 [ ] F3 opens the sample list  — _stock/upstream — low risk_
- 🔴 [ ] Ctrl-F3 opens the disk Sample Library from anywhere  — _stock/upstream — low risk_

### `f4-instrument-list`
- 🔴 [ ] F4 opens the instrument editor  — _stock/upstream — low risk_
- 🔴 [ ] Pressing F4 again cycles the instrument tabs  — _stock/upstream — low risk_
- 🔴 [ ] Ctrl-F4 opens the disk Instrument Library from anywhere  — _stock/upstream — low risk_

### `f6-play-from-order-list-row`
- 🔴 [ ] F7 outside the Order List keeps its stock from-mark behaviour  — _stock/upstream — low risk_

### `midi-in-multitimbral`
- 🔴 [ ] Polyphony per channel

### `midi-realtime-sync`
- 🔴 [ ] 0xFB Continue resumes from the last-known order/row

### `multi-wav`
- 🔴 [ ] WHAT WOULD VERIFY THIS CARD (the test that has not been run)  — _DOSBox ✗ — UNTESTED even in emulation_

### `multitimbral-instrument-play-dots`
- 🔴 [ ] Instrument mode still shows dots exactly as before  — _stock/upstream — low risk_

### `sample-amplify-keeps-playback`
- 🔴 [ ] Alt-M on the Sample List is the Amplify gesture  — _stock/upstream — low risk_
- 🔴 [ ] The dialog pre-fills the no-clip (normalize) amplification  — _stock/upstream — low risk_
- 🔴 [ ] Other Sample-List operations that still stop the song are untouched  — _stock/upstream — low risk_

### `scrolllock-follow-from-lists`
- 🔴 [ ] Scroll Lock inside the Pattern Editor still just toggles Follow Mode  — _stock/upstream — low risk_
- 🔴 [ ] (not built) Scroll Lock / Ctrl-F from other screens (Order list F11, Song vars F12)

### `shift-f4-enters-instrument-mode`
- 🔴 [ ] (verify live) cursor + playback survive the mode switch  — _DOSBox ✗ — UNTESTED even in emulation_

### `wav-render-quicksave`
- 🔴 [ ] Two renders in the same second overwrite

### `no-samples-to-instruments-envelope-retention`
- 🔴 [ ] Initialise Instruments = YES does the upstream clear + remap  — _DOSBox ✗ — UNTESTED even in emulation_
- 🔴 [ ] The envelope-retention feature and its IMPI checker are gone
- 🔴 [ ] Shift-Enter bulk-load can no longer feed the crash class
- 🔴 [ ] The I_MapEnvelope MaxNode<=25 clamp stays as defensive insurance  — _stock/upstream — low risk_
- 🔴 [ ] (guardrail) Do not re-introduce envelope retention without HW verify

