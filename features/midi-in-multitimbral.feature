# =============================================================================
# WIKI PAGE / REPORT CARD: Multitimbral MIDI-In (live 16-part sampler)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# This .feature is the durable understanding-store AND the session command for
# the multitimbral MIDI-in feature. Each Scenario is a verified claim about
# behaviour, cited to its source proc and the commit that shipped it. Tags are
# the report-card grade.
#
# Report-card legend (tags):
#   @shipped          - in origin/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @hw-untested      - NOT yet exercised with real MIDI input (DOSBox-X cannot
#                       inject MIDI), so live note routing is unconfirmed
#   @stock            - upstream Impulse Tracker behaviour, not a fork addition
#
# SESSION >> features/midi-in-multitimbral.session.md
#   (the spawning conversation = the vibe diff; session 1fa213d0-83aa-4fc1-a8fb-
#    b38dbcdee53d, 2026-06-03; "claude --resume 1fa213d0-83aa-4fc1-a8fb-b38dbcdee53d")
#
# Source files linked back to this card (grep "features/midi-in-multitimbral"):
#   IT_MUSIC.ASM  - creator / expand / reset / build-slot / enable+banks flags
#   IT_I.ASM      - MIDIMulti_Route live router + MMR_FindInst channel match
#   IT_K.ASM      - MIDISend router hook + Shift-F1 panel toggle proc
#   IT_G.ASM      - Glbl_Shift_F4 3-state dispatcher
#   IT_OBJ1.ASM   - confirm dialog, F4 MIDI-In field object, Shift-F1 button
#
# Commit log (the ingest trail):
#   10c837b  per-instrument MIDI-In channel (hdr 1Fh) + Shift-F4 batch v1
#   7e3620a  live any-screen note router (MIDIMulti_Route)
#   2dac7d5  Shift-F4 made a toggle (MIDIMultiEnable can be turned off)
#   b5a0c66  Shift-F4 gated to Instrument mode      <- SUPERSEDED by 8c32fd2
#   8c32fd2  3-state Shift-F4 cycle + Shift-F1 router toggle + gate removed
#
# WATCH: Music_CreateMIDIInInstruments Music_ExpandMIDIInTo96 Music_ResetMIDIInTo16 MCMI_BuildSlot Music_GetMIDIMultiBanks Music_GetMIDIMultiEnable Music_SetMIDIMultiEnable MIDIMultiEnable MIDIMultiBanks Glbl_Shift_F4 Glbl_MIDIMulti_Toggle MIDIMulti_Route MMR_FindInst MIDIMultiToggleButton O1_ConfirmCreateMIDIIn InstrumentMIDIInChannel
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
#   2026-06-03  direct-commit  touched: Glbl_Shift_F4
#   2026-06-03  direct-commit  touched: Glbl_Shift_F4
#   2026-06-03  direct-commit  touched: Music_GetMIDIMultiEnable MIDIMultiEnable MIDIMulti_Route
#   2026-06-03  direct-commit  touched: Glbl_Shift_F4
# =============================================================================

