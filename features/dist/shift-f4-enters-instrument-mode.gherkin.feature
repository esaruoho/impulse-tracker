# Pure Gherkin test extracted from features/shift-f4-enters-instrument-mode.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/shift-f4-enters-instrument-mode.feature

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
