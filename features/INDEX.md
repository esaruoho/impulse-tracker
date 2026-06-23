# Feature Index — the commit ↔ feature map

> The rollup page for the report-card system (see `../GHERKIN-FEATURE-WIKI-PATTERN.md`).
> Each fork feature is a `.feature` card; each card owns a set of commits. This index
> is the two-way join between `git log` (immutable source of truth) and the cards
> (compounding understanding).
>
> **Forward** (feature → commits): read the card's `Commit log` header + per-scenario
>   `# cite: ... commit XXXX`.
> **Reverse** (commit → feature): `grep -rl <hash> features/`.
> **Audit**: every fork commit below should resolve to exactly one card. A commit with
>   no card is the work surface — bookkeeping not yet done, or a feature not yet carded.
>
> Card status: ✅ carded · 🟡 partial · ⬜ no card yet
>
> **Test status is GENERATED, not hand-typed.** See `features/STATUS.md` — it is
> computed from each card's `@grade` tags by `features/gen-status.py` (the
> pre-commit hook regenerates it on any card change). Do NOT hand-edit
> build/runtime/hardware status into this index; change the card's tags and the
> table follows. This index stays the curated commit↔feature *map*; STATUS.md is
> the derived test matrix.

---

## Carded features

### ✅ ctrl-o-empty-orderlist-crash.feature
Two crash fixes for the single-pattern WAV-render gestures (Ctrl-O / right-arrow / Shift-right). Build-verified, HW-untested.
- `128ab04` bound-check Music_GetPattern — empty-order-list reboot (invalid pattern → wild pointer)
- `4041e66` set StopEndOfPlaySection for the render — order-list render hang (looped forever)

### ✅ midi-in-multitimbral.feature
Live 16-part sampler; per-instrument MIDI-In channel (hdr 1Fh); Shift-F4 3-state cycle; Shift-F1 router toggle.
- `10c837b` per-instrument MIDI-In channel + Shift-F4 batch v1
- `7e3620a` live any-screen note router (MIDIMulti_Route)
- `2dac7d5` Shift-F4 made a toggle
- `b5a0c66` Shift-F4 gated to Instrument mode *(superseded by 8c32fd2)*
- `8c32fd2` 3-state cycle + Shift-F1 toggle + gate removed
- `7f5b2ff` the card itself + source back-links

### 🟡 wav-render-quicksave.feature
Ctrl-O render → auto-import; Shift-Ctrl-O no-import; Quicksave routing; LL\<HHMMSS\>.WAV naming. LL naming + .WAV extension runtime-verified (2026-06-04, Esa); auto-import path still runtime-untested.
- `35732c3` Ctrl-O renders current pattern (P1)
- `089119a` Ctrl-O toggles ITWAV.DRV render mode (P2a)
- `af03f96` Ctrl-O auto-imports rendered pattern (P2.5+P3)
- `e4c9b4a` deep-dive findings doc for P2/P3
- `1d7910e` `09d7e7d` `bb5e5ea` `9ed42ed` `64b853b` `4d5e9da` `3a626b4` `e3f5815` `f136a7b` `b0690a4` `ce3fb79` `9bd18d1` `81c78aa` `d13a849` `0c02662` P3 hardening chain
- `3537c0d` Ctrl-O hang VRAM markers
- `4ae100e` `b72f541` `f401e39` Ctrl-O robustness (header check, logging, 0-byte cleanup)
- `a98a37c` Shift-Ctrl-O no-import + 15s marker hold
- `18e8da4` Ctrl-O diagnostics / dispatcher trace
- `97712ce` render to Quicksave folder + import open-fail fix
- `6464e15` Quicksave folder: Alt-W save / Shift-Alt-W memorize
- `7fd1abc` F12 Quicksave directory row
- `be595b2` .WAV extension *(carded)*
- `74c3fe8` LL\<HHMMSS\>.WAV naming *(carded)*
- `34b725d` `054f1f0` gitignore rendered samples / repo-root IT.CFG

