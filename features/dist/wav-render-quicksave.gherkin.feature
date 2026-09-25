# Pure Gherkin test extracted from features/wav-render-quicksave.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/wav-render-quicksave.feature

Feature: WAV Quicksave render filename
  As a musician rendering patterns to disk for use in another app,
  I want each single-pattern Quicksave render to come out as a real,
  time-stamped .WAV file (LL<HHMMSS>.WAV),
  So that the files sit time-sorted in the Quicksave folder and drag straight
  into another app, instead of clobbering each other or carrying a fake
  .000-style extension.

  # --- The trigger gesture ---------------------------------------------------

  @shipped @build-verified @runtime-verified @hw-verified
  Scenario: Shift-Right at the order-list right edge renders to Quicksave only
    # cite: IT_PE.ASM PE_OrderList_RightDispatch (line 2320) fires only at
    #       OrderCursor == 2 (rightmost of the 3-digit cell), else normal wrap
    # cite: -> PE_OrderList_RenderDispatch (2337): Shift held => ArmRenderNoImport
    Given the F11 Order List is open
    And the cursor is on the right-most character of the 3-char order column
    When the user presses Shift-Right
    Then a WAV render of the active pattern starts
    And the file lands in the Quicksave folder with NO auto-import
      (Shift = render-to-Quicksave-only)

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Plain Right at the same edge renders AND auto-imports
    # cite: IT_PE.ASM PE_OrderList_RenderDispatch (2337): no Shift =>
    #       Music_ClearRenderNoImport, so the file imports as the next sample
    Given the F11 Order List cursor on the right-most order-column character
    When the user presses Right (no Shift)
    Then the active pattern is rendered to the Quicksave folder
    And the rendered WAV is auto-imported as the next sample slot

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Shift-Right writes stereo WAV data when Stereo playback is enabled
    # cite: IT_MUSIC.ASM Music_AutoDetectSoundCard (~8063) calls
    #       Music_InitStereo after loading ITWAV.DRV for the render hot-swap
    # cite: SoundDrivers/WAVDRV.ASM compiles SetStereo, stereo mixing, and the
    #       Poll10 stereo header fields under STEREOENABLED, not REGISTERED
    Given Stereo playback is enabled in the song flags
    And the F11 Order List cursor is on the right-most order-column character
    When the user presses Shift-Right
    Then ITWAV.DRV writes a 2-channel 16-bit WAV file
    And mono mode still writes a 1-channel 16-bit WAV file

  # --- The name: LL + HHMMSS -------------------------------------------------

  @shipped @build-verified @runtime-verified @hw-verified
  Scenario: A single-pattern Quicksave render is named by wall-clock time
    # cite: IT_MUSIC.ASM Music_ToggleWAVRender enter-mode gate (~5618):
    #       MultiMode=0 AND SongMode=0 AND UserFilenameSet=0 -> timestamp path
    # cite: WAV_BuildTimestampBasename (2827) reads INT 21h AH=2Ch (CH=hour,
    #       CL=min, DH=sec) and writes "LL"+HHMMSS+'.' into WAV_RenderBasename
    # cite: WAV_Store2Dec (2804) turns each 0..99 field into two ASCII digits
    # cite: commit 74c3fe8
    Given a single-pattern Quicksave render at 16:34:22
    Then the file is named LL163422.WAV
    And HHMMSS is the 24-hour DOS clock (hour, minute, second), zero-padded

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Auto-named WAV rendering preserves the song filename for later saves
    # cite: IT_MUSIC.ASM snapshots all 14 bytes of Disk FileName before writing
    #       the render basename, then restores them after WAVDRV is unloaded.
    Given the loaded song filename is AM_AM.IT
    When I render a pattern with Shift-Right
    Then the WAV file is named LL<HHMMSS>.WAV
    And the loaded song filename remains AM_AM.IT
    And a later song save targets AM_AM.IT

  @shipped @build-verified @hw-untested
  Scenario: The prefix is a static "LL" (Lackluster), not derived from the song
    # cite: WAV_BuildTimestampBasename writes literal 'L','L' at bytes 0..1 of
    #       WAV_RenderBasename, independent of the song name
    Given any module, regardless of its song name
    When a single-pattern Quicksave render runs
    Then the filename always begins "LL"
    And "LL" + 6 time digits = 8 characters, fitting DOS 8.3 exactly

  # --- The extension: real .WAV ----------------------------------------------

  @shipped @build-verified @runtime-verified @hw-verified
  Scenario: The extension is a real .WAV, not the 3-digit pattern number
    # cite: SoundDrivers/WAVDRV.ASM CopyFileName (593) copies the basename up
    #       to its '.', then Poll9 (813) appends ".WAV" + NUL (was the pattern
    #       number, e.g. .000) for the pattern-render path
    # cite: commit be595b2 ; mirrors the song-mode path that already wrote .WAV
    Given the pattern-render path in WAVDRV
    When the output file is created
    Then its extension is ".WAV"
    And it is NOT the 3-digit pattern number (the old PTN0003.000 form is gone)

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The auto-import opens the exact file WAVDRV wrote
    # cite: IT_MUSIC.ASM two RenderedFilename builders -- enter-mode at
    #       WAV_BasenameReady's tail (~5790) and Music_ImportRenderedPattern
    #       (6274) -- both copy WAV_RenderBasename UP TO its '.' then append
    #       ".WAV", so they match whether the basename is 8 (LL163422) or 7
    #       (PFX0000) chars before the dot
    Given a plain-Right render produced LL163422.WAV on disk
    When auto-import rebuilds the filename to open it
    Then it reconstructs LL163422.WAV (copy-up-to-dot + ".WAV")
    And the open succeeds because the rebuilt name equals the file on disk

  # --- The boundary: what KEEPS the old counter naming -----------------------

  @shipped @build-verified @hw-untested
  Scenario: Multi-WAV, full-song, and user-named renders keep <PFX><NNNN>
    # cite: IT_MUSIC.ASM enter-mode gate jumps to WAV_BuildCounterName (5651)
    #       whenever WAV_MultiMode, WAV_SongMode, or WAV_UserFilenameSet is set
    Given a render that is the multi-WAV per-channel sweep, OR a full-song
      render, OR one with a user-typed filename
    When the basename is built
    Then it uses the song-name-derived <PFX> + 4-digit counter (not the clock)
    And only the extension changed for these (now .WAV via WAVDRV Poll9)

  # --- The bug that made renders silently produce nothing --------------------

  @shipped @build-verified @dosbox-verified @hw-untested
  Scenario: The render plays the pattern's actual number of rows
    # cite: IT_MUSIC.ASM Music_ToggleWAVRender -- Music_GetPattern, then LodsW twice:
    #       word 0 is the packed length, word 1 is the row count -> BX
    # cite: IT_MUSIC.ASM Music_PlayPattern -- "AX = pattern, BX = number of rows,
    #       CX = row to start"; it stores BX into NumberOfRows
    Given a pattern of any length is about to be rendered
    When playback is started for the render
    Then it is told how many rows that pattern actually has

  @corrected
  Scenario: BX was never set, so renders intermittently wrote NO FILE AT ALL
    # THE ROOT CAUSE of "it says it saved but there is no wavefile", found
    # 2026-08-14 while building the headless batch render.
    #
    # Music_PlayPattern takes the row count in BX. This call site set only AX and
    # CX, so NumberOfRows received whatever BX happened to hold from the code that
    # ran before. When that value landed small, the pattern ended on its FIRST tick:
    #
    #   PlayMode -> 0 before WAVDRV's Poll ever reached its Int 21h AH=3Ch
    #   -> the output file was never even CREATED, let alone written
    #   -> the synchronous loop exited on its first pass and looked healthy
    #
    # Every symptom pointed away from the real cause. The log's "it=" field showed
    # the full 100000 counter, which reads as a clean one-pass render (see
    # features/debug-logging-channels.feature, gotcha 5). No error was raised,
    # because WAVDRV's create-failure path only sets an info line. And it depended
    # on leftover register contents, so it came and went -- which sent the
    # investigation to the network share and the DOS redirector instead.
    #
    # Time lost: most of a session, across both trackers. What ended it was
    # rendering in a LOOP: the same failure every time, in DOSBox, where the
    # register state going in was consistent.
    Given a proc documents a register in its own header comment
    Then a caller that ignores it can fail in a way that looks like anything else

  # --- Known limit carried forward (open report-card item) -------------------

  @known-limit
  Scenario: Two renders in the same second overwrite
    # The name has 1-second resolution (HHMMSS). Accepted by Esa: renders take
    # seconds and the gesture is a manual key press, so a same-second collision
    # is not a real-world case. A tiebreaker (centisecond from INT 21h DL, or a
    # counter suffix) would be a small follow-up if it ever bites.
    Given two single-pattern Quicksave renders within the same wall-clock second
    Then both resolve to the same LL<HHMMSS>.WAV
    And the second render overwrites the first
