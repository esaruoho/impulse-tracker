# =============================================================================
# WIKI PAGE / REPORT CARD: Alt-R = Replicate at Cursor (Paketti port)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/alt-r-replicate.session.md
#
# Pattern-editor power tool ported from Paketti / ztrackerprime: Alt-R tiles the
# current channel from the cursor downward. Alt-R and Shift-Alt-R arrive as the
# same keyword (1300h), so a dispatcher splits on the live shift state.
#
# Report-card legend (tags):
#   @shipped          - in origin/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @runtime-untested - NOT yet exercised by running IT.EXE and pressing the key
#
# Source files linked back to this card (grep "features/alt-r-replicate"):
#   IT_PE.ASM  PEFunction_AltR_Dispatch     (8275) split on Left/Right shift
#   IT_PE.ASM  PEFunction_ReplicateAtCursor (8308) tile current channel
#   IT_PE.ASM  PEFunction_ClearViews        (Shift-Alt-R = original Alt-R)
#   IT_PE.ASM  keymap entry 1300h (Alt-R) -> PEFunction_AltR_Dispatch (785)
#
# Commit log (the ingest trail):
#   d506486  Alt-R = Replicate at Cursor
#   aaada5e  Alt-R tile at row 0 + Shift-Alt-R = ClearViews (original Alt-R)
#
# RESULT (triad: .feature spec + .session convo + what shipped):
#   Feature delivery : d506486, aaada5e   (direct to esaruoho/main, no PR)
#   This card authored: this session (see RESULT-LOG / git log for this file)
#   Triad: this .feature <-> alt-r-replicate.session.md <-> those commits
#
# WATCH: PEFunction_AltR_Dispatch PEFunction_ReplicateAtCursor PEFunction_ClearViews
# RESULT-LOG >> (auto-maintained by .githooks/pre-commit / post-merge)
#
# IT.TXT source of truth: Alt-R historically = "clear all track views"; this fork
#   repurposes plain Alt-R to Replicate and keeps the old behaviour on Shift-Alt-R.
# =============================================================================

Feature: Alt-R replicate at cursor
  As someone filling a pattern channel with a repeating figure,
  I want Alt-R to tile the rows above the cursor down to the end of the channel,
  So that I can lay down a one- or few-row loop and stamp it across the pattern
  without copy/paste — while Shift-Alt-R keeps the original "clear track views".

  @shipped @build-verified
  Scenario: Alt-R and Shift-Alt-R are disambiguated by live shift state
    # cite: IT_PE.ASM PEFunction_AltR_Dispatch (8275) — both keys map to 1300h
    #       (Alt suppresses ASCII; Shift doesn't change R's scancode), so the
    #       dispatcher reads Left(02Ah)/Right(036h) shift via K_IsKeyDown
    Given the pattern editor with the keyword 1300h bound to the Alt-R dispatcher
    When the user presses Alt-R with no shift held
    Then control goes to PEFunction_ReplicateAtCursor
    When the user presses Alt-R with either shift held
    Then control goes to PEFunction_ClearViews (the original Alt-R behaviour)

  @shipped @build-verified @runtime-untested
  Scenario: Cursor above row 0 tiles the rows-above-cursor chunk downward
    # cite: IT_PE.ASM PEFunction_ReplicateAtCursor (8308); commit d506486
    # single-channel; empty source events copy through (exact tiling)
    Given the cursor is on Row R (R > 0) of the current channel
    Then the source chunk is rows 0..R-1 of that channel (length R)
    And rows R..MaxRow of the SAME channel are filled by repeating that chunk
    And empty events are copied through as-is (mirror semantics, exact tiling)

  @shipped @build-verified @runtime-untested
  Scenario: Cursor on row 0 tiles row 0 down the whole channel
    # cite: IT_PE.ASM PEFunction_ReplicateAtCursor row==0 branch (~8316); aaada5e
    Given the cursor is on Row 0 of the current channel
    Then the source chunk is row 0 itself (length 1)
    And rows 1..MaxRow are filled with copies of row 0

  @shipped @build-verified
  Scenario: No-op at the pattern edges
    # cite: IT_PE.ASM PEFunction_ReplicateAtCursor guards (8310-8312)
    Given the cursor is past MaxRow, or the destination start is past MaxRow
      (e.g. a 1-row pattern)
    Then Replicate does nothing (clean no-op)

  @shipped @build-verified @runtime-untested
  Scenario: Shift-Alt-R preserves the original "clear all track views"
    # cite: IT_PE.ASM PEFunction_ClearViews; commit aaada5e kept this on Shift-Alt-R
    Given the pattern editor
    When the user presses Shift-Alt-R
    Then all track views are cleared (the pre-fork Alt-R behaviour), unchanged
