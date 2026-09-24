# Pure Gherkin test extracted from features/f12-song-variables.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/f12-song-variables.feature

Feature: User Presses F12 (Song Variables & Directory Configuration)
  As someone setting up a tune and its working folders,
  I want F12 to open song variables plus the module/sample/instrument/quicksave
  directories, with each directory row pickable, and Samples->Instruments to
  keep my drawn envelopes,
  So that song config and folder routing live on one screen and nothing is lost.

  @stock @build-verified
  Scenario: F12 opens the song variables & configuration screen
    # cite: IT_OBJ1.ASM:3198 GlobalKeyList F12 (scancode 158h) -> Glbl_F12
    # cite: IT_G.ASM:652 Glbl_F12 CurrentMode=12, returns O1_ConfigureITList
    # cite: IT_OBJ1.ASM:5378 title "Song Variables & Directory Configuration (F12)"
    # cite: IT.TXT:1748 "F12 for the variables"
    Given the user is on any screen
    When the user presses F12
    Then CurrentMode becomes 12 and the song variables & directory config screen opens
    And song name, tempo, speed, global volume and mixing config are editable

  @shipped @build-verified @hw-untested
  Scenario: A Quicksave directory row is on the F12 screen
    # cite: IT_OBJ1.ASM:5643 QuickSaveDirectoryInput (object 31), Enter -> D_PickQuickSaveDir
    # cite: commit 7fd1abc
    Given the user is on the F12 config screen
    Then a Quicksave directory input row is present alongside the
      Module / Sample / Instrument directory rows
    And typing a path and saving persists it to IT.CFG

  @shipped @build-verified @hw-untested
  Scenario: Each directory row is Enter-pickable through a file browser
    # cite: IT_DISK.ASM:8403/8452/8461/8470 the four D_Pick*Dir Enter callbacks
    #       all route through D_PickDir_Common (IT_DISK.ASM:8504)
    # cite: D_PickDir_Common backs up SongDirectory, swaps in the target dir,
    #       sets DirectoryPickerActive, jumps to Glbl_F9; Esc restores the backup
    # cite: commits 4eee4f8, 8f11aa6 ('/' -> '\' in the fields)
    Given the user is on a directory row (Module / Sample / Instrument / Quicksave)
    When the user presses Enter
    Then the F9 file browser opens scoped to that directory
    And choosing a folder writes it back to that row; Esc restores the previous value

  @shipped @build-verified @hw-untested
  Scenario: Samples->Instruments keeps drawn envelopes
    # cite: IT_F.ASM:4833 F_SetControlInstrument; :4922 Music_InstrumentIsReal gate
    #       (ZF=1 -> "IMPI" magic present -> real instrument, do not clear);
    #       envelope section (offset 130h+) is never touched, so drawn envelopes survive
    # cite: history d8ec842 (attempt) -> b5a0c66 (revert, EMM386 #12 crash)
    #       -> 9a1142c (clean IMPI-gated re-implementation) -> 9493101 (merged to main)
    # NOTE: corrects the older "feature reverted" memory — the cleaner policy is live.
    Given the user converts samples into instruments
    When an instrument slot already holds a real instrument ("IMPI" magic)
    Then that slot is not cleared and its drawn envelope is preserved
    And only non-IMPI garbage slots are reset to a valid blank template
    And every slot with a matching sample gets the name + 120-note keymap written