Feature: Multitimbral MIDI-In
  As a musician driving the DOS PC from an external MIDI source,
  I want incoming notes on MIDI channels 01-16 to each trigger their own
  Impulse Tracker instrument live,
  So that Impulse Tracker becomes a 16-part sampler-synth, even while the
  transport is stopped.

  # The boundary that confused us for weeks: the per-instrument MIDI fields
  # split cleanly into OUT (drive outboard gear) and IN (listen). They never
  # cross. This scenario is the canonical claim that keeps them un-conflated.
  @stock @shipped @build-verified
  Scenario: Output MIDI fields are independent of the input field
    # cite: IT_MUSIC.ASM UpdateMIDI (~line 7960) reads hdr 3Ch/3Dh/3Eh-3Fh
    # cite: nothing in the output path reads hdr 1Fh
    Given an instrument header
    Then byte 3Ch "MIDI Channel", 3Dh "MIDI Program" and 3Eh/3Fh "MIDI Bank"
      are OUTPUT only (IT sends note/program/bank out to an external synth)
    And byte 1Fh "MIDI In Channel" is INPUT only (which channel IT listens on)
    And changing one never affects the other

  @shipped @build-verified
  Scenario: Each instrument can claim an incoming MIDI channel
    # cite: IT_OBJ1.ASM InstrumentMIDIInChannel object (F4 MIDI tab, type 14,
    #       bound DW 1Fh, min/max 0,17); commit 10c837b
    Given the F4 instrument editor MIDI screen
    Then a "MIDI In Channel" field stores 0..17 at instrument header byte 1Fh
    And 0 means off, 1..16 mean that channel, 17 means All/Omni
    And the value persists inside the 554-byte header (saved in .IT / .ITI)

  # --- Shift-F4 three-state cycle (this session's spec) ----------------------

  @shipped @build-verified
  Scenario: First Shift-F4 maps current samples to MIDI-In 01-16
    # cite: IT_G.ASM Glbl_Shift_F4 -> Music_CreateMIDIInInstruments (IT_MUSIC)
    # cite: commit 8c32fd2 ; instrument-mode gate (b5a0c66) removed here
    Given the user has samples loaded
    And Instruments mode is Off
    And no multitimbral set exists yet (MIDIMultiBanks = 0)
    When the user presses Shift-F4
    Then the "Map current samples to MIDI-In 01-16?" dialog opens
    When the user confirms
    Then instruments 01-16 are created in slots 1..16 directly
    And instrument N is set to MIDI In Channel N and plays sample N
    And each is named "MIDI In Ch NN"
    And the multitimbral router is enabled

  @shipped @build-verified
  Scenario: Second Shift-F4 replicates 01-16 across six banks (96 instruments)
    # cite: IT_G.ASM Glbl_Shift_F4 -> Music_ExpandMIDIInTo96 (IT_MUSIC)
    # cite: commit 8c32fd2 ; decision: "just create the 96 slots, no router change"
    Given the user has samples loaded and a single 01-16 set exists (banks = 1)
    When the user presses Shift-F4
    Then instruments 1..96 are created as six copies of the 01-16 map
    And instrument K responds to MIDI In Channel ((K-1) mod 16)+1 and plays
      that same-numbered sample
    And 96 is the largest multiple of 16 under the 99-instrument cap
    And the router still plays the first matching instrument per channel
      (the extra five copies are spare slots, by design)

  @shipped @build-verified
  Scenario: Third Shift-F4 resets the six banks back to one 01-16 set
    # cite: IT_G.ASM Glbl_Shift_F4 -> Music_ResetMIDIInTo16 (IT_MUSIC)
    # cite: commit 8c32fd2
    Given six banks exist (banks = 6, instruments 1..96 populated)
    When the user presses Shift-F4
    Then instruments 17..96 are emptied (each 554-byte header zeroed)
    And the single 01-16 set in slots 1..16 remains
    And the cycle returns to its one-bank state (banks = 1)

  # --- Live routing (the payoff that still needs hardware) -------------------

  @shipped @hw-untested
  Scenario: An incoming note on channel N triggers the matching instrument
    # cite: IT_K.ASM MIDISend hook -> IT_I.ASM MIDIMulti_Route + MMR_FindInst
    # cite: plays via Music_PlayNote on host channel 48+N ; commit 7e3620a
    # status: assembles + links, but live note-on/off NOT verified on hardware
    Given the multitimbral router is enabled
    And an instrument has MIDI In Channel set to N (or 17 = All)
    When a MIDI note-on arrives on channel N
    Then that instrument is played live on host channel 48+N, transport-independent
    And the note is NOT recorded into the pattern
    When the matching note-off (or note-on velocity 0) arrives
    Then that channel's voice is cut

  @shipped @hw-untested
  Scenario: Channel 1 note entry is unchanged when the router is off
    # cite: IT_K.ASM MIDISend ; router returns 0 when MIDIMultiEnable=0,
    #       so MIDIDataInput is left intact and the classic page path runs
    Given the multitimbral router is disabled (MIDIMultiEnable = 0)
    When a MIDI note arrives
    Then behaviour is byte-for-byte the classic note-entry path (the selected
      sample is triggered on the active screen)

  # --- The on/off switch (this session) --------------------------------------

  @shipped @build-verified
  Scenario: The router on/off switch lives on the Shift-F1 MIDI screen
    # cite: IT_OBJ1.ASM MIDIMultiToggleButton (list entry 25, rows 46-48)
    # cite: IT_K.ASM Glbl_MIDIMulti_Toggle flips MIDIMultiEnable ; commit 8c32fd2
    Given the Shift-F1 MIDI screen
    Then a "Toggle Multitimbral MIDI-In" button sits beside the MIDI Sync
      (F8 Clock) and MIDI Transport (FA/FB/FC) toggles
    When the user activates it
    Then the live router is flipped on or off without destroying any instruments
    And the info line confirms "Multitimbral MIDI-In: ON" / ": OFF"

  # --- Known limits carried forward (open report-card items) -----------------

  @todo
  Scenario: Polyphony per channel
    # The six-bank copies are spare slots only; the router is monophonic per
    # channel (fixed host channel 48+N, first-match instrument). Real polyphony
    # would need round-robin allocation or NNA=Continue. Deferred by decision
    # this session.
    Given a channel receives overlapping notes
    Then later notes currently cut earlier ones on that channel
