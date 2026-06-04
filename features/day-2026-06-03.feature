# =============================================================================
# WIKI PAGE / REPORT CARD: Day 2026-06-03 — exact changes to esaruoho/impulse-tracker
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/session-2026-06-03-multitimbral-and-whitelabel.session.md
#   (today spanned MULTIPLE concurrent sessions — transcripts 1fa213d0,
#    8fdac3f9, 227bcb50, bfba3a95; each feature card links its own session.
#    This day card is the git-derived rollup, not one conversation.)
#
# Built straight from git: 33 commits on origin/main, 09:04–13:11 UTC, 2026-06-03.
# Grouped into (A) things a user would notice in IT.EXE, (B) the self-documenting
# report-card system + tooling (no IT.EXE behaviour change), (C) the release.
#
# Report-card legend (tags):
#   @build-verified - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @hw-untested    - behaviour NOT yet exercised on real DOS hardware
#   @shipped        - committed to origin/main (or published as a release)
#   @verified       - checked against the live GitHub state this session
#
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
# =============================================================================

Feature: Day 2026-06-03 — what changed in impulse-tracker
  As the maintainer, I want the exact day's changes as graded, cited claims,
  so "what did we do today" is answerable from git, not memory.

  # ---- A. Behaviour changes to IT.EXE (user-visible) -----------------------

  @shipped @build-verified @hw-untested
  Scenario: Samples->Instruments envelope retention re-merged
    # cite: 9493101 (Merge PR #3 retain-envelopes-samples-to-instruments, 09:04)
    # The feature reverted on 06-02 for EMM386 #12 crashes came back via PR #3,
    # now IMPI-gated (F_SetControlInstrument / Music_InstrumentIsReal).
    Given F12 Samples->Instruments with custom envelopes
    Then real instruments keep their envelopes instead of being wiped
    And crash-free operation is @hw-untested (the original bug was hardware-only)

  @shipped @build-verified @hw-untested
  Scenario: WAV render filenames are clock-named
    # cite: be595b2 (.WAV extension, 09:27) ; 74c3fe8 (LL<HHMMSS>.WAV, 09:42)
    Given a single-pattern Quicksave WAV render
    Then the file is named LL<HHMMSS>.WAV (e.g. LL163422.WAV), not PTN0003.000

  @shipped @build-verified @hw-untested
  Scenario: Shift-F4 multitimbral MIDI-In (this conversation)
    # cite: 8c32fd2 (10:11) ; card features/midi-in-multitimbral.feature
    Given samples loaded
    When the user presses Shift-F4
    Then it cycles: map samples to MIDI-In 01-16 -> 96 (6 banks) -> reset to 16
    And a Shift-F1 button toggles the live router on/off
    And live note routing is @hw-untested (DOSBox-X cannot inject MIDI)

  @shipped @build-verified @hw-untested
  Scenario: WAV render re-entry guard
    # cite: c9ff6b9 (10:11-era, 12:31) ; card features/wav-render-reentry-guard.feature
    Given a WAV render is already active
    When the user fires the render gesture a second time
    Then it early-stops to Quicksave instead of wedging IT

  @shipped @build-verified @hw-untested
  Scenario: Scroll Lock on F3/F4 lists opens Pattern Editor with Follow Mode
    # cite: 91dfc0b (12:35) ; card features/scrolllock-follow-from-lists.feature
    Given the F3 sample list or F4 instrument list
    When the user presses Scroll Lock
    Then the Pattern Editor opens with Follow Mode on

  # ---- B. The self-documenting report-card system + tooling ----------------

  @shipped @hw-untested
  Scenario: The report-card wiki + self-maintaining hooks landed
    # cite cards: f2/f3/f4/f11/f12, midi-in-multitimbral, midi-realtime-sync,
    #   wav-render-quicksave, wav-render-reentry-guard, scrolllock-follow,
    #   session-changes-codespace (meta) + their .session.md siblings + INDEX.md
    # cite hooks: 1f47584 + 24279ca (post-merge RESULT-LOG), 994b241 (pre-commit stamp)
    # cite tooling: POWER-PROOF (1654bc3), RUNNER design (08be4ba)
    Given the features/ directory
    Then every feature has a graded, source-linked, session-backed report card
    And a post-merge + pre-commit hook keeps each card's RESULT-LOG current from git
    And no IT.EXE behaviour changed (cards/hooks/docs only)

  # ---- C. The release ------------------------------------------------------

  @shipped @verified @hw-untested
  Scenario: v2.354-2026-06-03 was published with the day's features
    # cite: GitHub release v2.354-2026-06-03, asset IT-V2.354-2026-06-03.zip,
    #   built 10:04 UTC from commit b9a5a71 (8c32fd2 proven in its history)
    Given the Package DOS release zip workflow ran on today's main
    Then the Latest release on esaruoho/impulse-tracker is v2.354-2026-06-03
    And its zip bundles IT.EXE + 42 drivers and contains the multitimbral feature
    And it carries no IT.CFG, by choice
