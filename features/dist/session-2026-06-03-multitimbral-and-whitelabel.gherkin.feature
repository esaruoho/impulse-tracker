# Pure Gherkin test extracted from features/session-2026-06-03-multitimbral-and-whitelabel.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/session-2026-06-03-multitimbral-and-whitelabel.feature

Feature: Conversation 2026-06-03 — what we accomplished
  As the maintainer of the esaruoho/impulse-tracker fork,
  I want a graded, checkable record of what one conversation shipped,
  So that the accomplishment is provable from the repo, not just remembered.

  @shipped @repo-checkable @hw-untested
  Scenario: The Shift-F4 multitimbral MIDI feature shipped
    # cite: features/midi-in-multitimbral.feature ; commit 8c32fd2
    Given the repository at origin/main
    Then features/midi-in-multitimbral.feature exists and cites commit 8c32fd2
    And it documents the Shift-F4 3-state cycle (map 01-16 -> 96 -> reset)
    And it documents the Shift-F1 router on/off toggle

  @shipped @out-of-repo @hw-untested
  Scenario: The report-card pattern became a reusable system
    # cite: ~/.claude/CLAUDE.md rule + ~/.claude/skills/report-card/SKILL.md
    # (out-of-repo: lives in the user's ~/.claude, so this card cannot self-check it)
    Given this conversation
    Then the report-card pattern was promoted to a global rule in ~/.claude/CLAUDE.md
    And a reusable cross-domain report-card skill was created
    And the principle was whitelabeled (code / electronics / API skins)

  @shipped @repo-checkable @hw-untested
  Scenario: Every report card carries its spawning session
    # cite: the SESSION >> line required in each card header
    Given every features/*.feature card in the repo
    Then each one contains a "SESSION >>" link to its .session.md

  @shipped @repo-checkable @hw-untested
  Scenario: Every session is clickable, not just summarized
    # cite: the "How to get back" / transcript block required in each session
    Given every features/*.session.md in the repo
    Then each one contains a transcript reference (a session ID / resume path)

  @shipped @repo-checkable @hw-untested
  Scenario: The DOS release was delivered
    # cite: GitHub release v2.354-2026-06-03 + its IT-V2.354-2026-06-03.zip asset
    Given the Package DOS release zip workflow ran on this conversation's main
    Then a release tagged v2.354-2026-06-03 exists with a .zip asset
    And the zip bundles IT.EXE + the sound drivers (no IT.CFG, by choice)

  @shipped @hw-untested
  Scenario: The live MIDI routing still needs hardware proof
    # cite: features/midi-in-multitimbral.feature @hw-untested scenarios
    # Honest carry-forward: built + shipped, but DOSBox-X cannot inject MIDI,
    # so whether incoming notes actually sound is unconfirmed.
    Given the multitimbral feature is shipped and enabled
    When incoming MIDI notes arrive on channels 01-16
    Then they SHOULD trigger the matching instruments — unverified until tested
      on the real DOS machine with a MIDI keyboard
