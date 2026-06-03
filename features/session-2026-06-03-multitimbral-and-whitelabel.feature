# =============================================================================
# WIKI PAGE / REPORT CARD: Conversation 2026-06-03 (session 1fa213d0)
# Multitimbral MIDI-In + Report-Card whitelabel + v2.354 release
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/session-2026-06-03-multitimbral-and-whitelabel.session.md
#
# This is a CONVERSATION-SCOPED ledger card: the unit it describes is "what one
# conversation accomplished", as graded, verifiable claims. It does not replace
# the per-feature cards (it cross-links them); it is the rolled-up answer to
# "what did we get done in this session, and can each claim be checked?"
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE  = the artifacts this conversation produced (the midi-in triad,
#                  the global rule, the skill, the release) + the check script
#                  features/check-session-2026-06-03.sh that grades the claims.
#   - THINKSPACE = the .session sibling (the arc, the AskUserQuestions, the
#                  breach-and-fix on the missing session leg).
#   - AREASPACE  = this card OWNS the accounting of the conversation. It does NOT
#                  own feature correctness (each feature's own card does), and it
#                  must NOT grade the live-routing claim up until hardware proves it.
#
# Report-card legend (tags):
#   @shipped         - committed/pushed to origin/main (or published as a release)
#   @repo-checkable  - check-session-2026-06-03.sh verifies this from the repo
#   @out-of-repo     - true but lives in ~/.claude (rule/skill); not repo-checkable
#   @hw-untested     - NOT yet exercised on real MIDI hardware (honest carry)
#
# Innards / cross-links:
#   features/midi-in-multitimbral.feature        - the MIDI feature's own card
#   features/check-session-2026-06-03.sh         - the runnable gherkin checks
#   ~/.claude/CLAUDE.md  §"BUILDING ANY UNIT EMITS ITS REPORT CARD"  (the rule)
#   ~/.claude/skills/report-card/SKILL.md        - the reusable skill
#   GitHub release v2.354-2026-06-03             - the delivered zip
#
# Commit log (this conversation, session 1fa213d0):
#   8c32fd2  Shift-F4 multitimbral 3-state cycle (16->96->16) + Shift-F1 toggle
#   7f5b2ff  midi-in-multitimbral.feature report card + source back-links
#   1abb7d9  register the spawning session for the midi-in card (the missing seed)
#   73c3c2a  backfill click-back block into the F-key session
#   64c4636  enroll midi-in-multitimbral card into the self-maintaining set
#   (release) v2.354-2026-06-03 published via the Package DOS release zip workflow
#
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
# =============================================================================

Feature: Conversation 2026-06-03 — what we accomplished
  As the maintainer of the esaruoho/impulse-tracker fork,
  I want a graded, checkable record of what one conversation shipped,
  So that the accomplishment is provable from the repo, not just remembered.

  @shipped @repo-checkable
  Scenario: The Shift-F4 multitimbral MIDI feature shipped
    # cite: features/midi-in-multitimbral.feature ; commit 8c32fd2
    Given the repository at origin/main
    Then features/midi-in-multitimbral.feature exists and cites commit 8c32fd2
    And it documents the Shift-F4 3-state cycle (map 01-16 -> 96 -> reset)
    And it documents the Shift-F1 router on/off toggle

  @shipped @out-of-repo
  Scenario: The report-card pattern became a reusable system
    # cite: ~/.claude/CLAUDE.md rule + ~/.claude/skills/report-card/SKILL.md
    # (out-of-repo: lives in the user's ~/.claude, so this card cannot self-check it)
    Given this conversation
    Then the report-card pattern was promoted to a global rule in ~/.claude/CLAUDE.md
    And a reusable cross-domain report-card skill was created
    And the principle was whitelabeled (code / electronics / API skins)

  @shipped @repo-checkable
  Scenario: Every report card carries its spawning session
    # cite: the SESSION >> line required in each card header
    Given every features/*.feature card in the repo
    Then each one contains a "SESSION >>" link to its .session.md

  @shipped @repo-checkable
  Scenario: Every session is clickable, not just summarized
    # cite: the "How to get back" / transcript block required in each session
    Given every features/*.session.md in the repo
    Then each one contains a transcript reference (a session ID / resume path)

  @shipped @repo-checkable
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
