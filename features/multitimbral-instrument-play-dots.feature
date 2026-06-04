# =============================================================================
# WIKI PAGE / REPORT CARD: F4 Instrument-list play dots in multitimbral Sample mode
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# This .feature is the durable understanding-store AND the session command for
# the fork change that makes the F4 Instrument List show live "play dots" while
# the multitimbral MIDI-in router is driving voices in SAMPLE mode (instrument
# mode off). Each Scenario is a verified claim, cited to its source proc and the
# commit that shipped it. Tags are the report-card grade.
#
# WHAT THIS CARD SPAWNS (the card is a generative SEED, not a description):
#   - CODESPACE  : this .feature + the .session.md sibling, PLUS the innards in
#                  "Source files" below -- the one-branch change at the top of
#                  I_ShowInstrumentPlay and the shared dot-scan it now reaches.
#   - THINKSPACE : the .session.md -- WHY the F3 sample dots showed but F4
#                  instrument dots didn't (the instrument-mode gate), and the
#                  investigation that ruled out the slave fields first.
#   - AREASPACE  : owns ONLY the gate decision in I_ShowInstrumentPlay; must NOT
#                  touch the slave scan body, I_ShowSamplePlay, or the router.
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01);
#                       IT_I.asm Error/Warning = None, IT.EXE links
#   @hw-untested    - NOT run on real DOS hardware (DOSBox-X is emulation, not metal)
#   @runtime-verified - exercised by running IT.EXE and watching the F4 dots
#   @runtime-untested - NOT yet run; logic verified by reading only
#   @stock            - upstream Impulse Tracker behaviour, not a fork addition
#
# Source files linked back to this card (grep "features/multitimbral-instrument-play-dots"):
#   IT_I.ASM  - I_ShowInstrumentPlay gate: Music_GetInstrumentMode OR
#               Music_GetMIDIMultiEnable -> proceed (~line 8543)
#   IT_I.ASM  - I_ShowSamplePlay (8488): the no-gate sibling F3 reference
#   IT_L.ASM  - UpdatePointers (448/455): per-screen idle dispatch to the two
#               Show procs (AH=3 -> sample list, AH=4 -> instrument list)
#   IT_MUSIC.ASM - Music_GetMIDIMultiEnable (4272); slave [SI+32h]=Nte&Ins so
#               [SI+33h]=instrument (AllocateChannel ~1591)
#
# Commit log (the ingest trail):
#   478b638  show F4 instrument-list play dots in multitimbral Sample mode
#
# SESSION (the vibe record): features/multitimbral-instrument-play-dots.session.md
#   The card is incomplete without it.
#
# RESULT (third leg of the triad):
#   Feature delivery : 478b638 direct to esaruoho/main, no PR
#   This card authored: the card+session commit that follows 478b638
#   Triad: this .feature <-> .session.md <-> 478b638
#
# WATCH: I_ShowInstrumentPlay I_ShowSamplePlay Music_GetInstrumentMode Music_GetMIDIMultiEnable MIDIMulti_Route
#
# Sibling: features/midi-in-multitimbral.feature (the router itself).
# =============================================================================

Feature: F4 instrument-list play dots in multitimbral Sample mode
  As someone playing a multitimbral MIDI rig into IT with the song in Sample
  mode,
  I want the F4 Instrument List to show live play dots while notes sound,
  just like the F3 Sample List already does,
  So that I can see which routed instruments are active without switching to
  the sample screen.

  # --- The bug -------------------------------------------------------------

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Stock IT hid the F4 dots whenever instrument mode was off
    # cite: IT_I.ASM I_ShowInstrumentPlay opened with Music_GetInstrumentMode /
    #       JZ end -- bailed entirely when not in instrument mode
    # cite: I_ShowSamplePlay (8488) has NO such gate -> F3 kept showing dots
    Given the song is in Sample mode (instrument mode off)
    And the multitimbral MIDI-in router is enabled and sounding voices
    When the user views the F4 Instrument List
    Then (old) no play dots appeared, even though the F3 Sample List showed them

  # --- The fix -------------------------------------------------------------

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: With the router on, F4 shows play dots even in Sample mode
    # cite: IT_I.ASM I_ShowInstrumentPlay (478b638): if Music_GetInstrumentMode
    #       is 0, fall through to Music_GetMIDIMultiEnable; proceed if set
    Given the song is in Sample mode
    And Music_GetMIDIMultiEnable is set (multitimbral routing on)
    When voices are sounding and the user views F4
    Then the instrument-list play dots are drawn (the gate no longer bails)
    And they track the matched instrument via the slave field [SI+33h]

  @shipped @build-verified @hw-untested
  Scenario: Normal Sample mode (router off) is unchanged
    # cite: the new branch only proceeds when Music_GetMIDIMultiEnable is set;
    #       otherwise the original JZ-to-end behaviour stands
    Given the song is in Sample mode and the multitimbral router is OFF
    When the user views F4
    Then no instrument play dots are drawn (stock behaviour preserved)

  @stock @build-verified
  Scenario: Instrument mode still shows dots exactly as before
    # cite: Music_GetInstrumentMode non-zero takes the proceed branch directly,
    #       never consulting the router flag
    Given the song is in Instrument mode
    When the user views F4 during playback
    Then the dots draw as they always did, router on or off

  # --- Why it is keyed correctly -------------------------------------------

  @shipped @build-verified @hw-untested
  Scenario: The dot row is the routed instrument, not a sentinel
    # cite: MIDIMulti_Route -> Music_PlayNote with MMR_Inst (1..99); the slave
    #       allocator copies host [DI+3..4] into [SI+32h] so [SI+33h]=instrument
    # cite: I_ShowInstrumentPlay scan reads [SI+33h], skips >=100, lights row BX
    Given a routed note for instrument N is sounding
    When the F4 dot scan runs
    Then InstrumentPlayTable[N] is lit, so the dot appears on instrument N's row
