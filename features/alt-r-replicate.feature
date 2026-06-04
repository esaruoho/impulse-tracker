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
#   @hw-untested    - NOT run on real DOS hardware (DOSBox-X is emulation, not metal)
#   @runtime-untested - NOT yet exercised by running IT.EXE and pressing the key
#
# Source files linked back to this card (grep "features/alt-r-replicate"):
#   IT_PE.ASM  PEFunction_AltR_Dispatch     (8275) split on Left/Right shift
#   IT_PE.ASM  PEFunction_ReplicateAtCursor        (8386) tile current channel
#   IT_PE.ASM  PEFunction_ReplicatePatternAtCursor (8488) Shift-Alt-R, whole pattern
#   IT_PE.ASM  PEFunction_ClearViews               (11040) NO LONGER key-bound
#   IT_PE.ASM  UndoBufferTypes table + UndoBufferType23/24 (undo-list labels)
#   IT_PE.ASM  keymap entry 1300h (Alt-R) -> PEFunction_AltR_Dispatch (788)
#
# Commit log (the ingest trail):
#   d506486  Alt-R = Replicate at Cursor
#   aaada5e  Alt-R tile at row 0 + Shift-Alt-R = ClearViews (original Alt-R)
#   3a3b7ff  Alt-R / Shift-Alt-R get their own undo labels (UndoBufferType23/24)
#
# RESULT (triad: .feature spec + .session convo + what shipped):
#   Feature delivery : d506486, aaada5e   (direct to esaruoho/main, no PR)
#   This card authored: this session (see RESULT-LOG / git log for this file)
#   Triad: this .feature <-> alt-r-replicate.session.md <-> those commits
#
# WATCH: PEFunction_AltR_Dispatch PEFunction_ReplicateAtCursor PEFunction_ReplicatePatternAtCursor PEFunction_ClearViews
# RESULT-LOG >> (auto-maintained by .githooks/pre-commit / post-merge)
#   2026-06-04  direct-commit  touched: PEFunction_AltR_Dispatch
#   2026-06-04  direct-commit  touched: PEFunction_ReplicateAtCursor PEFunction_ClearViews
#
# IT.TXT source of truth: Alt-R historically = "clear all track views"; this fork
#   repurposes plain Alt-R to replicate the current TRACK and Shift-Alt-R to
#   replicate the whole PATTERN. ClearViews is no longer bound to any key.
#   Undo = Ctrl-Backspace (IT.TXT:1054); Alt-Z = Cut current block (IT.TXT:1152).
# =============================================================================

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

  @shipped @build-verified @runtime-verified @hw-untested
  # RUNTIME-VERIFIED 2026-06-04 (Esa): "alt-r and shift-alt-r work beautifully".
  Scenario: Shift-Alt-R replicates the whole PATTERN at cursor
    # Changed 2026-06-04 per Esa's hardware feedback: Shift-Alt-R was the stock
    # ClearViews ("does nothing" to him); he wanted it to replicate the current
    # PATTERN at cursor. PEFunction_ReplicatePatternAtCursor tiles full 320-byte
    # rows across all 64 channels with the same rule as the per-channel Alt-R.
    # cite: IT_PE.ASM PEFunction_ReplicatePatternAtCursor; commit 5fb263b
    # (ClearViews is no longer bound to a key.)
    # KEYMAP ROOT-CAUSE (commit a52a462): Shift-Alt-R first "did nothing" because
    # the R key had NO Shift+Alt (cond-11) translation entry -- cond 5 (Alt)
    # rejects when Shift is also held, so Shift+Alt+R produced no keyword and
    # never reached the dispatcher. Added R cond-11 -> 1300h (IT_K.ASM ~285) so it
    # reaches PEFunction_AltR_Dispatch, whose live-shift check routes it here.
    Given the cursor is on Row R of the pattern
    When the user presses Shift-Alt-R
    Then Shift+Alt+R reaches the dispatcher (cond-11 keymap entry) and is routed here
    And if R > 0, rows 0..R-1 (ALL channels) tile down to fill rows R..MaxRow
    And if R == 0, row 0 (all channels) tiles down the whole pattern

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Both replicate ops are undoable and show a correct label in the undo list
    # Added 2026-06-04 per Esa ("Shift-Alt-R should create an undo step"). Both ops
    # already snapshotted via PE_AddToUndoBuffer, so the data was always recoverable;
    # the defect was that BOTH used undo tag 23 while the UndoBufferTypes offset table
    # only labelled tags 0..22 -- so PEFunction_DrawUndo indexed past the table end and
    # drew a garbage label for any replicate step in the Ctrl-Backspace undo list.
    # FIX (3a3b7ff): UndoBufferType23 "Undo replicate track (Alt-R)" + UndoBufferType24
    # "Undo replicate pattern (Sh-Alt-R)", extend UndoBufferTypes, move Shift-Alt-R to
    # tag 24. NOTE: the undo key is Ctrl-Backspace (IT.TXT:1054), NOT Alt-Z -- Alt-Z is
    # "Cut current block" (IT.TXT:1152).
    # cite: IT_PE.ASM PEFunction_ReplicateAtCursor (DI=23) + PEFunction_ReplicatePatternAtCursor
    #       (DI=24); UndoBufferTypes table + UndoBufferType23/24 strings ; commit 3a3b7ff
    # cite: IT_PE.ASM PEFunction_DrawUndo (~13845) indexes UndoBufferTypes by tag low byte
    Given the user has performed an Alt-R or Shift-Alt-R replicate
    When they open the undo list with Ctrl-Backspace
    Then the replicate step is listed with its own readable label
    And selecting it reverts the pattern to its pre-replicate state
    # @runtime-untested: assembles + links clean (IT.EXE 477096 bytes). Flip to
    # @runtime-verified after a live DOSBox-X test: replicate, Ctrl-Backspace, confirm
    # the label reads "Undo replicate track/pattern" and the revert restores the data.
