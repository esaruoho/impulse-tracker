# =============================================================================
# WIKI PAGE / REPORT CARD: WAV render keeps the music going (fast render + MIDI resume)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# Rendering a pattern to WAV while a song is playing used to mean a realtime-long
# silence (the render commandeers IT's single audio engine: unload the live
# driver, load the WAV-to-file driver, play the pattern into it). Two changes
# soften that to "barely a hiccup, then it resumes":
#   Option 2 -- the single-PATTERN render runs FASTER-THAN-REALTIME (tight
#     Music_Poll loop; WAVDRV mixes on demand), so the silence is a brief freeze.
#   Option 1 -- if a song was playing, the render snapshots its position and an
#     incoming MIDI clock/transport after the render RESUMES playback in place.
# (True simultaneous render+playback is NOT possible on IT's single engine --
# one active driver, shared mixer state. Documented, not attempted.)
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE  : this .feature + .session.md, PLUS the WAV_PlayDone tight-loop
#                  (IT_MUSIC), Music_ResumeAfterRender + WAV_Resume* state, and the
#                  F8-clock call site in IT_K's MIDISend.
#   - THINKSPACE : the .session.md -- why faster-than-realtime is possible (WAVDRV
#                  Poll has no timer), why true-simultaneous is a rewrite, and the
#                  read-only analysis behind the plan.
#   - AREASPACE  : owns the pattern-render pacing + the resume hook; must NOT
#                  change song-mode render (stays realtime/timer-paced), and must
#                  not claim simultaneous live+render audio.
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean; IT_MUSIC.asm + IT_K.asm Error/Warning = None
#   @runtime-untested - not yet run
#   @hw-untested      - not yet run on real DOS hardware
#   @known-limit      - a deliberately-not-done boundary, recorded honestly
#
# Source files linked back to this card (grep "features/wav-render-keep-playback"):
#   IT_MUSIC.ASM - Music_ToggleWAVRender WAV_PlayDone: WAV_SongMode gate ->
#                  WAV_SyncRenderLoop (tight Music_Poll until PlayMode==0) +
#                  close loop + inline WAV_LeaveMode; WAV_ResumeArmed/Order/Row
#                  snapshot at enter; Music_ResumeAfterRender (resume via
#                  Music_PlayPartSong)
#   IT_K.ASM     - MIDISendRTClock: calls Music_ResumeAfterRender (gated by
#                  MIDITransportEnable + MIDISyncLoaderSuppress)
#   SoundDrivers/WAVDRV.ASM - Poll (mixes on demand, "called as often as possible")
#
# Commit log (the ingest trail):
#   702727c  faster-than-realtime pattern render + MIDI-clock resume after
#   ed62137  standalone auto-resume at render-complete (no external clock needed)
#
# SESSION (the vibe record): features/wav-render-keep-playback.session.md
#
# RESULT: 702727c direct to esaruoho/main, no PR.
#
# WATCH: Music_ToggleWAVRender Music_Poll Music_ResumeAfterRender Music_PlayPartSong MIDISend
#
# Sibling: features/wav-render-reentry-guard.feature, features/wav-render-quicksave.feature.
# =============================================================================

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
  Scenario: Standalone Ctrl-O resumes on its own, with no external clock
    # cite: IT_MUSIC.ASM WAV_LeaveMode latches WAV_DoResumeOnLeave (only when
    #       single-pattern: not WAV_MultiMode, not WAV_SongMode, and armed), then
    #       calls Music_ResumeAfterRender just before WAV_ToggleDone -- after the
    #       live driver is back and the import is done. ; commit ed62137
    Given a song was playing and the user presses Ctrl-O (single-pattern render)
    And there is NO external MIDI clock feeding IT
    When the render finishes and the live driver is back
    Then playback resumes from the saved order/row on its own
    And a whole-song render or a multi-WAV sweep does NOT auto-resume this way

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
