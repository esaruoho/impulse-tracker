# Pure Gherkin test extracted from features/f6-play-from-order-list-row.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/f6-play-from-order-list-row.feature

Feature: Order List F6 loops the selected order's pattern; F7 plays from it at the cursor row
  As someone arranging a song in the F11 Order List,
  I want F6 to loop the pattern at the order row I selected, and F7 to start
  playback from that order at the row my edit cursor is on,
  So that I can audition any order's pattern in place, and resume the song from
  any order at the exact row I was working on.

  # --- F6: loop the selected order's pattern ---------------------------------

  @shipped @build-verified @runtime-untested
  Scenario: F6 loops the pattern at the selected order row
    # cite: IT_G.ASM Glbl_F6: Cmp CurrentMode,11 -> Call PE_OrderListLoopPattern
    # cite: IT_PE.ASM PE_OrderListLoopPattern: Order -> pattern via SongSeg:100h+Order;
    #       Music_GetPattern word[1] = #rows; Music_PlayPattern(pat, rows, 0)
    # cite: commit 5b37353
    Given the user is in the Order List (F11, CurrentMode==11)
    And the cursor is on order row N, whose pattern is P
    When the user presses F6
    Then pattern P plays, LOOPING (not advancing through the order list)
    And the row count comes from P's own header, so it loops correctly

  @shipped @build-verified
  Scenario: F6 outside the Order List keeps its stock "play current pattern"
    # cite: the CurrentMode==11 gate; the JNE branch is the original
    #       PE_GetCurrentPattern -> Music_PlayPattern path
    Given the user is on any screen other than the Order List
    When the user presses F6
    Then the editor's current pattern is played (stock behaviour)

  @shipped @build-verified
  Scenario: A skip/end marker order slot is a no-op
    # cite: PE_OrderListLoopPattern: Cmp AL,254 / JAE done (0FEh ++ / 0FFh end)
    Given the selected order row holds a "++" (254) or end (255) marker
    When the user presses F6
    Then nothing plays (there is no pattern at that slot)

  # --- F7: Playback from Cursor (selected order, current row) -----------------

  @shipped @build-verified @runtime-untested
  Scenario: F7 plays from the SELECTED order at the current edit row
    # Esa's spec: on row 048 of pattern 003, navigate the order list to a row
    # whose pattern is 008, press F7 -> playback starts at that order, row 048.
    # cite: IT_PE.ASM PE_F7: Cmp CurrentMode,11 -> Music_PlayPartSong(Order, Row)
    # cite: commit 5b37353
    Given the edit cursor is on row R (e.g. 048, set in some pattern)
    And the user is in the Order List with the cursor on order row N
    When the user presses F7
    Then Music_PlayPartSong starts playback at order N, row R

  @stock @build-verified
  Scenario: F7 outside the Order List keeps its stock from-mark behaviour
    # cite: PE_F7_Stock branch = the original PlayMark / current-pattern+row logic
    Given the user is on the Pattern Editor (not the Order List)
    When the user presses F7
    Then playback starts from the playback mark (or current pattern+row), as before