### ✅ wav-render-keep-playback.feature  (+ .session.md, full triad)
WAV render no longer kills the groove: a single-PATTERN render runs faster-than-realtime (tight Music_Poll loop; WAVDRV mixes on demand) = a brief freeze not a realtime silence; and if a song was playing, an incoming MIDI clock/transport after the render RESUMES it from the saved order/row (Music_ResumeAfterRender). True-simultaneous = @known-limit (one engine). Build-verified, runtime+hw-untested.
- `702727c` faster-than-realtime pattern render + MIDI-clock resume after
- Card + session authored same session

### ✅ wav-render-reentry-guard.feature  (+ .session.md, full triad)
A second render gesture mid-render (Right then Shift-Right at the F11 order-list right edge; or a second Ctrl-O/Ctrl-G/Shift-G) now early-stops like Esc and finalizes to Quicksave instead of re-entering the teardown and wedging IT. New `WAV_FinalizeRequest` discriminator. Build-verified, runtime-verified (2026-06-04, Esa).
- `c9ff6b9` guard re-entrant WAV render gesture; second press early-stops to Quicksave
- Card + session authored same session; card-commit hash follows `c9ff6b9`

---

## Carded features (continued)

### ✅ midi-realtime-sync.feature  (+ .session.md, RESULT block, source back-links)
External transport: FA/FB/FC Start/Stop/Continue, F8 Clock tempo sync, driver F8–FF passthrough, Sync/Transport toggles, MIDI Monitor.
- `ec42bd1` start/stop song on MIDI System Real-Time messages
- `ad5d840` MIDI Sync default ON + Alt-F12 toggle *(superseded by 7163709)*
- `7163709` move toggle to Shift-F1 MIDI screen
- `95f628a` MIDI Monitor RT byte counters
- `4ebf849` drivers stop filtering F8–FF (14 drivers)
- `78fb72d` GUSMIXDR + IWDRV stop filtering F8–FF (last 2 = 16 total)
- `03b0a6d` `0a82cb3` MIDI Clock 0xF8 external tempo sync + enable flag
- `731e168` MIDI Transport toggle (independent FA/FB/FC gate)

### ✅ midi-out-stop-on-f8.feature  (+ .session.md, full triad)
OUTBOUND: F8 (Stop) also transmits a single 0FCh MIDI Stop, gated by a Shift-F1 toggle, persisted across restarts (IT.CFG ForkExtConfig +3). One transmit site (Glbl_F8) means no feedback loop is structurally possible. Build-verified; outbound byte hw-untested; persistence + button runtime-untested.
- `67cdb60` Glbl_F8 transmits 0FCh out via Music_SendMIDIStop, gated by MIDIStopOnF8Enable (Shift-F1 toggle); IT_K.ASM flag+toggle+Far query, IT_OBJ1.ASM button
- `222962f` persist toggle across restarts: PE_ForkExtConfig +3 force-off mirror byte (0=ON default), synced in D_InitDisk / D_SaveDirectoryConfiguration; MIDI_SetF8StopEnable setter

### ✅ scrolllock-follow-from-lists.feature  (+ .session.md, full triad)
Scroll Lock — AND Ctrl-F — on F3 Sample List / F4 Instrument List force-enables Pattern Follow Mode and opens the Pattern Editor (= F2). Build-verified; Ctrl-F on F3/F4 runtime-verified (2026-06-04, Esa).
- `91dfc0b` Scroll Lock on F3/F4 lists → open Pattern Editor + force Follow Mode (IT_PE.ASM `PE_ScrollLockFollow` + IT_OBJ1.ASM two keylist entries, 146h on Sample/Instrument lists)
- `8c85035` backfill RESULT hash 91dfc0b into the card + session
- `97b28e9` Ctrl-F (06h) added as a 2nd trigger on F3/F4 → same PE_ScrollLockFollow handler

