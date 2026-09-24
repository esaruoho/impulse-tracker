# Pure Gherkin test extracted from features/loader-keyjazz-hang.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/loader-keyjazz-hang.feature

Feature: F3/F4 loader keyjazz keeps the song playing
  As someone auditioning samples against a playing song from the loader browser,
  I want previewing or loading a sample to NOT stop playback,
  So that I can hear a candidate sample in the mix without the song halting and
  without IT hanging on a half-loaded sample header.

  @stock @build-verified
  Scenario: (pre-fork) keyjazz / load in the browser used to kill the song
    # The bug this card fixes: the loader paths called Music_Stop, halting all voices.
    Given the user is auditioning or loading a sample in the F9 file browser
    When a preview note is played or a sample is loaded (pre-fork)
    Then the entire song stops -- the defect

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Keyjazz preview in the browser silences only the preview voice
    # cite: IT_DISK.ASM LoadSample -- preview load uses zero-based slot 99.
    # cite: IT_MUSIC.ASM Music_SilenceSampleVoices -- only matching zero-based slot
    #       voices fall silent (the 200h voice-off sentinel), every other channel plays on.
    # cite: commit a44c41b
    Given a song is playing and the user is in the sample-loader file browser
    When the user keyjazzes a note to preview a sample
    Then only the preview voice for sample slot 99 is silenced; the song keeps playing

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Preview waveform redraw reads the freshly loaded preview slot
    # cite: IT_DISK.ASM LoadSample calls D_DrawWaveForm after loading zero-based
    #       preview slot 99, then regenerates it again after PE_RestoreCurrentPattern
    #       so the loader waveform glyphs are not replaced by pattern/numeric glyphs.
    Given the user has entered the sample-loader browser from F3
    When the user selects a sample and presses a key to preview it
    Then the loader waveform area is redrawn from the freshly loaded preview sample
    And it does not show stale pattern/numeric glyphs in the waveform rectangle

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Loading a sample silences only that slot, song continues
    # cite: IT_MUSIC.ASM Music_ReleaseSample passes the zero-based release slot
    #       to Music_SilenceSampleVoices before freeing sample pages.
    Given a song is playing
    When the user presses Enter on a sample file to load it into a slot
    Then only that slot's voices are silenced; the song does not stop

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The MIDI-sync mixer path is gated against a half-loaded header
    # cite: IT_K.ASM MIDISyncLoaderSuppress=1 while loading (MIDI_SetLoaderSuppress),
    #       cleared after (MIDI_ClearLoaderSuppress); the sync path skips at 2097/2120/2140
    #       so the mixer never reads a sample header mid-reload. commit 64fa1ce.
    Given an external MIDI clock/sync is driving playback during a load
    When a sample reload is in progress (MIDISyncLoaderSuppress set)
    Then the MIDI-sync mixer path is suppressed until the load completes (no hang)

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Loader preview defaults away from pattern channel 01
    # cite: IT_DISK.ASM D_PostLoadSampleWindow calls I_GetPlayChannel before
    #       Music_PlaySample, instead of hardcoding host channel 0.
    # cite: IT_I.ASM PlayChannel defaults to 63 (displayed channel 64);
    #       I_GetPlayChannel returns the same value used by F3/F4 sample-list
    #       keyjazz.
    Given the pattern is playing on channel 01
    When the user keyjazz-previews a sample in the loader browser
    Then the preview is played on displayed channel 64 by default
    And it does not overwrite the pattern event currently sounding on channel 01

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: MIDI notes can keyjazz the sample loader preview
    # cite: IT_DISK.ASM LSWindowKeys maps MIDI Note On/Off to LSWindow_MIDINote
    #       and LSWindow_MIDINoteOff via M_FunctionDivider MIDI compare code 6.
    # cite: IT_DISK.ASM LSWindow_MIDINote uses PE_TranslateMIDI, loads preview
    #       slot 99, then plays it through Music_PlaySample on I_GetPlayChannel.
    Given the user is in the sample-loader file browser
    When an external MIDI note-on arrives
    Then the highlighted sample is loaded into preview slot 99 and auditioned
    And MIDI note-off or velocity-zero silences only that preview slot
