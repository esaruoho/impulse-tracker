# Pure Gherkin test extracted from features/note-cut-toggle.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/note-cut-toggle.feature

Feature: '1' toggles the note cut under the cursor
  As someone editing a pattern,
  I want pressing '1' on a cell that already shows ^^^ to clear it,
  So that the same key both places and removes a note cut without reaching for '.'.

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: First '1' on an empty (or noted) cell stamps a note cut
    # cite: IT_PE.ASM PE_PatternCursorPos0_3 (~5495) '1'/'!' -> NoteCutToggle ; commit 81e4819
    # cite: IT_PE.ASM NoteCutToggle (~5600): [ES:DI] != 0FEh -> JNE WipeNote with AL=0FEh
    Given the cursor is on a note cell that does NOT already hold a note cut
    When the user presses '1' (or Shift-'1' = '!')
    Then a note cut (^^^, 0FEh) is written into that cell
    And behaviour is identical to stock IT (cursor advances per the cursor step)

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Second '1' on a note-cut cell wipes it
    # cite: IT_PE.ASM NoteCutToggle (~5600): [ES:DI] == 0FEh -> AL=NONOTE, Jmp WipeNote
    # cite: IT_PE.ASM WipeNote (~5534): writes AL into the note byte, clears the
    #       rest of the event per EditMask -- the same path '.' takes
    Given the cursor is on a note cell that already holds a note cut (^^^)
    When the user presses '1' (or '!')
    Then the cell is erased exactly as pressing '.' would (note <- NONOTE, columns
         per the edit mask)
    And no second ^^^ is stamped

  @stock @build-verified @hw-untested
  Scenario: Note-off and '.' are unchanged
    # cite: IT_PE.ASM PE_PatternCursorPos0_3: '`'/'~' still -> WipeNote with AL=0FFh,
    #       '.' still -> WipeNote with AL=NONOTE (neither routes through NoteCutToggle)
    Given the cursor is on any note cell
    When the user presses '`' / '~' (note-off) or '.' (erase)
    Then those keys behave exactly as in stock IT (note-off stamps ===, '.' erases)
