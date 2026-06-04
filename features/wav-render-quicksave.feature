# =============================================================================
# WIKI PAGE / REPORT CARD: WAV Quicksave render filename
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# This .feature is the durable understanding-store AND the session command for
# how single-pattern WAV renders are named when they land in the Quicksave
# folder. Each Scenario is a verified claim about behaviour, cited to its source
# proc and the commit that shipped it. Tags are the report-card grade.
#
# WHAT THIS CARD SPAWNS (the card is a generative SEED, not a description):
# This card + its .session.md is, by itself, enough to re-spawn the feature's
# three spaces. That is the whole point -- the report card comes first; code,
# dialogue, and domain flow back out of it.
#   - CODESPACE  (the file structure): this .feature + the .session.md sibling,
#                PLUS the innards layout in "Source files" below -- which files,
#                which procs, the order they run (gesture -> name -> extension ->
#                import). From this you can scaffold or re-derive the code.
#   - THINKSPACE (the reasoning / vibe): the .session.md -- the dialogue that
#                produced every decision, including the wrong turns. Load it and
#                skip re-deriving the WHY.
#   - AREASPACE  (the domain boundary): the Feature narrative + the "keeps the
#                counter naming" scenario -- what this OWNS, and just as
#                important what it must NOT touch (multi-WAV / full-song /
#                user-named names; MIDI; the mixer).
#
# Report-card legend (tags):
#   @shipped          - in origin/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01), full
#                       BUILDALL: IT.EXE + 42 drivers, Error/Warning = None
#   @hw-untested    - NOT run on real DOS hardware (DOSBox-X is emulation, not metal)
#   @runtime-verified - CONFIRMED on a running IT.EXE (2026-06-04, Esa): the
#                       Quicksave render writes LL<HHMMSS>.WAV to disk.
#   @runtime-untested - NOT yet exercised by actually running IT.EXE: pressing
#                       the key, watching the Quicksave folder, confirming the
#                       file name / that auto-import opens it. Runnable in
#                       DOSBox-X; just not run yet.
#   @stock            - upstream Impulse Tracker behaviour, not a fork addition
#
# Source files linked back to this card (grep "features/wav-render-quicksave"):
#   IT_PE.ASM          - F11 order-list gestures + Ctrl-O dispatchers
#   IT_MUSIC.ASM       - Music_ToggleWAVRender enter-mode naming gate;
#                        WAV_BuildTimestampBasename / WAV_Store2Dec;
#                        the two RenderedFilename builders; Music_Import...
#   SoundDrivers/WAVDRV.ASM - CopyFileName (basename) + Poll9 (.WAV extension)
#
# Commit log (the ingest trail):
#   be595b2  WAV render: .000 (3-digit pattern number) -> real .WAV extension
#   74c3fe8  single-pattern Quicksave render named LL<HHMMSS>.WAV by the clock
#
# SESSION (the vibe record -- the conversation that spawned this card):
#   features/wav-render-quicksave.session.md
#   The card is incomplete without it. The session is the vibe-diff unit:
#   future versions diff the dialogue (requests, refinements, corrections),
#   not just the code and the card.
#
# RESULT (third leg of the triad: .feature spec + .session convo + what shipped):
#   Feature delivery : be595b2 (.000 -> .WAV), 74c3fe8 (LL<HHMMSS>.WAV)
#                      direct to esaruoho/main, no PR
#   This card authored: 3d5882a (card + back-links), 47015b7 (session),
#                       3fd46da (generative-seed preamble)
#   Triad: this .feature  <->  wav-render-quicksave.session.md  <->  those commits
#
# WATCH: WAV_BuildTimestampBasename WAV_Store2Dec Music_ToggleWAVRender Music_ImportRenderedPattern PE_OrderList_RightDispatch PE_OrderList_RenderDispatch PE_OrderList_RenderQuicksave PE_OrderList_GDispatch CopyFileName
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
#   2026-06-03  direct-merge  merge b54ecc0  touched: WAV_Store2Dec
#   2026-06-03  direct-merge  merge 6de8cd0  touched: WAV_Store2Dec
#
# IT.TXT source of truth: F10/F11 render docs; CLAUDE.md Ctrl-O / F11 tables.
# =============================================================================

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
