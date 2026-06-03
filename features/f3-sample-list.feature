# =============================================================================
# WIKI PAGE / REPORT CARD: User Presses F3 (Sample List)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/fkey-report-cards.session.md (the vibe diff that spawned this)
#
# Durable understanding-store for "what happens when the user presses F3" and
# the sibling Ctrl-F3 sample library, plus the fork's loader-keyjazz hang fix
# that keeps the song playing while a sample preview loads.
#
# Report-card legend (tags):
#   @stock          - upstream Impulse Tracker behaviour
#   @shipped        - fork addition, in origin/main
#   @build-verified - assembles + links clean (TASM 4.1 / TLINK 3.01)
#
# Source files linked back to this card:
#   IT_OBJ1.ASM  - GlobalKeyList F3 (3142) and Ctrl-F3 (3146) dispatch entries
#   IT_G.ASM     - Glbl_F3 (303), Glbl_Ctrl_F3 (680)
#   IT_I.ASM     - I_DrawSampleList (~1000), I_PreSampleList (~1163), I_DrawWaveForm
#   IT_K.ASM     - MIDISyncLoaderSuppress flag (114); MIDI_SetLoaderSuppress (2134),
#                  MIDI_ClearLoaderSuppress (2145); FA/FC guards (1991, 2014)
#   IT_DISK.ASM  - D_PreLoadSampleWindow suppress/clear (6108/6157);
#                  LSWindow_ShiftEnter bulk suppress/clear (7859/7922)
#   IT_MUSIC.ASM - Music_SilenceSampleVoices (9230), called from LoadSample (7363)
#
# Commit log (the ingest trail):
#   fb47b32  Import code (upstream base: F3 sample list, Ctrl-F3 library)
#   a44c41b  Music_SilenceSampleVoices: keep playback alive across (re)loads
#   64fa1ce  F3 loader keyjazz hang fix: suppress MIDI sync during LoadSample
#   ec91331  F3 loader keyjazz: instrument LoadSample + PlaySample w/ VRAM markers
#
# RESULT (third leg of the triad: .feature spec + .session convo + what shipped):
#   Feature delivery : a44c41b, 64fa1ce, ec91331  (direct to esaruoho/main, no PR)
#   This card authored: 8ca97e9 (cards) + 009dbab (session + back-links)
#   Triad: this .feature  <->  fkey-report-cards.session.md  <->  those commits
#
# IT.TXT source of truth: lines 1815-1817 (Ctrl-F3 = Sample library from anywhere).
# =============================================================================

Feature: User Presses F3 (Sample List)
  As someone working with raw samples,
  I want F3 to open the sample list and Ctrl-F3 to reach the disk library,
  And I want previewing a sample in the loader to NOT kill the playing song,
  So that sample work never silences the tune I'm building it for.

  @stock @build-verified
  Scenario: F3 opens the sample list
    # cite: IT_OBJ1.ASM:3142 GlobalKeyList F3 (scancode 13Dh) -> Glbl_F3
    # cite: IT_G.ASM:303 Glbl_F3 sets CurrentMode=3, returns O1_SampleList
    # cite: IT_G.ASM:305 Glbl_InstrumentToSample translates an F4-cursor to F3
    # cite: IT_I.ASM I_DrawWaveForm + I_DrawSampleList draw the screen
    Given the user is on any screen
    When the user presses F3
    Then CurrentMode becomes 3 and the sample list (O1_SampleList) opens
    And if the user was on the instrument list, the cursor maps to the same slot

  @stock @build-verified
  Scenario: Ctrl-F3 opens the disk Sample Library from anywhere
    # cite: IT_OBJ1.ASM:3146 GlobalKeyList Ctrl-F3 -> Glbl_Ctrl_F3
    # cite: IT_G.ASM:680 Glbl_Ctrl_F3 calls D_InitLoadSamples, CurrentMode=13,
    #       returns O1_ViewSampleLibrary
    # cite: IT.TXT:1815 "The Sample library is accesible from all screens ... Ctrl-F3"
    Given the user is on any screen
    When the user presses Ctrl-F3
    Then CurrentMode becomes 13 and the disk-based sample library browser opens

  # --- The fork's loader keyjazz hang fix ------------------------------------

  @shipped @build-verified
  Scenario: Previewing a sample in the loader does not stop the song
    # cite: IT_DISK.ASM:6108 D_PreLoadSampleWindow calls MIDI_SetLoaderSuppress
    #       before LoadSample, :6157 clears it after Music_PlayNote
    # cite: IT_MUSIC.ASM:9230 Music_SilenceSampleVoices stops only slaves whose
    #       slot ([SI+36h]) matches the slot being (re)loaded (writes 200h)
    # cite: commits a44c41b, 64fa1ce
    Given a song is playing
    When the user keyjazz-previews a sample in the loader (LoadSample slot 99)
    Then only the voices reading that one slot are silenced (200h sentinel)
    And the rest of the song keeps playing

  @shipped @build-verified
  Scenario: MIDI transport bytes can't restart the song mid-load
    # cite: IT_K.ASM:114 MIDISyncLoaderSuppress; :1991 FA guard, :2014 FC guard
    #       MIDISend skips Music_KBPlaySong / Music_Stop while the flag is set;
    #       RT clock counters still tick, only start/stop/continue are gated
    # cite: commit 64fa1ce
    Given the loader suppress flag is set (a sample load is in flight)
    When a MIDI Start (FA) or Stop (FC) byte arrives
    Then MIDISend skips the playback restart while slot 99 is mid-write
    And once the load finishes the flag is cleared and sync resumes normally

  @shipped @build-verified
  Scenario: Shift-Enter bulk sample load is guarded the same way
    # cite: IT_DISK.ASM:7859 LSWindow_ShiftEnter sets suppress at loop start,
    #       :7922 clears it at loop end
    # cite: commit 64fa1ce
    Given the user triggers a bulk sample load in the library
    When many slots are written in a loop
    Then MIDI transport is suppressed for the whole loop, not per file
    And the song (if playing) survives the bulk load
