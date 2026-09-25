# Report Card — WAV Quicksave render filename

> Source: `features/wav-render-quicksave.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As a musician rendering patterns to disk for use in another app, I want each single-pattern Quicksave render to come out as a real, time-stamped .WAV file (LL<HHMMSS>.WAV), So that the files sit time-sorted in the Quicksave folder and drag straight into another app, instead of clobbering each other or carrying a fake .000-style extension.

**Grades:** @build-verified × 10 · @hw-verified × 3 · @runtime-untested × 4 · @runtime-verified × 3 · @shipped × 10

**Scenarios: 12**


---


## 1. Shift-Right at the order-list right edge renders to Quicksave only

`@shipped @build-verified @runtime-verified @hw-verified`


- Given the F11 Order List is open
- And the cursor is on the right-most character of the 3-char order column
- When the user presses Shift-Right
- Then a WAV render of the active pattern starts
- And the file lands in the Quicksave folder with NO auto-import
- (Shift = render-to-Quicksave-only)

<sub>cite: IT_PE.ASM PE_OrderList_RightDispatch (line 2320) fires only at · -> PE_OrderList_RenderDispatch (2337): Shift held => ArmRenderNoImport</sub>


## 2. Plain Right at the same edge renders AND auto-imports

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the F11 Order List cursor on the right-most order-column character
- When the user presses Right (no Shift)
- Then the active pattern is rendered to the Quicksave folder
- And the rendered WAV is auto-imported as the next sample slot

<sub>cite: IT_PE.ASM PE_OrderList_RenderDispatch (2337): no Shift =></sub>


## 3. Shift-Right writes stereo WAV data when Stereo playback is enabled

`@shipped @build-verified @runtime-untested @hw-untested`


- Given Stereo playback is enabled in the song flags
- And the F11 Order List cursor is on the right-most order-column character
- When the user presses Shift-Right
- Then ITWAV.DRV writes a 2-channel 16-bit WAV file
- And mono mode still writes a 1-channel 16-bit WAV file

<sub>cite: IT_MUSIC.ASM Music_AutoDetectSoundCard (~8063) calls · SoundDrivers/WAVDRV.ASM compiles SetStereo, stereo mixing, and the</sub>


## 4. A single-pattern Quicksave render is named by wall-clock time

`@shipped @build-verified @runtime-verified @hw-verified`


- Given a single-pattern Quicksave render at 16:34:22
- Then the file is named LL163422.WAV
- And HHMMSS is the 24-hour DOS clock (hour, minute, second), zero-padded

<sub>cite: IT_MUSIC.ASM Music_ToggleWAVRender enter-mode gate (~5618): · WAV_BuildTimestampBasename (2827) reads INT 21h AH=2Ch (CH=hour, · WAV_Store2Dec (2804) turns each 0..99 field into two ASCII digits · commit 74c3fe8</sub>


## 5. Auto-named WAV rendering preserves the song filename for later saves

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the loaded song filename is AM_AM.IT
- When I render a pattern with Shift-Right
- Then the WAV file is named LL<HHMMSS>.WAV
- And the loaded song filename remains AM_AM.IT
- And a later song save targets AM_AM.IT

<sub>cite: IT_MUSIC.ASM snapshots all 14 bytes of Disk FileName before writing</sub>


## 6. The prefix is a static "LL" (Lackluster), not derived from the song

`@shipped @build-verified @hw-untested`


- Given any module, regardless of its song name
- When a single-pattern Quicksave render runs
- Then the filename always begins "LL"
- And "LL" + 6 time digits = 8 characters, fitting DOS 8.3 exactly

<sub>cite: WAV_BuildTimestampBasename writes literal 'L','L' at bytes 0..1 of</sub>


## 7. The extension is a real .WAV, not the 3-digit pattern number

`@shipped @build-verified @runtime-verified @hw-verified`


- Given the pattern-render path in WAVDRV
- When the output file is created
- Then its extension is ".WAV"
- And it is NOT the 3-digit pattern number (the old PTN0003.000 form is gone)

<sub>cite: SoundDrivers/WAVDRV.ASM CopyFileName (593) copies the basename up · commit be595b2 ; mirrors the song-mode path that already wrote .WAV</sub>


## 8. The auto-import opens the exact file WAVDRV wrote

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a plain-Right render produced LL163422.WAV on disk
- When auto-import rebuilds the filename to open it
- Then it reconstructs LL163422.WAV (copy-up-to-dot + ".WAV")
- And the open succeeds because the rebuilt name equals the file on disk

<sub>cite: IT_MUSIC.ASM two RenderedFilename builders -- enter-mode at</sub>


## 9. Multi-WAV, full-song, and user-named renders keep <PFX><NNNN>

`@shipped @build-verified @hw-untested`


- Given a render that is the multi-WAV per-channel sweep, OR a full-song
- render, OR one with a user-typed filename
- When the basename is built
- Then it uses the song-name-derived <PFX> + 4-digit counter (not the clock)
- And only the extension changed for these (now .WAV via WAVDRV Poll9)

<sub>cite: IT_MUSIC.ASM enter-mode gate jumps to WAV_BuildCounterName (5651)</sub>


## 10. The render plays the pattern's actual number of rows

`@shipped @build-verified @dosbox-verified @hw-untested`


- Given a pattern of any length is about to be rendered
- When playback is started for the render
- Then it is told how many rows that pattern actually has

<sub>cite: IT_MUSIC.ASM Music_ToggleWAVRender -- Music_GetPattern, then LodsW twice: · IT_MUSIC.ASM Music_PlayPattern -- "AX = pattern, BX = number of rows,</sub>


## 11. BX was never set, so renders intermittently wrote NO FILE AT ALL

`@corrected`


- Given a proc documents a register in its own header comment
- Then a caller that ignores it can fail in a way that looks like anything else


## 12. Two renders in the same second overwrite

`@known-limit`


- Given two single-pattern Quicksave renders within the same wall-clock second
- Then both resolve to the same LL<HHMMSS>.WAV
- And the second render overwrites the first

