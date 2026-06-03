# =============================================================================
# WIKI PAGE / REPORT CARD: Multi-WAV (per-channel + whole-song render)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/multi-wav.session.md
#
# Render-to-disk power tools beyond the single Ctrl-O:
#   - Shift-Alt-M  : render the CURRENT pattern once per non-empty channel
#   - F10 "WAV"    : render the WHOLE song to one WAV
#   - F10 "MWAV"   : render the WHOLE song, one WAV per channel
# Shift-Alt-M needs a Shift+Alt keymap path that IT's keymap couldn't express,
# so K_TranslateCondition11 was added (emits 3232h; plain Alt-M = 3200h stays
# block-mix).
#
# !!! TESTING STATUS — READ FIRST !!!
#   This feature is NOT runtime-tested. It is in origin/main and assembles/links
#   clean, but it has NOT been exercised by running IT.EXE in DOSBox-X and
#   confirming the per-channel / whole-song WAVs are actually written correctly.
#   Every behaviour scenario below is graded @runtime-untested ON PURPOSE.
#   Do not treat this card as verification. (Esa, 2026-06-03: "multi-wav is not
#   tested so it should say it.")
#
# Report-card legend (tags):
#   @shipped          - in origin/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @runtime-untested - NOT run in IT.EXE; the on-disk result is UNCONFIRMED
#
# Source files linked back to this card (grep "features/multi-wav"):
#   IT_PE.ASM    PEFunction_StartMultiWAVKey (8267) Shift-Alt-M -> StartMultiWAV
#   IT_PE.ASM    PE_ChannelIsEmpty           (8206) skip empty channels
#   IT_MUSIC.ASM Music_StartMultiWAV               per-channel sweep state machine
#   IT_MUSIC.ASM Music_StartFullSongWAV      (2621) F10 "WAV" whole-song single
#   IT_MUSIC.ASM Music_StartFullSongMWAV     (2859) F10 "MWAV" whole-song per-chan
#   IT_K.ASM     K_TranslateCondition11      (1457) Shift+Alt keymap -> 3232h
#
# Commit log (the ingest trail):
#   9fb5ac1  Multi-WAV + F10 MWAV + F10 WAV + Shift+Alt keymap condition
#
# RESULT (triad: .feature spec + .session convo + what shipped):
#   Feature delivery : 9fb5ac1   (direct to esaruoho/main, no PR)
#   This card authored: this session (see RESULT-LOG / git log for this file)
#   Triad: this .feature <-> multi-wav.session.md <-> 9fb5ac1
#
# WATCH: PEFunction_StartMultiWAVKey Music_StartMultiWAV Music_StartFullSongWAV Music_StartFullSongMWAV K_TranslateCondition11 PE_ChannelIsEmpty
# RESULT-LOG >> (auto-maintained by .githooks/pre-commit / post-merge)
# =============================================================================

Feature: Multi-WAV render
  As someone bouncing a tune to stems or a mix,
  I want to render the current pattern per channel, or the whole song as one WAV
  or as per-channel stems,
  So that I can take Impulse Tracker output into another DAW —
  NOTE: this whole feature is shipped but NOT yet runtime-tested (see header).

  @shipped @build-verified @runtime-untested
  Scenario: Shift-Alt-M renders the current pattern per non-empty channel
    # cite: IT_PE.ASM PEFunction_StartMultiWAVKey (8267) -> Music_StartMultiWAV;
    #       PE_ChannelIsEmpty (8206) skips channels with no triggered note (0..119);
    #       keymap 3232h via K_TranslateCondition11; commit 9fb5ac1
    # UNTESTED: not confirmed by running IT.EXE that one WAV per channel is written
    Given the pattern editor on a pattern with several non-empty channels
    When the user presses Shift-Alt-M
    Then each non-empty channel is rendered to its own WAV (empty channels skipped)
    And plain Alt-M still does block-mix (3200h), unchanged

  @shipped @build-verified @runtime-untested
  Scenario: F10 "WAV" renders the whole song to a single WAV
    # cite: IT_MUSIC.ASM Music_StartFullSongWAV (2621); commit 9fb5ac1
    # UNTESTED: on-disk whole-song WAV not confirmed by running IT.EXE
    Given a loaded song
    When the user activates the F10 "WAV" button
    Then the entire song is rendered to one WAV in the render folder

  @shipped @build-verified @runtime-untested
  Scenario: F10 "MWAV" renders the whole song as per-channel stems
    # cite: IT_MUSIC.ASM Music_StartFullSongMWAV (2859); commit 9fb5ac1
    # UNTESTED: per-channel stem set not confirmed by running IT.EXE
    Given a loaded song
    When the user activates the F10 "MWAV" button
    Then the song is rendered once per non-empty/non-muted channel (stems)

  @shipped @build-verified
  Scenario: The Shift+Alt keymap path exists (this part IS structural)
    # cite: IT_K.ASM K_TranslateCondition11 (1457) emits 3232h for Shift+Alt-M
    # This is a build-time fact (the translate path assembles), distinct from the
    # runtime render behaviour above.
    Given IT's keymap could not previously express a Shift+Alt combo for M
    Then K_TranslateCondition11 supplies one, mapping Shift-Alt-M to 3232h

  @runtime-untested
  Scenario: WHAT WOULD VERIFY THIS CARD (the test that has not been run)
    # The honest "definition of done" for flipping the grades above to verified.
    Given IT.EXE running in DOSBox-X with a multi-channel tune loaded
    When Shift-Alt-M / F10 WAV / F10 MWAV are each triggered
    Then the expected WAV file(s) appear in the render folder, non-zero, and play
    And only THEN do the scenarios above lose their @runtime-untested tag