### ✅ shift-enter-bulk-load-from-module.feature  (+ .session.md, full triad)
Sample-loader browser: Shift-Enter on a module row bulk-loads all its samples into
consecutive slots (names + loop modes preserved). Carded while fixing a .MOD
hard-hang (missing loader-cache finalisation). Build-verified, runtime-untested.
- `f541198` Shift-Enter on module row = bulk-load all samples (original)
- *(this session)* MOD hard-hang fix: finalise loader cache before loop/teardown

### ✅ sample-amplify-keeps-playback.feature  (+ .session.md, full triad)
Sample Amplify (Alt-M, the "normalize" gesture) no longer stops the song — only the amplified sample's voices are silenced (Music_SilenceSampleVoices), every other channel keeps playing. Same pattern as loader-keyjazz-hang. Build-verified, runtime-verified (2026-06-04, Esa).
- `e5e5c38` Sample Amplify (Alt-M) no longer stops the song
- Card + session authored same session

### ✅ multitimbral-instrument-play-dots.feature  (+ .session.md, full triad)
F4 Instrument List now shows live play dots during multitimbral MIDI-in playback in Sample mode — I_ShowInstrumentPlay's instrument-mode gate now also proceeds when Music_GetMIDIMultiEnable is set, so F4 mirrors F3. Build-verified, runtime-untested.
- `478b638` show F4 instrument-list play dots in multitimbral Sample mode
- Card + session authored same session

### ✅ f2-resize-tiles-pattern.feature  (+ .session.md, full triad)
Increasing the row count on the F2 Pattern-Edit-Config now DUPLICATES (tiles) the existing rows to fill the new length (64→128 = 2 copies, 64→192 = 3, partial final copy on non-multiples) instead of appending blank rows. New PE_TilePatternToLength helper. Build-verified, runtime-verified (2026-06-04, Esa).
- `05c70c9` F2 pattern-length increase tiles content instead of blank rows
- Card + session authored same session

### ✅ f2-pattern-editor.feature
F2 enters the Pattern Editor; a second F2 opens Pattern Edit Config; the chosen row count is remembered (DefaultNewPatternLength, persisted to IT.CFG). Stock navigation + fork default-length persistence. Build-verified.
- `068648f` F2-F2 default pattern length persists + M flag (IT.CFG ext block)
- Stock F2/F2 behaviour verified IT_G.ASM:224-298

### ✅ shift-enter-load-from-sample-list.feature
User-facing spec of Shift-Enter on a module row in the Sample List: samples load one per row with original names AND loop modes (+ instrument auto-assign in Instrument mode). Sibling impl/regression card: shift-enter-bulk-load-from-module.feature.
- `f541198` Shift-Enter on module row = bulk-load all samples
- `32e080c` .MOD hard-hang fix (loader-cache finalisation)

