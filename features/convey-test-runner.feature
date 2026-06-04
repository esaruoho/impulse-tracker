# =============================================================================
# WIKI PAGE / REPORT CARD: Convey test-runner — display the situation to a User,
#                          capture the verdict, route it back to the cards
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/convey-test-runner.session.md
#
# This is the conveyance LAYER of Convey, carded as a unit in its own right. Its
# principle is "displaying information to a User": it takes the generated test
# situation (the unverified fork scenarios) and CONVEYS it to a human tester one
# item at a time, then routes their works/failed verdict back into the cards'
# @grade tags -- so the human's hardware run becomes Convey-recorded truth without
# anyone hand-typing status anywhere (Convey Principle 1).
#
# Honest note: this card was written AFTER the tool (hwtest.py / the launcher) --
# a Convey miss. Convey Principle 2 says the card is the SEED, born with the code.
# Esa flagged it ("not done the Convey way; start from the .feature"); this card
# closes that gap and is now the seed the runner spawns from.
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE  : features/hwtest.py (the TUI), test-impulse-tracker (the repo-
#                  anchored launcher), and the verdict-routing into the cards +
#                  HW-FAILURES.md.
#   - THINKSPACE : the .session.md -- why a host-side TUI (the DOS box can't run
#                  it), why it routes to @hw-verified, why it is excluded from the
#                  hardware matrix (it is the tool, not a tracker behaviour).
#   - AREASPACE  : owns the conveyance of test status to/from the human; must NOT
#                  itself be a tracker feature graded on the @hw floor.
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - the script parses + runs (python3, no deps)
#   @runtime-verified - actually run: it displayed items and captured a verdict
#   @tool             - host-side Convey machinery, NOT an IT.EXE behaviour -> it
#                       carries NO @hw floor and is EXCLUDEd from STATUS/HARDWARE-TEST
#
# Source files linked back to this card (grep "features/convey-test-runner"):
#   features/hwtest.py            - the TUI: load_items / parse_card / the verdict
#                                   loop / flip_tag_to_hw_verified / write_failures / regen
#   test-impulse-tracker          - repo-anchored launcher (runs from any dir)
#   features/gen-status.py        - the generated matrix the runner advances
#   features/gen-hwtest.py        - the red-line checklist the runner walks
#
# Commit log (the ingest trail):
#   9ec40af  hwtest.py interactive hardware-test TUI
#   e63518b  repo-anchored ./test-impulse-tracker launcher
#   (this commit) card the runner the Convey way + exclude it from the matrices
#
# RESULT: direct to esaruoho/main, no PR. Triad: this .feature <-> .session.md <-> those commits.
#
# WATCH: (host-side python; no ASM symbols)
# =============================================================================

Feature: Convey test-runner conveys the test situation to a User and routes the verdict back
  As the human who flashes a build to real DOS hardware,
  I want a runner that shows me each unverified behaviour, takes my works/failed
  call (with a note when it fails), and folds that straight back into the cards,
  So that confirming what works costs no chat tokens and the generated status
  matrices advance themselves — the human run becomes Convey truth.

  # --- Principle: displaying information to a User ---------------------------

  @shipped @build-verified @runtime-verified @tool
  Scenario: It displays each unverified fork scenario's Given/When/Then to the tester
    # cite: features/hwtest.py load_items (fork + not @hw-verified, DOSBox-first)
    #       + the per-item print of card, title, steps, and DOSBox status
    Given fork scenarios that are not yet @hw-verified
    When the runner is launched
    Then it shows them one at a time -- card, scenario, the steps to perform, and
      whether DOSBox already confirmed it -- so the User knows exactly what to test

  @shipped @build-verified @runtime-verified @tool
  Scenario: It captures the User's verdict: works / failed (+ how) / skip / back / quit
    # cite: features/hwtest.py verdict loop; 'f' prompts "how did it fail?"
    Given an item is displayed
    When the User presses w / f / s / b / q
    Then works/skip are recorded, failed also captures a free-text note, and the
      verdict is saved after EVERY answer (resumable -- quit and rerun continues)

  # --- Routing the verdict back (Convey Principle 1: no hand-typed status) -----

  @shipped @build-verified @runtime-verified @tool
  Scenario: A "works" verdict flips that scenario to @hw-verified in its card
    # cite: features/hwtest.py flip_tag_to_hw_verified -- edits the scenario's tag
    #       line in the .feature (the SOURCE), not a status view
    Given the User marked a scenario "works"
    When the runner exits
    Then the scenario's @hw-untested becomes @hw-verified in its own card
    And STATUS.md / HARDWARE-TEST.md regenerate from the cards (never hand-typed)

  @shipped @build-verified @runtime-verified @tool
  Scenario: Failures are conveyed out as the single focused worklist
    # cite: features/hwtest.py write_features -> features/HW-FAILURES.md
    Given the User marked some scenarios "failed" with notes
    When the runner exits
    Then features/HW-FAILURES.md holds exactly those, with the notes -- the only
      thing the User sends back; passes need no words

  # --- The launcher (repo-anchored) ------------------------------------------

  @shipped @build-verified @runtime-verified @tool
  Scenario: The launcher runs from any directory
    # cite: test-impulse-tracker resolves the repo from its own path (symlink-safe)
    #       -> execs features/hwtest.py. Fixes the "No such file" from running it in ~.
    Given the user is in any directory
    When they run ~/work/impulse-tracker/test-impulse-tracker
    Then the runner starts against this repo's cards regardless of cwd

  # --- Boundary: it is the tool, not a tested tracker feature -----------------

  @shipped @build-verified @tool
  Scenario: The runner is excluded from the hardware test matrix
    # cite: features/gen-status.py + gen-hwtest.py + hwtest.py EXCLUDE sets list
    #       convey-test-runner.feature; it is host-side, the DOS box can't run it,
    #       so it carries no @hw floor and never appears as a thing to hardware-test
    Given the generated STATUS.md and HARDWARE-TEST.md
    When they are regenerated from the cards
    Then this runner card is not listed as a fork behaviour to verify on metal
