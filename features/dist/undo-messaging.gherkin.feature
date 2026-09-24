# Pure Gherkin test extracted from features/undo-messaging.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/undo-messaging.feature

Feature: Undo steps are named via the UndoBufferTypes table
  As a maintainer adding a pattern-editing operation,
  I want a documented, repeatable way to give my operation a readable undo-list name,
  So that pressing Ctrl-Backspace shows "what this step was" instead of a blank or
  garbage label, and the knowledge of how to do it never gets lost.

  # --- The mechanism (how naming works) --------------------------------------

  @howto @stock @build-verified @runtime-verified
  Scenario: Each undo slot stores a TYPE number that indexes a string table
    # cite: IT_PE.ASM:375 UndoBuffer = 10 entries x 4 bytes: [seg/handle][type word]
    # cite: IT_PE.ASM:378 UndoBufferTypes = parallel offset table (one DW per type)
    # cite: IT_PE.ASM:393-417 UndoBufferType0..24 = the null-terminated label strings
    Given the 10-deep undo buffer
    When a step is recorded
    Then its slot holds a type word, and UndoBufferTypes[type] points at its label

  @howto @stock @build-verified @runtime-verified
  Scenario: Recording an undo step assigns its type
    # cite: IT_PE.ASM:13708 PE_AddToUndoBuffer; :13712 "Parameter: DI = buffer TYPE";
    #       :13794 Mov [SI+2], DI stores the type word into the new slot
    Given an edit op that mutates pattern data
    When it does `Mov DI, <type>` then `Call PE_AddToUndoBuffer`
    Then the pattern is snapshotted AND the step is tagged with <type>

  @howto @stock @build-verified @runtime-verified
  Scenario: The undo list draws each step's name from the table
    # cite: IT_PE.ASM:13865 PEFunction_DrawUndo; :13887 Mov SI,[UndoBufferTypes+SI]
    #       reads the type word, masks the low byte (And SI,0FFh), doubles it (x2 = DW
    #       index), looks up the string, draws it with S_DrawString
    Given the user presses Ctrl-Backspace
    When the undo list is drawn
    Then each of the 10 rows shows UndoBufferTypes[its type] as its label

  # --- The recipe (how to ADD a named undo step) -----------------------------

  @howto
  Scenario: Adding a new named undo step (the four-step recipe)
    # The contract every pattern-mutating op must follow to be named:
    Given a new pattern-editing operation that needs an undo step
    When the maintainer wires it up
    Then they (1) add a string `UndoBufferTypeN DB "My Label", 0` after the last one
    And  (2) add a matching `DW Offset UndoBufferTypeN` to the UndoBufferTypes table
             (MANDATORY — see the off-the-end bug below)
    And  (3) make the op call `Mov DI, N` / `Call PE_AddToUndoBuffer` BEFORE it mutates
    And  (4) (optional) format codes in the string: `0FDh,"D"` draws a decimal number
             (e.g. UndoBufferType22 "Pattern <n>"); `0FFh,N` pads/aligns a trailing
             key hint. Plain inline keys like "(Alt-R)" need no codes and are fine.

  @howto @bug @runtime-verified
  Scenario: A type with no offset-table entry draws garbage (the trap)
    # The defect Esa hit: Alt-R/Shift-Alt-R passed DI=23 while UndoBufferTypes only
    # listed 0..22, so PEFunction_DrawUndo indexed PAST the table end and drew
    # garbage/blank for the replicate step. Fixed by adding the 23/24 entries (3a3b7ff).
    # cite: commit 3a3b7ff (added UndoBufferType23/24 + their offset-table DWs)
    Given an op passes a type number with no UndoBufferTypes[type] entry
    When the undo list is drawn
    Then PEFunction_DrawUndo reads past the table and draws a garbage/blank label
    And the fix is ALWAYS to add the offset-table DW, not just the string

  # --- The worked example (the fork's replicate labels) ----------------------

  @howto @shipped @build-verified @runtime-untested
  Scenario: Worked example - Alt-R / Shift-Alt-R replicate labels
    # cite: IT_PE.ASM:416 UndoBufferType23 "Replicate Track Above (Alt-R)"
    # cite: IT_PE.ASM:417 UndoBufferType24 "Replicate Pattern Above (Sh-Alt-R)"
    # cite: IT_PE.ASM PEFunction_ReplicateAtCursor (DI=23) / ReplicatePatternAtCursor
    #       (DI=24) ; commits 3a3b7ff (add) + d938ff4 (rename to Esa's wording)
    Given Alt-R (type 23) and Shift-Alt-R (type 24) replicate ops
    When the user undoes one via Ctrl-Backspace
    Then it is named "Replicate Track Above (Alt-R)" or "Replicate Pattern Above (Sh-Alt-R)"
    # @runtime-untested: renamed strings build clean; awaiting Esa's live confirm of wording
