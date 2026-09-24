# Pure Gherkin test extracted from features/f4-instrument-list.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/f4-instrument-list.feature

Feature: User Presses F4 (Instrument List)
  As someone shaping instruments (envelopes, NNA, MIDI),
  I want F4 to open the instrument editor and repeated F4 to cycle its tabs,
  And Ctrl-F4 to reach the disk instrument library,
  So that all four envelope/MIDI tabs of an instrument are reachable from one key.

  @stock @build-verified
  Scenario: F4 opens the instrument editor
    # cite: IT_OBJ1.ASM:3150 GlobalKeyList F4 (scancode 13Eh) -> Glbl_F4
    # cite: IT_G.ASM:384 Glbl_F4 -> Glbl_SampleToInstrument (cursor map),
    #       I_MapEnvelope, CurrentMode=4, Object1 instrument list
    Given the user is on any screen
    When the user presses F4
    Then CurrentMode becomes 4 and the instrument editor opens
    And if the user was on the sample list, the cursor maps to the same slot
    And the tab shown is whichever InstrumentScreen was last active

  @stock @build-verified
  Scenario: Pressing F4 again cycles the instrument tabs
    # cite: IT_I.ASM:871 I_SelectScreen cycles 0..3 then redraws via Glbl_F4_2
    # cite: IT_I.ASM:383 InstrumentScreenTable -> General / Volume / Panning / Pitch
    Given the user is already in the instrument editor
    When the user presses F4
    Then the active tab advances General -> Volume -> Panning -> Pitch -> General
    And the matching O1_InstrumentList<tab> object is drawn

  @stock @build-verified
  Scenario: Ctrl-F4 opens the disk Instrument Library from anywhere
    # cite: IT_OBJ1.ASM:3154 GlobalKeyList Ctrl-F4 -> Glbl_Ctrl_F4
    # cite: IT_G.ASM:696 Glbl_Ctrl_F4 calls D_InitLoadInstruments, CurrentMode=15,
    #       returns O1_ViewInstrumentLibrary
    # cite: IT.TXT:1817 "The Instrument library is accesible on Ctrl-F4"
    Given the user is on any screen
    When the user presses Ctrl-F4
    Then CurrentMode becomes 15 and the disk instrument library browser opens

  @shipped @build-verified @hw-untested
  Scenario: The per-instrument MIDI-In Channel is edited on the Pitch tab
    # cite: IT_OBJ1.ASM:6531 InstrumentMIDIInChannel (type 14, hdr byte 1Fh, 0..17)
    # cite: commit 10c837b
    # NOTE: live routing of those channels is a separate card ->
    #       features/midi-in-multitimbral.feature
    Given the user is on the instrument editor Pitch tab
    Then a "MIDI In Channel" field stores 0..17 at instrument header byte 1Fh
    And 0 = off, 1..16 = that channel, 17 = All/Omni
    And what those values DO live is documented in midi-in-multitimbral.feature
