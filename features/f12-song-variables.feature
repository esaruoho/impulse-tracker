# =============================================================================
# WIKI PAGE / REPORT CARD: User Presses F12 (Song Variables & Directory Config)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/fkey-report-cards.session.md (the vibe diff that spawned this)
#
# Durable understanding-store for "what happens when the user presses F12":
# the stock song-variables / config screen, plus the fork's Quicksave directory
# row, the four Enter-pickable directory rows, and the Samples->Instruments
# envelope-preservation policy.
#
# Report-card legend (tags):
#   @stock          - upstream Impulse Tracker behaviour
#   @shipped        - fork addition, in origin/main
#   @build-verified - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @hw-untested    - NOT run on real DOS hardware (DOSBox-X is emulation, not metal)
#
# Source files linked back to this card:
#   IT_OBJ1.ASM  - GlobalKeyList F12 (3198, scancode 158h) -> Glbl_F12
#   IT_G.ASM     - Glbl_F12 (652-662), CurrentMode=12, O1_ConfigureITList
#   IT_OBJ1.ASM  - O1_ConfigureITList (5378, title "Song Variables & Directory
#                  Configuration (F12)"); QuickSaveDirectoryInput (5643)
#   IT_DISK.ASM  - D_PickModuleDir (8403), D_PickSampleDir (8452),
#                  D_PickInstrumentDir (8461), D_PickQuickSaveDir (8470),
#                  D_PickDir_Common (8504)
#   IT_F.ASM     - F_SetControlInstrument (4833), Music_InstrumentIsReal gate (4922)
#
# Commit log (the ingest trail):
#   fb47b32  Import code (upstream base: F12 song variables / config)
#   7fd1abc  F12 config screen: add Quicksave directory input row
#   8f11aa6  Quickfix: translate '/' to '\' in F12 directory input fields
#   4eee4f8  F12 dir pickers via unified D_PickDir_Common
#   d8ec842  F12 Samples->Instruments preserves drawn envelopes (first attempt)
#   b5a0c66  Revert envelope preservation (EMM386 #12 crash)
#   9a1142c  Cleaner policy: always remap + keep envelopes; gate garbage-clear on IMPI
#   9493101  Merge PR #3 -> envelope preservation re-lands in main
#
# RESULT (third leg of the triad: .feature spec + .session convo + what shipped):
#   Feature delivery (dir rows): 7fd1abc, 8f11aa6, 4eee4f8  (direct to esaruoho/main, no PR)
#   Feature delivery (envelope) : d8ec842 (attempt) -> b5a0c66 (revert, both direct)
#                                 -> a44a607, 9a1142c (PR #3 branch)
#                                 -> 9493101 MERGE PR #3 "WIP (DO NOT MERGE):
#                                    Samples->Instruments retain drawn envelopes"
#                                    (merged 2026-06-03; the only PR-delivered piece
#                                    in this batch — everything else is direct-push)
#   This card authored: 8ca97e9 (cards) + 009dbab (session + back-links)
#   Triad: this .feature  <->  fkey-report-cards.session.md  <->  commits + PR #3
#
# WATCH: Glbl_F12 QuickSaveDirectoryInput D_PickModuleDir D_PickSampleDir D_PickInstrumentDir D_PickQuickSaveDir D_PickDir_Common F_SetControlInstrument Music_InstrumentIsReal
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
#   2026-06-03  direct-commit  touched: F_SetControlInstrument
#   2026-06-03  direct-commit  touched: F_SetControlInstrument Music_InstrumentIsReal
#
# IT.TXT source of truth: lines 659 (Song Variables) and 1748 ("F12 for the variables").
# =============================================================================

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
