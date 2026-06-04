# =============================================================================
# WIKI PAGE / REPORT CARD: Shift-F4 also auto-builds a drumkit (instrument 01, MIDI ch 10)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# Shift-F4's multitimbral Create step now ALSO builds, automatically, a drumkit
# instrument at slot 01 (the FIRST instrument): every sample slot mapped to a key (C-0 -> sample 01,
# C#0 -> 02, ...), responding to MIDI channel 10. Separate from the 02-17
# multitimbral set; the 3-state cycle (expand-96 / reset) never touches it.
#
# WHAT THIS CARD SPAWNS (generative SEED):
#   - CODESPACE  : this .feature + .session.md, PLUS MCMI_BuildDrumkit (the
#                  slot-01 builder) and the one call added to
#                  Music_CreateMIDIInInstruments' Create step.
#   - THINKSPACE : the .session.md -- why slot 01 (FIRST, visible; Esa's relocation from 99),
#                  why fixed pitch C-5 (a real drumkit), and Esa's "00 instrument,
#                  automatic, not touched by the other 3-state Shift-F4" framing.
#   - AREASPACE  : owns the drumkit build at slot 01 + multitimbral shift to 02-17; must NOT change the
#                  01-16 multitimbral set, expand-96, or reset.
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean; IT_MUSIC.asm Error/Warning = None
#   @runtime-verified - exercised in DOSBox-X
#   @runtime-untested - not yet run in emulation
#   @hw-untested      - not yet run on real DOS hardware (this is what HARDWARE-TEST tracks)
#
# Source files linked back to this card (grep "features/shift-f4-drumkit"):
#   IT_MUSIC.ASM - MCMI_BuildDrumkit (slot 01: [DI+1Fh]=10 MIDI ch; name at +20h;
#                  note table at +40h, entry = [60, sample]); called from
#                  Music_CreateMIDIInInstruments MCMI_Done; MCMI_DrumName data
#   IT_G.ASM     - Glbl_Shift_F4 Create state (calls Music_CreateMIDIInInstruments)
#
# Commit log (the ingest trail):
#   f94f63c  drumkit slot 99 (first cut) -> dee41bd moved to slot 01, multitimbral 02-17
#
# SESSION (the vibe record): features/shift-f4-drumkit.session.md
#
# RESULT: Feature delivery f94f63c direct to esaruoho/main, no PR.
#
# WATCH: MCMI_BuildDrumkit Music_CreateMIDIInInstruments Music_ClearInstrument Glbl_Shift_F4
#
# Sibling: features/midi-in-multitimbral.feature (the 01-16 set this rides with);
#          features/shift-f4-enters-instrument-mode.feature.
# =============================================================================

Feature: Shift-F4 auto-builds a drumkit instrument alongside the 01-16 multitimbral set
  As a musician setting up a multitimbral MIDI rig,
  I want Shift-F4 to also create one drumkit instrument that maps every sample to
  a key on MIDI channel 10,
  So that, in the same gesture that builds my 16 single-sample parts, I get a
  ready-to-play kit where each key fires a different sample.

  @shipped @build-verified @runtime-verified @hw-verified
  # RUNTIME-VERIFIED 2026-06-04 (Esa): "shift-f4 drumkit works pretty well" --
  # overall create/build confirmed working live; the granular sub-behaviours
  # below (MIDI ch10 response, fixed-pitch playback) not individually vetted yet.
  Scenario: Shift-F4 Create builds the drumkit (01) + the 16 parts (02-17)
    # cite: IT_MUSIC.ASM Music_CreateMIDIInInstruments MCMI_Done -> Call MCMI_BuildDrumkit
    # cite: commit f94f63c
    Given the user has samples loaded
    When the user confirms the Shift-F4 "create multitimbral" build
    Then the 16 multitimbral parts are built at instruments 02-17
    And a drumkit instrument is also built, with no extra interaction

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The drumkit maps each sample slot to a successive key
    # cite: MCMI_BuildDrumkit note table at [DI+40h]: note i -> sample (i+1) for
    #       i = 0..98; notes 99..119 -> no sample
    Given the drumkit instrument was built
    When the user plays it from C-0 upward
    Then C-0 triggers sample 01, C#0 triggers sample 02, ... each key a new sample
    And keys past the 99th sample produce no sound

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The drumkit responds to MIDI channel 10
    # cite: MCMI_BuildDrumkit sets [ES:DI+1Fh] = 10 (the per-instrument MIDI-in channel)
    Given the multitimbral router is enabled
    When MIDI notes arrive on channel 10
    Then they are routed to the drumkit instrument

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Each pad plays its sample at fixed base pitch (C-5), not transposed
    # cite: MCMI_BuildDrumkit writes note byte = 60 (C-5) for every entry, so the
    #       triggering key does not transpose the sample -- a real drumkit
    Given the drumkit instrument
    When any key fires its mapped sample
    Then the sample plays at C-5 (its base rate), regardless of which key

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The 3-state Shift-F4 cycle never touches the drumkit
    # cite: drumkit is at slot 01; multitimbral parts at 02-17; expand fills
    #       02-97, reset clears 18-97 -- both leave slot 01 alone.
    Given the drumkit was built at slot 01
    When the user presses Shift-F4 again to expand, then again to reset
    Then the drumkit at slot 01 is unchanged
    And only the 02-97 multitimbral slots are rebuilt/cleared
