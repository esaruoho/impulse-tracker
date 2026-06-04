# Pure Gherkin test extracted from features/wav-render-keep-playback.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/wav-render-keep-playback.feature

Feature: WAV render keeps the music going (fast pattern render + MIDI-clock resume)
  As someone rendering a pattern to WAV while a tune plays,
  I want the render to barely interrupt playback and the song to resume,
  So that bouncing a pattern doesn't kill my groove for seconds at a time.

  # --- Option 2: faster-than-realtime pattern render -------------------------

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: A single-pattern render runs faster than realtime (brief freeze)
    # cite: IT_MUSIC.ASM WAV_PlayDone -> WAV_SyncRenderLoop: tight Music_Poll loop
    #       until PlayMode==0, instead of one buffer per main-loop frame
    # cite: SoundDrivers/WAVDRV.ASM Poll mixes on demand (no timer/DMA wait)
    # cite: commit 702727c
    Given a song is playing
    When the user triggers a single-PATTERN render (Shift-Right at the order edge)
    Then the pattern renders as fast as the CPU can mix -- a brief freeze
    And NOT a silence as long as the pattern would take to play in realtime

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Whole-song render stays realtime
    # cite: WAV_PlayDone gates on WAV_SongMode; song mode (Music_PlaySong arms a
    #       timer) keeps the async/realtime finalize path
    Given a whole-song WAV render (F10 WAV/MWAV)
    When it runs
    Then it stays realtime (timer-paced), unchanged by the fast-pattern path

  # --- Option 1: resume after the render -------------------------------------

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: A song that was playing resumes after the render, on the next MIDI clock
    # cite: IT_MUSIC.ASM render enter snapshots WAV_ResumeArmed + CurrentOrder/Row
    #       (before Music_Stop); Music_ResumeAfterRender -> Music_PlayPartSong
    # cite: IT_K.ASM MIDISendRTClock calls Music_ResumeAfterRender
    Given a song was playing when the render started
    When the render finishes and the live driver is back
    And an external MIDI clock (or Start/Continue) arrives
    Then playback resumes from the saved order/row

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: No resume if nothing was playing
    # cite: WAV_ResumeArmed is only set when PlayMode != 0 at render enter
    Given playback was stopped when the render started
    When the render finishes and clocks arrive
    Then nothing auto-starts (resume is armed only if a song was playing)

  # --- The boundary, recorded honestly ---------------------------------------

  @known-limit
  Scenario: True simultaneous live-audio + render is NOT done
    # cite: render unloads the live driver (Music_UnloadDriver) -- one active
    #       driver slot; mixer voice state (SlaveChannelInformationTable) is global.
    #       A genuine parallel render needs a second isolated mixer = a rewrite.
    Given IT's single audio engine
    When a render runs
    Then live audio cannot literally continue DURING the render
    And this feature gives "brief freeze + resume after" as the achievable best
