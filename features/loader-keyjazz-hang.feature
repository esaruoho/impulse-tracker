# =============================================================================
# WIKI PAGE / REPORT CARD: F3/F4 loader keyjazz no longer kills playback
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/loader-keyjazz-hang.session.md
#
# Auditioning samples (keyjazz) inside the F3/F4 sample-loader file browser, and
# loading a sample, used to call Music_Stop -- which killed the whole song. The
# fork silences only the preview / target-slot voices (Music_SilenceSampleVoices)
# so the song keeps playing, and gates the MIDI-sync mixer path with
# MIDISyncLoaderSuppress so it never reads a half-loaded sample header mid-reload.
#
# Report-card legend (tags):
#   @stock            - upstream Impulse Tracker behaviour (the pre-fork bug)
#   @shipped          - fork addition, in origin/main
#   @build-verified   - the code is in main; main assembles (cards are docs, no rebuild)
#   @hw-untested      - NOT run on real DOS hardware (DOSBox-X is emulation)
#   @runtime-untested - NOT yet exercised against a running IT.EXE
#
# Source files linked back to this card:
#   IT_MUSIC.ASM  Music_SilenceSampleVoices (175) -- silence one slot's voices, keep song
#   IT_K.ASM      MIDISyncLoaderSuppress (127); MIDI_SetLoaderSuppress (~2257) /
#                 MIDI_ClearLoaderSuppress (~2270); guard checks (2097, 2120, 2140)
#
# Commit log (the ingest trail):
#   a44c41b  Music_SilenceSampleVoices (keep playback alive across reloads)
#   ec91331  F3 loader keyjazz hang VRAM markers (triage)
#   64fa1ce  F3 loader keyjazz hang fix via MIDISyncLoaderSuppress
#
# RESULT (triad: .feature spec + .session convo + what shipped):
#   Feature delivery : a44c41b, ec91331, 64fa1ce  (direct to esaruoho/main, no PR)
#   Triad: this .feature <-> loader-keyjazz-hang.session.md <-> those commits
#
# WATCH: Music_SilenceSampleVoices MIDISyncLoaderSuppress MIDI_SetLoaderSuppress MIDI_ClearLoaderSuppress
# RESULT-LOG >> (auto-maintained by .githooks/pre-commit / post-merge)
#
# IT.TXT source of truth: CLAUDE.md "Loader screens (after F9)" table, status as of a44c41b.
# =============================================================================

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
    # cite: IT_MUSIC.ASM Music_SilenceSampleVoices -- preview uses slot 99; only slot-99
    #       voices fall silent (the 200h voice-off sentinel), every other channel plays on.
    # cite: commit a44c41b
    Given a song is playing and the user is in the sample-loader file browser
    When the user keyjazzes a note to preview a sample
    Then only the preview (slot 99) voice is silenced; the song keeps playing

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Loading a sample silences only that slot, song continues
    # cite: Music_SilenceSampleVoices(target slot) replaces the old Music_Stop calls
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
