# Pure Gherkin test extracted from features/alt-r-replicate.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/alt-r-replicate.feature

Feature: Alt-R replicate at cursor
  As someone filling a pattern channel with a repeating figure,
  I want Alt-R to tile the rows above the cursor down to the end of the channel,
  So that I can lay down a one- or few-row loop and stamp it across the pattern
  without copy/paste — while Shift-Alt-R does the same across the WHOLE pattern
  (all channels).

  @shipped @build-verified @hw-verified
  Scenario: Alt-R and Shift-Alt-R are disambiguated by live shift state
    # cite: IT_PE.ASM PEFunction_AltR_Dispatch — both keys map to 1300h
    #       (Alt suppresses ASCII; Shift doesn't change R's scancode), so the
    #       dispatcher reads Left(02Ah)/Right(036h) shift via K_IsKeyDown
    # HW 2026-06-04: Esa confirmed Alt-R (replicate track) works on real hardware.
    Given the pattern editor with the keyword 1300h bound to the Alt-R dispatcher
    When the user presses Alt-R with no shift held
    Then control goes to PEFunction_ReplicateAtCursor (replicate current TRACK)
    When the user presses Alt-R with either shift held
    Then control goes to PEFunction_ReplicatePatternAtCursor (replicate whole PATTERN)

  @shipped @build-verified @runtime-verified @hw-verified
  Scenario: Cursor above row 0 tiles the rows-above-cursor chunk downward
    # cite: IT_PE.ASM PEFunction_ReplicateAtCursor (8308); commit d506486
    # single-channel; empty source events copy through (exact tiling)
    Given the cursor is on Row R (R > 0) of the current channel
    Then the source chunk is rows 0..R-1 of that channel (length R)
    And rows R..MaxRow of the SAME channel are filled by repeating that chunk
    And empty events are copied through as-is (mirror semantics, exact tiling)

  @shipped @build-verified @runtime-verified @hw-verified
  Scenario: Cursor on row 0 tiles row 0 down the whole channel
    # cite: IT_PE.ASM PEFunction_ReplicateAtCursor row==0 branch (~8316); aaada5e
    Given the cursor is on Row 0 of the current channel
    Then the source chunk is row 0 itself (length 1)
    And rows 1..MaxRow are filled with copies of row 0

  @shipped @build-verified @hw-untested
  Scenario: No-op at the pattern edges
    # cite: IT_PE.ASM PEFunction_ReplicateAtCursor guards (8310-8312)
    Given the cursor is past MaxRow, or the destination start is past MaxRow
      (e.g. a 1-row pattern)
    Then Replicate does nothing (clean no-op)

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Shift-Alt-R replicates the whole PATTERN at cursor
    # Changed 2026-06-04 per Esa's hardware feedback: Shift-Alt-R was the stock
    # ClearViews ("does nothing" to him); he wanted it to replicate the current
    # PATTERN at cursor. PEFunction_ReplicatePatternAtCursor tiles full 320-byte
    # rows across all 64 channels with the same rule as the per-channel Alt-R.
    # cite: IT_PE.ASM PEFunction_ReplicatePatternAtCursor; commit 5fb263b
    # (ClearViews is no longer bound to a key.)
    Given the cursor is on Row R of the pattern
    When the user presses Shift-Alt-R
    Then if R > 0, rows 0..R-1 (ALL channels) tile down to fill rows R..MaxRow
    And if R == 0, row 0 (all channels) tiles down the whole pattern