### ✅ no-samples-to-instruments-envelope-retention.feature  (+ .session.md, full triad) — a REMOVAL card
F12 Samples→Instruments back to upstream clear+remap; the envelope-retention feature (added → PR#2 removed → PR#3 re-added) is reinstated-removed for good. Brittlest feature / EMM386 #12 crash class. Build-verified.
- `d8ec842` added envelope preserve → `b5a0c66` (PR#2) removed → `c2094e6`/`a44a607`/`9a1142c` (PR#3) re-added
- *(this session)* reinstate PR#2's removal as de-facto: restored IT_F.ASM to b5a0c66, deleted Music_InstrumentIsReal

### ✅ shift-f4-enters-instrument-mode.feature  (+ .session.md, full triad)
Shift-F4 "Yes, enter Multitimbral Mode" now also flips Sample→Instrument mode (direct flag set, NOT the F12 path) and shows the Instrument List; the 16 instruments mapped to samples 01-16 were already built by Music_CreateMIDIInInstruments. Build-verified, runtime-untested.
- `8c32fd2` Shift-F4 3-state cycle (dispatcher this extends)
- *(this session)* create-confirm → Or [songseg:2Ch],4 + Jmp Glbl_F4

### ✅ shift-f4-drumkit.feature  (+ .session.md, full triad)
Shift-F4's Create step ALSO auto-builds a drumkit at slot 99 (MIDI ch 10): note i → sample (i+1), C-0→01, C#0→02, … every sample slot mapped to a key at fixed C-5 pitch. Separate from the 01-16 set; expand-96/reset never touch slot 99. New MCMI_BuildDrumkit. Build-verified, runtime+hw-untested.
- `f94f63c` Shift-F4 also auto-builds a slot-99 drumkit (every sample → a key, ch 10)
- Card + session authored same session

### ✅ convey-test-runner.feature  (@tool; + .session.md, full triad)
The Convey conveyance layer carded as a unit: hwtest.py + test-impulse-tracker DISPLAY each unverified fork scenario to the human, capture works/failed(+note), and route a "works" back to `@hw-verified` in the card (HW-FAILURES.md for the rest). Host-side `@tool` — EXCLUDEd from STATUS/HARDWARE-TEST (no @hw floor). Carded retroactively after Esa flagged it wasn't "done the Convey way".
- `9ec40af` hwtest.py TUI · `e63518b` repo-anchored launcher
- Card + session this commit (the Convey-way fix)

### ✅ f6-play-from-order-list-row.feature  (+ .session.md, full triad)
F11 Order List: F6 LOOPS the pattern at the selected order row (PE_OrderListLoopPattern: Order→pattern→row count→Music_PlayPattern); F7 = "Playback from Cursor" = Music_PlayPartSong(selected Order, current Row). Gated on CurrentMode==11; stock elsewhere. Build-verified, runtime-untested. (First cut 8acb41f used Music_PlaySong — wrong, Esa corrected to loop.)
- `8acb41f` first cut: F6 = Music_PlaySong(Order) *(superseded)*
- `5b37353` F6 loops the selected order's pattern; F7 plays from order+current row
- Card + session authored same session

### ✅ pattern-length-beyond-200.feature  (+ .session.md)  [carded 2026-06-04]
Feasibility / negative-result card: 256- and 512-row patterns are blocked by the 64,000-byte PatternData segment (= 200 rows × 320 bytes/row exactly), 16-bit row offsets, and byte-width row fields. `@blocked-by-architecture`, source-cited. No code shipped.
- `6208e79` feasibility card — 256/512-row patterns blocked by 64KB segment

> The Convey gardener detector (`gardener.py` + the `convey-gardener` card/session)
> moved to its real home, the Convey repo (esaruoho/convey, 2026-06-05) — it is
> generic Convey tooling, not tracker work.

### ✅ note-cut-toggle.feature  (+ .session.md, full triad)  [carded 2026-06-04]
Note column: '1' stamps a note cut (^^^, 0FEh) as in stock IT, but pressing '1' on a cell that ALREADY holds ^^^ wipes it (NoteCutToggle checks [ES:DI], falls through to WipeNote with AL=NONOTE — same erase as '.'). Note-off and '.' unchanged. Build-verified, runtime-untested.
- `81e4819` '1' on a note cut toggles it off (NoteCutToggle)
- Card + session authored same session

### ✅ song-name-timestamp-default.feature  (+ .session.md, full triad)  [carded 2026-06-04]
A blank song is born named with its creation timestamp "YYYY-MM-DD HH:MM" (e.g. "2026-06-04 15:07"). F_SetTimestampSongName reads DOS date/time (Int 21h AH=2Ah/2Ch) and writes SongData:4 when the name's first byte is 0 (blank-guard — a loaded name is never clobbered). Called at IT.ASM startup (the boot song) and after F_NewSong blanks the name. Build-verified, runtime-untested.
- `87ad1dd` default blank song name to creation timestamp (YYYY-MM-DD HH:MM)
- Card + session authored same session

### ✅ undo-messaging.feature  (+ .session.md, full triad) — a @howto/TEACHING card
How undo steps get NAMED in the Ctrl-Backspace list (UndoBufferTypes table + PE_AddToUndoBuffer DI=type + PEFunction_DrawUndo lookup) AND the 4-step recipe to add a new named undo step. Documents the off-the-end-of-the-table garbage trap. Reference knowledge for the impulse-tracker skill.
- `3a3b7ff` add replicate undo labels (types 23/24) → `d938ff4` rename to "Replicate Track/Pattern Above"

## Uncarded features (the work surface)

> Status flipped in place 2026-06-03: entries below marked ✅ are now carded, and
> two are COVERED by an existing card. They'll migrate up to "Carded features" on
> the next structural tidy; only ⬜ entries are still genuinely uncarded.

### ✅ loader-keyjazz-hang.feature  (+ .session.md, full triad)  [carded 2026-06-06]
F3/F4 loader keyjazz no longer kills playback; Music_SilenceSampleVoices + MIDISyncLoaderSuppress. Build-verified, runtime/hw-untested.
- `a44c41b` Music_SilenceSampleVoices (keep playback alive across reloads)
- `ec91331` F3 loader keyjazz hang VRAM markers
- `64fa1ce` F3 loader keyjazz hang fix via MIDISyncLoaderSuppress

### ✅ alt-r-replicate.feature  (Paketti port; + .session.md, full triad)  [carded 2026-06-03]
Alt-R = Replicate at Cursor (tile rows-above-cursor downward; row 0 tiles row 0 down);
Shift-Alt-R keeps the original "clear track views". Build-verified; tiling runtime-untested.
- `d506486` Alt-R = Replicate at Cursor
- `aaada5e` Alt-R tile at row 0 + Shift-Alt-R = ClearViews

### ✅ f11-order-list-power-tools — COVERED BY f11-order-list.feature  (stale duplicate)
Already carded inside f11-order-list.feature, whose WATCH set is PE_OrderList_ClonePattern /
ExtendPattern / ToggleMuteWipe / ApplyMuteWipe / RenderDispatch / RenderQuicksave / GDispatch /
RightDispatch / LeftDispatch. No separate card needed; kept here as a pointer.
Ctrl-O/Shift-Ctrl-O/Ctrl-G/Shift-G render, Alt-D clone+insert+advance, Alt-E extend, M toggle, cursor-key edge gestures.
- `1a7aa16` render / clone / extend + mute-wipe toggle
- `90cfd04` cursor-key edge gestures + note-cut at row 0
- `6e15aa7` clone/extend crash fix
- `4eee4f8` clone auto-insert + runtime status *(shared with f12-pickers)*

### ✅ f12-directory-pickers — COVERED BY f12-song-variables.feature  (stale duplicate)
Already carded inside f12-song-variables.feature, whose WATCH set is D_PickModuleDir /
D_PickSampleDir / D_PickInstrumentDir / D_PickQuickSaveDir / D_PickDir_Common. No separate
card needed; kept here as a pointer.
Module/Sample/Instrument/Quicksave rows Enter-pickable via D_PickDir_Common.
- `8ca7078` F12 Module Directory Enter opens F9 picker
- `8f11aa6` translate '/' → '\' in F12 input fields
- `4eee4f8` F12 dir pickers *(shared with f11)*

### ✅ multi-wav.feature  (+ .session.md, full triad — RUNTIME-UNTESTED, the card says so)  [carded 2026-06-03]
Shift-Alt-M per-channel; F10 WAV (whole-song single) + MWAV (per-channel) buttons; K_TranslateCondition11 for Shift+Alt.
NOT runtime-tested: every behaviour scenario is @runtime-untested and the card carries a READ-FIRST banner
plus an explicit "what would verify this card" scenario. Only the K_TranslateCondition11 keymap fact is @build-verified.
- `9fb5ac1` Multi-WAV + F10 MWAV + F10 WAV + Shift+Alt keymap condition

### ✅ f2-pattern-editor-defaults — COVERED BY f2-pattern-editor.feature  (stale duplicate)
Already carded inside f2-pattern-editor.feature (WATCH: DefaultNewPatternLength
NewPattern_ApplyDefaultLength; commit 068648f). No separate card needed.
- `068648f` F2-F2 default pattern length persists + M flag persists (IT.CFG ext block)

### ✅ f4-f3-cursor-translate.feature  (+ .session.md, full triad)  [carded 2026-06-06]
F4 Instrument list ↔ F3 Sample list: carry the cursor selection across the two screens (Glbl_InstrumentToSample, note-60-first + scan-all). Build-verified, runtime/hw-untested.
- `9d626b0` F4→F3 cursor translation
- `672273b` F4→F3 translate: bounds + note-60-first then scan-all fallback


<!-- REMOVED: samples-to-instruments-envelope (reverted feature). A "here's what
     was removed" bucket is a tombstone, not a behaviour card — the feature map
     describes what works. The parked feature still lives in PR #3 + its project
     memory; it does not belong in the runnable-feature index. -->

<!-- SPLIT RULE (Esa, 2026-06-03): a feature must be small enough to be ONE
     runnable, screenshot-checkable unit. "navigation-and-persist" was a grab-bag
     of F2 / F3-F4 / F9 behaviours that can't be verified in a single screen, so
     it is split per UI surface. F2 Pattern Editor is its own feature; F4↔F3 is
     its own; F9 bulk-load is its own. Features may link to each other. -->


---

## Non-feature commits (infrastructure / docs / base) — carded as process, not behaviour

**build-infra**: `1fa031c` `be79b3c` `5bd73ed` `1c4ca74` `84c7e1b` `3e49ca3` `fc92c77` `1b2bcf1`
**release-workflow** (v2.354): `8d80eff` `62e6991` `141893b` `fe1df01` `c599007` `400ea5b` `e4fafa6` `2eb6088` `87cc192` `53fa15d`
**docs/skill**: `0afd402` `e3e6940` `16d89da` `2051b90` `06ac14a` `eaa34e2` `5260c3d` `0a9fa2d` + (uncommitted) `GHERKIN-FEATURE-WIKI-PATTERN.md`, this index
**backlog**: `ecc745b` `5ece809`
**upstream/base** (pre-fork + version stamp): `fb47b32` `10e9e50` `a7466b7` `f2c9da1` `04a5a9e` `a09c04f` `11f82a2` `7144cd1` `5fe2570` `b09e0ef` `58c44e4` `aa311f5` `7df9edf`

---

## Coverage today (updated 2026-06-03 — shared working tree; counts move as the
## parallel session cards more, so trust the ### markers above over this prose)
This session's reconciliation:
- **Newly carded:** ✅ alt-r-replicate (full triad) and ✅ multi-wav (full triad,
  **RUNTIME-UNTESTED** — the card states it outright, per Esa's instruction).
- **Reconciled as duplicates:** f11-order-list-power-tools is COVERED by
  f11-order-list.feature; f12-directory-pickers is COVERED by
  f12-song-variables.feature. No separate cards needed.
- **Still 🟡 partial:** wav-render-quicksave (core behaviour carded, but not every
  historical Ctrl-O commit has its own scenario, and it's runtime-untested).
- **Genuinely still ⬜ uncarded: NONE** (2026-06-06). The last three are resolved:
  loader-keyjazz-hang ✅ + f4-f3-cursor-translate ✅ carded; f2-pattern-editor-defaults
  COVERED-BY f2-pattern-editor.feature. Every behaviour-bearing commit now resolves to
  exactly one card — the audit is closed.

Reverse-lookup note: `rg`/ugrep skip untracked + git-ignored files by default, so a
freshly-written card won't resolve until committed (or use `grep -rlF <hash> features/`
/ `rg -F --no-ignore`). After commit, plain `grep -rl <hash> features/` works.
