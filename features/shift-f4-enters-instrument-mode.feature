# =============================================================================
# WIKI PAGE / REPORT CARD: Shift-F4 (enable Multitimbral) also enters Instrument mode
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/shift-f4-enters-instrument-mode.session.md
#
# When the user confirms "Yes, enter Multitimbral Mode" on the Shift-F4 prompt,
# the fork now (a) batch-creates the 16 MIDI-in instruments mapped to samples
# 01-16, (b) flips the song from Sample mode to Instrument mode, and (c) shows
# the Instrument List so the mode change is visible. Sibling/parent dispatcher
# card: midi-in-multitimbral.feature (the 3-state Shift-F4 cycle).
#
# WHAT THIS CARD SPAWNS (generative seed)
#   Codespace : Glbl_Shift_F4_Create (IT_G.ASM) -> Music_CreateMIDIInInstruments
#               (IT_MUSIC.ASM) + the Instrument-mode flag set + Jmp Glbl_F4.
#   Thinkspace: the .session.md (why a DIRECT flag set, not the F12 path).
#   Areaspace : OWNS the "create confirmed -> enter Instrument mode + show F4"
#               transition. MUST NOT route through F_SetControlInstrument (the
#               removed-for-good envelope path) -- see
#               no-samples-to-instruments-envelope-retention.feature.
#
# Report-card legend (tags):
#   @stock @shipped @build-verified @runtime-verified @runtime-untested @todo
#
# Source files linked back to this card:
#   IT_G.ASM     - Glbl_Shift_F4 (353); Glbl_Shift_F4_Create (389): confirm ->
#                  Music_CreateMIDIInInstruments (396) -> Or [songseg:2Ch],4 (415,
#                  Instrument-mode flag) -> Jmp Glbl_F4 (429, show Instrument List).
#   IT_MUSIC.ASM - Music_CreateMIDIInInstruments (4075): builds instruments 1..16,
#                  each MIDI-in channel N (header byte 1Fh), all notes -> sample N;
#                  sets MIDIMultiBanks=1, MIDIMultiEnable=1.
#   IT_G.ASM     - Glbl_F4 (after this proc): the instrument-screen switch jumped to.
#
# Commit log (the ingest trail):
#   8c32fd2  Shift-F4 3-state cycle (the create dispatcher this extends)
#   (this commit) create-confirm now also enters Instrument mode + shows F4
#
# RESULT (third leg of the triad):
#   Delivery : this commit (direct to esaruoho/main).
#   Build    : BUILDALL via dosbox-x -conf buildall.conf 2026-06-03 22:06 EEST.
#              IT_G.asm "Error/Warning: None"; tlink 3.01 linked; IT.EXE rebuilt.
#   Triad: this .feature <-> shift-f4-enters-instrument-mode.session.md <-> commit
#
# WATCH: Glbl_Shift_F4 Music_CreateMIDIInInstruments Glbl_F4
# RESULT-LOG >> (auto-maintained by .githooks/post-merge)
#   2026-06-04  direct-commit  touched: Glbl_Shift_F4 Music_CreateMIDIInInstruments
#   2026-06-03  direct-commit  touched: Glbl_Shift_F4 Glbl_F4
#
# IT.TXT source of truth: Sample/Instrument mode is the F12 song-flag bit 2;
# Shift-F4 multitimbral MIDI-in is a fork feature (not in stock IT.TXT).
# =============================================================================

Feature: Shift-F4 to enable Multitimbral mode also switches Samples -> Instruments
  As someone enabling live multitimbral MIDI-in,
  I want confirming "Yes, enter Multitimbral Mode" to ALSO move me from Sample
  mode into Instrument mode (since the 16 things created are instruments),
  So that the instruments I just made are immediately the active, playable mode.

  @shipped @build-verified @runtime-verified @hw-verified
  # HW-VERIFIED 2026-06-05 (Esa): "shift f4 works in hw".
  Scenario: From Sample mode, Shift-F4 + confirm enters Instrument mode with 16 instruments
    # cite: IT_G.ASM:389 Glbl_Shift_F4_Create opens O1_ConfirmCreateMIDIIn; YES (DX!=0)
    # cite: IT_G.ASM:396 Call Music_CreateMIDIInInstruments
    # cite: IT_MUSIC.ASM:4075 builds instruments 1..16, each MIDI-in channel N
    #       (header 1Fh), all notes mapped to sample N; sets MIDIMultiBanks=1, enable=1
    # cite: IT_G.ASM:415 Or Byte Ptr [DS:2Ch],4 sets the Instrument-mode flag
    # cite: IT_G.ASM:429 Jmp Glbl_F4 shows the Instrument List (CurrentMode=4)
    Given the user is in Sample mode
    When they press Shift-F4 and choose "Yes, enter Multitimbral Mode"
    Then the song switches from Sample mode to Instrument mode (flag bit 2 set)
    And 16 instruments are created, instrument N mapped to sample N (01-16)
    And the Instrument List is shown so the mode change is visible

  @shipped @build-verified @hw-untested
  Scenario: The mode switch is a direct flag set, NOT the F12 clear/remap path
    # cite: IT_G.ASM:415 sets the flag directly after Music_GetSongSegment, exactly
    #       like F_SetControlInstrument does, but WITHOUT calling it -- so none of
    #       the removed envelope-retention / clear-all logic runs.
    # Guards against re-coupling to the brittle, removed F12 path.
    Given confirming "Yes" on the Shift-F4 prompt
    When the Instrument-mode flag is set
    Then F_SetControlInstrument is NOT invoked
    And no instrument-clearing / envelope-preserve logic runs

  @shipped @build-verified @hw-untested
  Scenario: Declining the prompt changes nothing
    # cite: IT_G.ASM Glbl_Shift_F4_Create: Test DX / JZ Glbl_Shift_F4_Done
    Given the user presses Shift-F4 and chooses "No"
    When the prompt is dismissed
    Then no instruments are created, the mode is unchanged, and the screen stays

  @runtime-untested
  Scenario: (verify live) cursor + playback survive the mode switch
    # Glbl_F4 runs Glbl_SampleToInstrument (cursor translate) + I_MapEnvelope as a
    # normal F4 entry; confirm on hardware that entering this way is indistinguishable
    # from pressing F4 and that any playing song keeps playing.
    Given a song may be playing when Shift-F4 + YES is pressed in Sample mode
    When the Instrument List opens
    Then it behaves like a normal F4 entry (cursor mapped, playback undisturbed)
