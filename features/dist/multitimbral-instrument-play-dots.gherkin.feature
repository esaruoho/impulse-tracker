# Pure Gherkin test extracted from features/multitimbral-instrument-play-dots.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/multitimbral-instrument-play-dots.feature

Feature: F4 instrument-list play dots in multitimbral Sample mode
  As someone playing a multitimbral MIDI rig into IT with the song in Sample
  mode,
  I want the F4 Instrument List to show live play dots while notes sound,
  just like the F3 Sample List already does,
  So that I can see which routed instruments are active without switching to
  the sample screen.

  # --- The bug -------------------------------------------------------------

  @shipped @build-verified @runtime-untested
  Scenario: Stock IT hid the F4 dots whenever instrument mode was off
    # cite: IT_I.ASM I_ShowInstrumentPlay opened with Music_GetInstrumentMode /
    #       JZ end -- bailed entirely when not in instrument mode
    # cite: I_ShowSamplePlay (8488) has NO such gate -> F3 kept showing dots
    Given the song is in Sample mode (instrument mode off)
    And the multitimbral MIDI-in router is enabled and sounding voices
    When the user views the F4 Instrument List
    Then (old) no play dots appeared, even though the F3 Sample List showed them

  # --- The fix -------------------------------------------------------------

  @shipped @build-verified @runtime-untested
  Scenario: With the router on, F4 shows play dots even in Sample mode
    # cite: IT_I.ASM I_ShowInstrumentPlay (478b638): if Music_GetInstrumentMode
    #       is 0, fall through to Music_GetMIDIMultiEnable; proceed if set
    Given the song is in Sample mode
    And Music_GetMIDIMultiEnable is set (multitimbral routing on)
    When voices are sounding and the user views F4
    Then the instrument-list play dots are drawn (the gate no longer bails)
    And they track the matched instrument via the slave field [SI+33h]

  @shipped @build-verified
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

  @shipped @build-verified
  Scenario: The dot row is the routed instrument, not a sentinel
    # cite: MIDIMulti_Route -> Music_PlayNote with MMR_Inst (1..99); the slave
    #       allocator copies host [DI+3..4] into [SI+32h] so [SI+33h]=instrument
    # cite: I_ShowInstrumentPlay scan reads [SI+33h], skips >=100, lights row BX
    Given a routed note for instrument N is sounding
    When the F4 dot scan runs
    Then InstrumentPlayTable[N] is lit, so the dot appears on instrument N's row
