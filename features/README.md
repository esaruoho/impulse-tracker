# Impulse Tracker (esaruoho fork) — Feature Reference

> **Generated** from the Gherkin report cards in this folder by `python3 features/print-card.py --readme`. Do not hand-edit — edit the `.feature` card and regenerate. Each entry below = one card: *what it does* (the feature intent + behaviour scenarios) and *how it does it* (the procs/files the behaviour is cited to).

Each card is a triad: the `.feature` spec, a `.session.md` (the conversation that produced it), and a RESULT-LOG of what shipped. See `GHERKIN-FEATURE-WIKI-PATTERN.md` and `INDEX.md`.

## Contents

- [Alt-R replicate at cursor](#alt-r-replicate) — `alt-r-replicate.feature`
- [User Presses F11 (Order List)](#f11-order-list) — `f11-order-list.feature`
- [User Presses F12 (Song Variables & Directory Configuration)](#f12-song-variables) — `f12-song-variables.feature`
- [User Presses F2 (Pattern Editor)](#f2-pattern-editor) — `f2-pattern-editor.feature`
- [F2 pattern-length increase duplicates (tiles) the existing content](#f2-resize-tiles-pattern) — `f2-resize-tiles-pattern.feature`
- [User Presses F3 (Sample List)](#f3-sample-list) — `f3-sample-list.feature`
- [User Presses F4 (Instrument List)](#f4-instrument-list) — `f4-instrument-list.feature`
- [Multitimbral MIDI-In](#midi-in-multitimbral) — `midi-in-multitimbral.feature`
- [External MIDI Real-Time Sync](#midi-realtime-sync) — `midi-realtime-sync.feature`
- [Multi-WAV render](#multi-wav) — `multi-wav.feature`
- [F4 instrument-list play dots in multitimbral Sample mode](#multitimbral-instrument-play-dots) — `multitimbral-instrument-play-dots.feature`
- [F12 Samples->Instruments uses upstream clear+remap (no envelope retention)](#no-samples-to-instruments-envelope-retention) — `no-samples-to-instruments-envelope-retention.feature`
- [Sample Amplify keeps the song playing](#sample-amplify-keeps-playback) — `sample-amplify-keeps-playback.feature`
- [User Presses Scroll Lock while in F3 (Sample List) or F4 (Instrument List)](#scrolllock-follow-from-lists) — `scrolllock-follow-from-lists.feature`
- [Shift-Enter Load from Sample List (bulk-load a module's samples)](#shift-enter-bulk-load-from-module) — `shift-enter-bulk-load-from-module.feature`
- [Shift-Enter Load from Sample List](#shift-enter-load-from-sample-list) — `shift-enter-load-from-sample-list.feature`
- [Shift-F4 to enable Multitimbral mode also switches Samples -> Instruments](#shift-f4-enters-instrument-mode) — `shift-f4-enters-instrument-mode.feature`
- [WAV Quicksave render filename](#wav-render-quicksave) — `wav-render-quicksave.feature`
- [WAV render re-entry guard -- a second render gesture mid-render stops cleanly](#wav-render-reentry-guard) — `wav-render-reentry-guard.feature`


<a id="alt-r-replicate"></a>
## Alt-R replicate at cursor

`features/alt-r-replicate.feature` · [session](alt-r-replicate.session.md)

**What it does:** As someone filling a pattern channel with a repeating figure, I want Alt-R to tile the rows above the cursor down to the end of the channel, So that I can lay down a one- or few-row loop and stamp it across the pattern without copy/paste — while Shift-Alt-R keeps the original "clear track views".

**Behaviour (5 scenarios):**

- Alt-R and Shift-Alt-R are disambiguated by live shift state — `@shipped @build-verified`
- Cursor above row 0 tiles the rows-above-cursor chunk downward — `@shipped @build-verified @runtime-untested`
- Cursor on row 0 tiles row 0 down the whole channel — `@shipped @build-verified @runtime-untested`
- No-op at the pattern edges — `@shipped @build-verified`
- Shift-Alt-R preserves the original "clear all track views" — `@shipped @build-verified @runtime-untested`

**How it does it:** **Key procs:** `PEFunction_AltR_Dispatch`, `PEFunction_ReplicateAtCursor`, `PEFunction_ClearViews` · **Source files:** `IT_PE.ASM`

**Grade:** @build-verified ×5 · @runtime-untested ×3 · @shipped ×5

**Commits:** `d506486` Alt-R = Replicate at Cursor · `aaada5e` Alt-R tile at row 0 + Shift-Alt-R = ClearViews (original Alt-R)


<a id="f11-order-list"></a>
## User Presses F11 (Order List)

`features/f11-order-list.feature`

**What it does:** As someone sequencing patterns into a song, I want F11 to open the order list and toggle to channel volume, and the fork power tools to clone / extend / render patterns right from the order list, So that arranging and bouncing patterns happens without leaving this screen.

**Behaviour (9 scenarios):**

- F11 opens the order list with channel panning — `@stock @build-verified`
- A second F11 toggles to channel volume — `@stock @build-verified`
- Stock order-list editing keys — `@stock @build-verified`
- Alt-D clones the current pattern to the first free slot — `@shipped @build-verified`
- Alt-E doubles the current pattern's length by tiling — `@shipped @build-verified`
- M toggles the clone mute-wipe mode — `@shipped @build-verified`
- Ctrl-O renders the active pattern to WAV (Shift-Ctrl-O = no import) — `@shipped @build-verified`
- Ctrl-G and Shift-G render variants — `@shipped @build-verified`
- Cursor-key edge gestures clone (left) and render (right) — `@shipped @build-verified`

**How it does it:** **Key procs:** `Glbl_F11`, `PE_OrderList_ClonePattern`, `PE_OrderList_ExtendPattern`, `PE_OrderList_ToggleMuteWipe`, `PE_OrderList_ApplyMuteWipe`, `PE_OrderList_RenderDispatch`, `PE_OrderList_RenderQuicksave`, `PE_OrderList_GDispatch`, `PE_OrderList_RightDispatch`, `PE_OrderList_LeftDispatch`, `Music_FindFreePattern`, `Music_GetMuteChannelTable`, `ClonePatternMuteWipe`

**Grade:** @build-verified ×9 · @shipped ×6 · @stock ×3

**Commits:** `fb47b32` Import code (upstream base: F11 order list / panning / volume) · `1a7aa16` F11 order list: render / clone / extend ops + mute-wipe toggle · `4eee4f8` F11 clone auto-insert + runtime status messages · `90cfd04` cursor-key edge gestures (note-cut at row 0 for mute-wipe clone) · `74c3fe8` Shift-Right single-pattern Quicksave render -> LL<HHMMSS>.WAV


<a id="f12-song-variables"></a>
## User Presses F12 (Song Variables & Directory Configuration)

`features/f12-song-variables.feature`

**What it does:** As someone setting up a tune and its working folders, I want F12 to open song variables plus the module/sample/instrument/quicksave directories, with each directory row pickable, and Samples->Instruments to keep my drawn envelopes, So that song config and folder routing live on one screen and nothing is lost.

**Behaviour (4 scenarios):**

- F12 opens the song variables & configuration screen — `@stock @build-verified`
- A Quicksave directory row is on the F12 screen — `@shipped @build-verified`
- Each directory row is Enter-pickable through a file browser — `@shipped @build-verified`
- Samples->Instruments keeps drawn envelopes — `@shipped @build-verified`

**How it does it:** **Key procs:** `Glbl_F12`, `QuickSaveDirectoryInput`, `D_PickModuleDir`, `D_PickSampleDir`, `D_PickInstrumentDir`, `D_PickQuickSaveDir`, `D_PickDir_Common`, `F_SetControlInstrument`, `Music_InstrumentIsReal`

**Grade:** @build-verified ×4 · @shipped ×3 · @stock ×1

**Commits:** `fb47b32` Import code (upstream base: F12 song variables / config) · `7fd1abc` F12 config screen: add Quicksave directory input row · `8f11aa6` Quickfix: translate '/' to '\' in F12 directory input fields · `4eee4f8` F12 dir pickers via unified D_PickDir_Common · `d8ec842` F12 Samples->Instruments preserves drawn envelopes (first attempt) · `b5a0c66` Revert envelope preservation (EMM386 #12 crash) · `9a1142c` Cleaner policy: always remap + keep envelopes; gate garbage-clear on IMPI · `9493101` Merge PR #3 -> envelope preservation re-lands in main


<a id="f2-pattern-editor"></a>
## User Presses F2 (Pattern Editor)

`features/f2-pattern-editor.feature`

**What it does:** As someone editing a tune, I want F2 to take me to the pattern editor, and a second F2 to open its configuration, with my chosen pattern length remembered for new patterns, So that the most-used screen is one key away and never forgets my row count.

**Behaviour (4 scenarios):**

- First F2 enters the pattern editor — `@stock @build-verified`
- Second F2 (already in the editor) opens Pattern Edit Config — `@stock @build-verified`
- F2-F2 remembers the chosen pattern length for new patterns — `@shipped @build-verified`
- A freshly-entered empty pattern uses the remembered length — `@shipped @build-verified`

**How it does it:** **Key procs:** `Glbl_F2`, `NewPattern_ApplyDefaultLength`, `DefaultNewPatternLength`, `D_SaveDirectoryConfiguration`, `O1_PEConfigList`

**Grade:** @build-verified ×4 · @shipped ×2 · @stock ×2

**Commits:** `fb47b32` Import code (upstream base: F2 + F2-F2 config) · `068648f` F2-F2 pattern length persists; M flag persists; IT.CFG ext block


<a id="f2-resize-tiles-pattern"></a>
## F2 pattern-length increase duplicates (tiles) the existing content

`features/f2-resize-tiles-pattern.feature` · [session](f2-resize-tiles-pattern.session.md)

**What it does:** As someone lengthening a pattern from the F2 config screen, I want the existing rows duplicated to fill the new length, So that growing 64 -> 128 (or 192) gives me repeats of my material to edit, not a block of empty rows I have to re-enter.

**Behaviour (6 scenarios):**

- 64 -> 128 duplicates the 64 rows once — `@shipped @build-verified @runtime-verified`
- 64 -> 192 duplicates the 64 rows twice — `@shipped @build-verified @runtime-verified`
- Non-multiple lengths get a partial final copy ("until the end") — `@shipped @build-verified @runtime-verified`
- Shrinking the pattern does not tile — `@shipped @build-verified`
- Scope is the F2 config path only — `@shipped @build-verified`
- The tiled buffer persists via the working-copy model — `@shipped @build-verified`

**How it does it:** **Key procs:** `PE_TilePatternToLength`, `Glbl_F2`, `PE_OrderList_ExtendPattern`, `NumberOfRows`, `MaxRow` · **Source files:** `IT_G.ASM`, `IT_PE.ASM`

**Grade:** @build-verified ×6 · @runtime-verified ×3 · @shipped ×6

**Commits:** `05c70c9` F2 pattern-length increase tiles content instead of blank rows


<a id="f3-sample-list"></a>
## User Presses F3 (Sample List)

`features/f3-sample-list.feature`

**What it does:** As someone working with raw samples, I want F3 to open the sample list and Ctrl-F3 to reach the disk library, And I want previewing a sample in the loader to NOT kill the playing song, So that sample work never silences the tune I'm building it for.

**Behaviour (5 scenarios):**

- F3 opens the sample list — `@stock @build-verified`
- Ctrl-F3 opens the disk Sample Library from anywhere — `@stock @build-verified`
- Previewing a sample in the loader does not stop the song — `@shipped @build-verified`
- MIDI transport bytes can't restart the song mid-load — `@shipped @build-verified`
- Shift-Enter bulk sample load is guarded the same way — `@shipped @build-verified`

**How it does it:** **Key procs:** `Glbl_F3`, `Glbl_Ctrl_F3`, `MIDISyncLoaderSuppress`, `MIDI_SetLoaderSuppress`, `MIDI_ClearLoaderSuppress`, `Music_SilenceSampleVoices`, `D_PreLoadSampleWindow`, `LSWindow_ShiftEnter` · **Source files:** `IT_I.ASM`

**Grade:** @build-verified ×5 · @shipped ×3 · @stock ×2

**Commits:** `fb47b32` Import code (upstream base: F3 sample list, Ctrl-F3 library) · `a44c41b` Music_SilenceSampleVoices: keep playback alive across (re)loads · `64fa1ce` F3 loader keyjazz hang fix: suppress MIDI sync during LoadSample · `ec91331` F3 loader keyjazz: instrument LoadSample + PlaySample w/ VRAM markers


<a id="f4-instrument-list"></a>
## User Presses F4 (Instrument List)

`features/f4-instrument-list.feature`

**What it does:** As someone shaping instruments (envelopes, NNA, MIDI), I want F4 to open the instrument editor and repeated F4 to cycle its tabs, And Ctrl-F4 to reach the disk instrument library, So that all four envelope/MIDI tabs of an instrument are reachable from one key.

**Behaviour (4 scenarios):**

- F4 opens the instrument editor — `@stock @build-verified`
- Pressing F4 again cycles the instrument tabs — `@stock @build-verified`
- Ctrl-F4 opens the disk Instrument Library from anywhere — `@stock @build-verified`
- The per-instrument MIDI-In Channel is edited on the Pitch tab — `@shipped @build-verified`

**How it does it:** **Key procs:** `Glbl_F4`, `Glbl_Ctrl_F4`, `I_SelectScreen`, `InstrumentScreenTable`, `InstrumentMIDIInChannel`

**Grade:** @build-verified ×4 · @shipped ×1 · @stock ×3

**Commits:** `fb47b32` Import code (upstream base: F4 instrument list + tab cycle) · `10c837b` per-instrument MIDI-In channel field (hdr 1Fh) on the Pitch tab


<a id="midi-in-multitimbral"></a>
## Multitimbral MIDI-In

`features/midi-in-multitimbral.feature` · [session](midi-in-multitimbral.session.md)

**What it does:** As a musician driving the DOS PC from an external MIDI source, I want incoming notes on MIDI channels 01-16 to each trigger their own Impulse Tracker instrument live, So that Impulse Tracker becomes a 16-part sampler-synth, even while the transport is stopped.

**Behaviour (9 scenarios):**

- Output MIDI fields are independent of the input field — `@stock @shipped @build-verified`
- Each instrument can claim an incoming MIDI channel — `@shipped @build-verified`
- First Shift-F4 maps current samples to MIDI-In 01-16 — `@shipped @build-verified`
- Second Shift-F4 replicates 01-16 across six banks (96 instruments) — `@shipped @build-verified`
- Third Shift-F4 resets the six banks back to one 01-16 set — `@shipped @build-verified`
- An incoming note on channel N triggers the matching instrument — `@shipped`
- Channel 1 note entry is unchanged when the router is off — `@shipped`
- The router on/off switch lives on the Shift-F1 MIDI screen — `@shipped @build-verified`
- Polyphony per channel — `@todo`

**How it does it:** **Key procs:** `Music_CreateMIDIInInstruments`, `Music_ExpandMIDIInTo96`, `Music_ResetMIDIInTo16`, `MCMI_BuildSlot`, `Music_GetMIDIMultiBanks`, `Music_GetMIDIMultiEnable`, `Music_SetMIDIMultiEnable`, `MIDIMultiEnable`, `MIDIMultiBanks`, `Glbl_Shift_F4`, `Glbl_MIDIMulti_Toggle`, `MIDIMulti_Route`, `MMR_FindInst`, `MIDIMultiToggleButton`, `O1_ConfirmCreateMIDIIn`, `InstrumentMIDIInChannel` · **Source files:** `IT_MUSIC.ASM`, `IT_OBJ1.ASM`, `IT_G.ASM`, `IT_K.ASM`, `IT_I.ASM`

**Grade:** @build-verified ×6 · @shipped ×8 · @stock ×1 · @todo ×1

**Commits:** `b38dbcdee53d,` 2026-06-03; "claude --resume 1fa213d0-83aa-4fc1-a8fb-b38dbcdee53d") · `10c837b` per-instrument MIDI-In channel (hdr 1Fh) + Shift-F4 batch v1 · `7e3620a` live any-screen note router (MIDIMulti_Route) · `2dac7d5` Shift-F4 made a toggle (MIDIMultiEnable can be turned off) · `b5a0c66` Shift-F4 gated to Instrument mode <- SUPERSEDED by 8c32fd2 · `8c32fd2` 3-state Shift-F4 cycle + Shift-F1 router toggle + gate removed


<a id="midi-realtime-sync"></a>
## External MIDI Real-Time Sync

`features/midi-realtime-sync.feature` · [session](midi-realtime-sync.session.md)

**What it does:** As a musician slaving the DOS PC to an external sequencer or drum machine, I want MIDI System Real-Time messages to drive Impulse Tracker's transport and tempo, So that pressing play on the master device starts, stops, and clocks IT in time with the rest of the rig.

**Behaviour (11 scenarios):**

- Real-Time bytes are dispatched without disturbing running status — `@shipped @build-verified`
- 0xFA Start plays the song from the top — `@shipped @build-verified`
- 0xFC Stop halts playback — `@shipped @build-verified`
- 0xFB Continue currently behaves as Start (known v1 limitation) — `@shipped @build-verified`
- 0xFB Continue resumes from the last-known order/row — `@todo`
- 0xF8 Clock derives IT tempo from the master at 24 PPQ — `@shipped @build-verified`
- MIDI Transport can be switched off, swallowing FA/FB/FC — `@shipped @build-verified`
- MIDI Sync (clock) can be switched off independently, ignoring F8 — `@shipped @build-verified`
- Loader keyjazz suppresses transport re-entry — `@shipped @build-verified`
- Sound drivers pass F8-FF through to MIDISend — `@shipped @build-verified`
- The MIDI Monitor shows live Real-Time byte counters — `@shipped @build-verified`

**How it does it:** **Source files:** `IT_K.ASM`, `SoundDrivers/*.ASM`

**Grade:** @build-verified ×10 · @shipped ×10 · @todo ×1

**Commits:** `ec42bd1` 2026-04-23 FA/FB/FC start/continue/stop dispatch in MIDISend · `03b0a6d` 2026-05-01 F8 Clock 0xF8 external tempo sync (24 PPQ) · `0a82cb3` 2026-05-01 F8 Clock enable flag (default off) + delta sanity check · `ad5d840` 2026-05-04 MIDI Sync default ON + Alt-F12 toggle <- SUPERSEDED by 7163709 · `7163709` 2026-05-04 toggle moved from Alt-F12 to Shift-F1 MIDI screen button · `95f628a` 2026-05-04 MIDI Monitor: FA/FB/FC/F8 byte counters on Shift-F1 · `4ebf849` 2026-05-04 14 drivers (SB16/ES/AWE32/GOLD16) stop filtering F8-FF · `78fb72d` 2026-05-04 GUSMIXDR + IWDRV stop filtering F8-FF (the last 2) · `731e168` 2026-05-18 independent MIDI Transport (FA/FB/FC) gate


<a id="multi-wav"></a>
## Multi-WAV render

`features/multi-wav.feature` · [session](multi-wav.session.md)

**What it does:** As someone bouncing a tune to stems or a mix, I want to render the current pattern per channel, or the whole song as one WAV or as per-channel stems, So that I can take Impulse Tracker output into another DAW — NOTE: this whole feature is shipped but NOT yet runtime-tested (see header).

**Behaviour (5 scenarios):**

- Shift-Alt-M renders the current pattern per non-empty channel — `@shipped @build-verified @runtime-untested`
- F10 "WAV" renders the whole song to a single WAV — `@shipped @build-verified @runtime-untested`
- F10 "MWAV" renders the whole song as per-channel stems — `@shipped @build-verified @runtime-untested`
- The Shift+Alt keymap path exists (this part IS structural) — `@shipped @build-verified`
- WHAT WOULD VERIFY THIS CARD (the test that has not been run) — `@runtime-untested`

**How it does it:** **Key procs:** `PEFunction_StartMultiWAVKey`, `Music_StartMultiWAV`, `Music_StartFullSongWAV`, `Music_StartFullSongMWAV`, `K_TranslateCondition11`, `PE_ChannelIsEmpty` · **Source files:** `IT_PE.ASM`, `IT_MUSIC.ASM`, `IT_K.ASM`

**Grade:** @build-verified ×4 · @runtime-untested ×4 · @shipped ×4

**Commits:** `9fb5ac1` Multi-WAV + F10 MWAV + F10 WAV + Shift+Alt keymap condition


<a id="multitimbral-instrument-play-dots"></a>
## F4 instrument-list play dots in multitimbral Sample mode

`features/multitimbral-instrument-play-dots.feature` · [session](multitimbral-instrument-play-dots.session.md)

**What it does:** As someone playing a multitimbral MIDI rig into IT with the song in Sample mode, I want the F4 Instrument List to show live play dots while notes sound, just like the F3 Sample List already does, So that I can see which routed instruments are active without switching to the sample screen.

**Behaviour (5 scenarios):**

- Stock IT hid the F4 dots whenever instrument mode was off — `@shipped @build-verified @runtime-untested`
- With the router on, F4 shows play dots even in Sample mode — `@shipped @build-verified @runtime-untested`
- Normal Sample mode (router off) is unchanged — `@shipped @build-verified`
- Instrument mode still shows dots exactly as before — `@stock @build-verified`
- The dot row is the routed instrument, not a sentinel — `@shipped @build-verified`

**How it does it:** **Key procs:** `I_ShowInstrumentPlay`, `I_ShowSamplePlay`, `Music_GetInstrumentMode`, `Music_GetMIDIMultiEnable`, `MIDIMulti_Route` · **Source files:** `IT_I.ASM`

**Grade:** @build-verified ×5 · @runtime-untested ×2 · @shipped ×4 · @stock ×1

**Commits:** `478b638` show F4 instrument-list play dots in multitimbral Sample mode


<a id="no-samples-to-instruments-envelope-retention"></a>
## F12 Samples->Instruments uses upstream clear+remap (no envelope retention)

`features/no-samples-to-instruments-envelope-retention.feature` · [session](no-samples-to-instruments-envelope-retention.session.md)

**What it does:** As someone who needs a NON-CRASHING tracker above all, I want F12 "Initialise Instruments? = YES" to do exactly what upstream IT2.15 does -- clear all instruments and rebuild a clean sample-name + 120-note keymap -- with NO attempt to preserve drawn envelopes across the flip, So that nothing in the load/convert path can ever feed garbage instrument slots to the envelope renderer and hard-crash IT (EMM386 #12).

**Behaviour (5 scenarios):**

- Initialise Instruments = YES does the upstream clear + remap — `@stock @build-verified @runtime-untested`
- The envelope-retention feature and its IMPI checker are gone — `@build-verified`
- Shift-Enter bulk-load can no longer feed the crash class — `@build-verified`
- The I_MapEnvelope MaxNode<=25 clamp stays as defensive insurance — `@stock @build-verified`
- (guardrail) Do not re-introduce envelope retention without HW verify — `@todo`

**How it does it:** **Key procs:** `F_SetControlInstrument`, `Music_InstrumentIsReal`, `Music_ClearAllInstruments` · **Source files:** `IT_F.ASM`, `IT_DISK.ASM`, `IT_I.ASM`

**Grade:** @build-verified ×4 · @runtime-untested ×1 · @stock ×2 · @todo ×1

**Commits:** `d8ec842` (added) F12 Samples->Instruments preserves drawn envelopes · `b5a0c66` (PR #2, removed) revert envelope preservation -> upstream clear+remap · `c2094e6` a44a607 9a1142c (PR #3, re-added) IMPI-gated keep-envelopes policy


<a id="sample-amplify-keeps-playback"></a>
## Sample Amplify keeps the song playing

`features/sample-amplify-keeps-playback.feature` · [session](sample-amplify-keeps-playback.session.md)

**What it does:** As a musician tweaking a sample's level while a tune is running, I want pressing Alt-M (Amplify / normalize) and confirming it to scale the sample WITHOUT stopping playback, So that I can hear the change in context and keep my flow, instead of the whole song cutting out every time I amplify a sample.

**Behaviour (9 scenarios):**

- Amplifying a sample mid-playback does not stop the song — `@shipped @build-verified @runtime-verified`
- Alt-M Maximize/Normalize during playback keeps playing through OK/Process — `@shipped @build-verified @runtime-verified`
- REGRESSION (reported 2026-06-03) - Alt-M still stopped F6 playback — `@runtime-verified`
- Alt-M on the Sample List is the Amplify gesture — `@stock @build-verified`
- The dialog pre-fills the no-clip (normalize) amplification — `@stock @build-verified`
- Only the amplified sample's voices are silenced, not all channels — `@shipped @build-verified`
- The mixer never reads the sample while it is being rewritten — `@shipped @build-verified`
- AX (the sample number) survives the silence call — `@shipped @build-verified`
- Other Sample-List operations that still stop the song are untouched — `@stock @build-verified`

**How it does it:** **Key procs:** `I_AmplifySample`, `Music_SilenceSampleVoices`, `Music_Stop`, `Music_GetSampleLocation`, `Music_SoundCardLoadSample`, `Music_SoundCardLoadAllSamples` · **Source files:** `IT_I.ASM`, `IT_MUSIC.ASM`

**Grade:** @build-verified ×8 · @runtime-verified ×3 · @shipped ×5 · @stock ×3

**Commits:** `e5e5c38` Sample Amplify (Alt-M) no longer stops the song (entry: Music_Stop


<a id="scrolllock-follow-from-lists"></a>
## User Presses Scroll Lock while in F3 (Sample List) or F4 (Instrument List)

`features/scrolllock-follow-from-lists.feature` · [session](scrolllock-follow-from-lists.session.md)

**What it does:** As someone auditioning samples/instruments against a playing song, I want Scroll Lock on the list screens to drop me into the Pattern Editor with Pattern Follow Mode already on, So that one key takes me from "browsing a slot" to "watching the cursor follow playback" without a separate F2 then Scroll Lock.

**Behaviour (7 scenarios):**

- Scroll Lock inside the Pattern Editor still just toggles Follow Mode — `@stock @build-verified`
- Scroll Lock in the Sample List opens the Pattern Editor with Follow Mode on — `@shipped @build-verified @runtime-untested`
- Scroll Lock in the Instrument List does the same — `@shipped @build-verified @runtime-untested`
- Ctrl-F on the Sample or Instrument List does the same as Scroll Lock — `@shipped @build-verified @runtime-untested`
- Follow Mode is forced ON, never toggled off, from the lists — `@shipped @build-verified`
- The handler hands Glbl_F2 the dispatcher's own DS (no segment damage) — `@shipped @build-verified`
- (not built) Scroll Lock / Ctrl-F from other screens (Order list F11, Song vars F12) — `@todo`

**How it does it:** **Key procs:** `PE_ScrollLockFollow`, `TracePlayback`, `PEFunction_ToggleTrace`, `Glbl_F2`, `K_SetScrollLock`, `SampleGlobalKeyList`, `InstrumentGlobalKeyList` · **Source files:** `IT_OBJ1.ASM`

**Grade:** @build-verified ×6 · @runtime-untested ×3 · @shipped ×5 · @stock ×1 · @todo ×1

**Commits:** `91dfc0b` Scroll Lock on F3/F4 lists -> Pattern Editor + Follow Mode


<a id="shift-enter-bulk-load-from-module"></a>
## Shift-Enter Load from Sample List (bulk-load a module's samples)

`features/shift-enter-bulk-load-from-module.feature` · [session](shift-enter-bulk-load-from-module.session.md)

**What it does:** As someone who wants a module's instruments fast, I want Shift-Enter on a module file in the Load Sample browser to load every sample in that module into consecutive slots, one per row, keeping each sample's original name and loop mode, So that I can lift a whole module's sample set in a single keystroke.

**Behaviour (3 scenarios):**

- Shift-Enter on a module bulk-loads its samples into consecutive slots — `@shipped @build-verified @runtime-untested`
- Loaded samples keep their original module names and loop modes — `@shipped @build-verified @runtime-untested`
- REGRESSION (reported 2026-06-03) - Shift-Enter on a .MOD hard-hangs IT

**How it does it:** **Key procs:** `LSWindow_ShiftEnter`, `LoadMODSamplesInModule`, `LSViewWindow_Enter2`, `LoadSample`, `ExitLibraryDirectory`, `SamplesInModule`, `SampleCacheFileComplete`

**Grade:** @build-verified ×2 · @runtime-untested ×2 · @shipped ×2

**Commits:** `f541198` Shift-Enter on module row = bulk-load all samples (original feature)


<a id="shift-enter-load-from-sample-list"></a>
## Shift-Enter Load from Sample List

`features/shift-enter-load-from-sample-list.feature` · [session](shift-enter-load-from-sample-list.session.md)

**What it does:** As a user building a song from an existing module's samples, I want Shift-Enter on a module to pull in all its samples at once, So that I get every sample, named and loop-configured as in the source.

**Behaviour (4 scenarios):**

- Shift-Enter on a module loads its samples one per row — `@shipped`
- Loaded samples keep their original names and loop modes — `@shipped`
- In Instrument mode each sample is also auto-assigned to an instrument — `@shipped`
- Samples->Instruments envelope retention does NOT clash with this — `@shipped`

**How it does it:** **Source files:** `IT_DISK.ASM`, `IT_F.ASM`, `IT_MUSIC.ASM`

**Grade:** @shipped ×4


<a id="shift-f4-enters-instrument-mode"></a>
## Shift-F4 to enable Multitimbral mode also switches Samples -> Instruments

`features/shift-f4-enters-instrument-mode.feature` · [session](shift-f4-enters-instrument-mode.session.md)

**What it does:** As someone enabling live multitimbral MIDI-in, I want confirming "Yes, enter Multitimbral Mode" to ALSO move me from Sample mode into Instrument mode (since the 16 things created are instruments), So that the instruments I just made are immediately the active, playable mode.

**Behaviour (4 scenarios):**

- From Sample mode, Shift-F4 + confirm enters Instrument mode with 16 instruments — `@shipped @build-verified @runtime-untested`
- The mode switch is a direct flag set, NOT the F12 clear/remap path — `@shipped @build-verified`
- Declining the prompt changes nothing — `@shipped @build-verified`
- (verify live) cursor + playback survive the mode switch — `@runtime-untested`

**How it does it:** **Key procs:** `Glbl_Shift_F4`, `Music_CreateMIDIInInstruments`, `Glbl_F4` · **Source files:** `IT_G.ASM`

**Grade:** @build-verified ×3 · @runtime-untested ×2 · @shipped ×3

**Commits:** `8c32fd2` Shift-F4 3-state cycle (the create dispatcher this extends)


<a id="wav-render-quicksave"></a>
## WAV Quicksave render filename

`features/wav-render-quicksave.feature` · [session](wav-render-quicksave.session.md)

**What it does:** As a musician rendering patterns to disk for use in another app, I want each single-pattern Quicksave render to come out as a real, time-stamped .WAV file (LL<HHMMSS>.WAV), So that the files sit time-sorted in the Quicksave folder and drag straight into another app, instead of clobbering each other or carrying a fake .000-style extension.

**Behaviour (8 scenarios):**

- Shift-Right at the order-list right edge renders to Quicksave only — `@shipped @build-verified @runtime-untested`
- Plain Right at the same edge renders AND auto-imports — `@shipped @build-verified @runtime-untested`
- A single-pattern Quicksave render is named by wall-clock time — `@shipped @build-verified @runtime-untested`
- The prefix is a static "LL" (Lackluster), not derived from the song — `@shipped @build-verified`
- The extension is a real .WAV, not the 3-digit pattern number — `@shipped @build-verified @runtime-untested`
- The auto-import opens the exact file WAVDRV wrote — `@shipped @build-verified @runtime-untested`
- Multi-WAV, full-song, and user-named renders keep <PFX><NNNN> — `@shipped @build-verified`
- Two renders in the same second overwrite

**How it does it:** **Key procs:** `WAV_BuildTimestampBasename`, `WAV_Store2Dec`, `Music_ToggleWAVRender`, `Music_ImportRenderedPattern`, `PE_OrderList_RightDispatch`, `PE_OrderList_RenderDispatch`, `PE_OrderList_RenderQuicksave`, `PE_OrderList_GDispatch`, `CopyFileName` · **Source files:** `IT_PE.ASM`, `IT_MUSIC.ASM`, `SoundDrivers/WAVDRV.ASM`

**Grade:** @build-verified ×7 · @runtime-untested ×5 · @shipped ×7

**Commits:** `be595b2` WAV render: .000 (3-digit pattern number) -> real .WAV extension · `74c3fe8` single-pattern Quicksave render named LL<HHMMSS>.WAV by the clock · `3fd46da` (generative-seed preamble)


<a id="wav-render-reentry-guard"></a>
## WAV render re-entry guard -- a second render gesture mid-render stops cleanly

`features/wav-render-reentry-guard.feature` · [session](wav-render-reentry-guard.session.md)

**What it does:** As a musician who fired a pattern-to-WAV render and then pressed a render key AGAIN before it finished (e.g. Right then Shift-Right at the F11 order-list right edge), I want that second press to halt the in-flight render cleanly -- like Esc -- and let the file finish writing to the Quicksave folder, So that IT.EXE does not glitch/wedge with no way out, and I do not lose the recording or have to kill the tracker.

**Behaviour (7 scenarios):**

- The old behaviour -- a second gesture tore the driver down mid-playback — `@shipped @build-verified`
- Right starts the render, Shift-Right during it halts and finalizes — `@shipped @build-verified @runtime-verified`
- WAV_FinalizeRequest tells the genuine finalize apart from a re-press — `@shipped @build-verified`
- The genuine auto-finalize is unchanged -- still leaves + imports — `@shipped @build-verified`
- Early-stop reuses the existing safe finalize, not a new teardown — `@shipped @build-verified @runtime-verified`
- All render entry points share the one central guard — `@shipped @build-verified`
- Multi-WAV sweep finalize and chaining are untouched — `@shipped @build-verified`

**How it does it:** **Key procs:** `Music_ToggleWAVRender`, `WAV_AlreadyActive`, `WAV_FinalizeRequest`, `WAV_LeaveMode`, `Music_Poll`, `Music_Stop`, `PE_OrderList_RightDispatch`, `PE_OrderList_RenderDispatch`, `PE_OrderList_RenderQuicksave`, `PE_OrderList_GDispatch` · **Source files:** `IT_PE.ASM`, `IT_MUSIC.ASM`

**Grade:** @build-verified ×7 · @runtime-verified ×2 · @shipped ×7

**Commits:** `c9ff6b9` guard re-entrant WAV render gesture; second press early-stops to


---

## Meta / session cards

These document the report-card *process* itself, not a tracker behaviour.

- **Day 2026-06-03 — what changed in impulse-tracker** — `features/day-2026-06-03.feature`
- **Conversation 2026-06-03 — what we accomplished** — `features/session-2026-06-03-multitimbral-and-whitelabel.feature` · [session](session-2026-06-03-multitimbral-and-whitelabel.session.md)
- **A session changes a codespace** — `features/session-changes-codespace.feature` · [session](session-changes-codespace.session.md)

