# =============================================================================
# WIKI PAGE / REPORT CARD: Order List F6 / F7 play the SELECTED order row
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# In the F11 Order List, F6 LOOPS the pattern at the selected order row, and F7
# ("Playback from Cursor") plays from the selected order at the current edit row.
# Each Scenario is a verified claim, cited to its source proc and the commit that
# shipped it. Tags are the report-card grade.
#
# WHAT THIS CARD SPAWNS (generative SEED):
#   - CODESPACE  : this .feature + .session.md, PLUS the innards -- Glbl_F6's
#                  CurrentMode==11 branch + PE_OrderListLoopPattern (F6), and
#                  PE_F7's CurrentMode==11 branch (F7).
#   - THINKSPACE : the .session.md -- why F6 LOOPS one pattern (not song-from-
#                  order; Esa corrected an earlier Music_PlaySong cut) and how F7
#                  carries the current edit Row onto the selected Order.
#   - AREASPACE  : owns F6+F7 behaviour in CurrentMode==11 only; must NOT change
#                  F6/F7 on other screens.
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01);
#                       IT_G.asm + IT_PE.asm Error/Warning = None, IT.EXE links
#   @runtime-verified - exercised by running IT.EXE and watching it play
#   @runtime-untested - NOT yet run; logic verified by reading only
#   @stock            - upstream Impulse Tracker behaviour, not a fork addition
#
# Source files linked back to this card (grep "features/f6-play-from-order-list-row"):
#   IT_G.ASM     - Glbl_F6: CurrentMode==11 -> Call PE_OrderListLoopPattern
#   IT_PE.ASM    - PE_OrderListLoopPattern (F6 loop); PE_F7 CurrentMode==11 branch
#                  (F7 from order+row); Order (250) + Row (254)
#   IT_MUSIC.ASM - Music_GetPattern (3457; word[1]=#rows); Music_PlayPattern
#                  (9076, AX=pat/BX=rows/CX=row); Music_PlayPartSong (9140, AX=order/BX=row)
#
# Commit log (the ingest trail):
#   8acb41f  first cut: F6 = Music_PlaySong(Order)  (superseded -- wrong: that
#            plays the song onward; Esa wanted F6 to LOOP one pattern)
#   5b37353  F6 loops the selected order's pattern; F7 plays from order+current row
#
# SESSION (the vibe record): features/f6-play-from-order-list-row.session.md
#
# RESULT (third leg of the triad):
#   Feature delivery : 8acb41f (first cut) + 5b37353 (corrected) direct to main, no PR
#   Triad: this .feature <-> .session.md <-> 5b37353
#
# WATCH: Glbl_F6 PE_OrderListLoopPattern PE_F7 Music_PlayPattern Music_PlayPartSong Music_GetPattern
# =============================================================================

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
