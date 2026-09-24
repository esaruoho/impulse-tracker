# Pure Gherkin test extracted from features/f2-pattern-editor.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/f2-pattern-editor.feature

Feature: User Presses F2 (Pattern Editor)
  As someone editing a tune,
  I want F2 to take me to the pattern editor, and a second F2 to open its
  configuration, with my chosen pattern length remembered for new patterns,
  So that the most-used screen is one key away and never forgets my row count.

  @stock @build-verified
  Scenario: First F2 enters the pattern editor
    # cite: IT_OBJ1.ASM:3138 GlobalKeyList F2 (scancode 13Ch) -> Glbl_F2
    # cite: IT_G.ASM:231 Glbl_F2_2 sets CurrentMode=2, loads O1_PatternEditList
    # cite: IT_PE.ASM:3400 PE_DrawPatternEdit draws the grid
    Given the user is on any screen other than the pattern editor
    When the user presses F2
    Then CurrentMode becomes 2 and the pattern editor (O1_PatternEditList) opens
    And the pattern grid for the current pattern is drawn

  @stock @build-verified
  Scenario: Second F2 (already in the editor) opens Pattern Edit Config
    # cite: IT_G.ASM:227 Cmp CurrentMode,2 / JE Glbl_F2_1
    # cite: IT_G.ASM:243 Glbl_F2_1 sets CurrentMode=6, loads O1_PEConfigList
    # cite: IT_G.ASM:246-252 reads pattern MaxRow, +1, stores as NumberOfRows
    # cite: IT.TXT:437 "pressing F2 when alredy in the Pattern Editor"
    Given the user is already in the pattern editor (CurrentMode = 2)
    When the user presses F2
    Then CurrentMode becomes 6 and the Pattern Editor Configuration screen opens
    And the current pattern's length (MaxRow + 1) is shown as NumberOfRows
    And the user can set the row count in IT's 32..200 range

  @shipped @build-verified @hw-untested
  Scenario: F2-F2 remembers the chosen pattern length for new patterns
    # cite: IT_G.ASM:280-291 on leaving config, NumberOfRows -> DefaultNewPatternLength
    #       then D_SaveDirectoryConfiguration persists it to IT.CFG immediately
    # cite: IT_PE.ASM:286 DefaultNewPatternLength (PE_ForkExtConfig, default 64)
    # cite: commit 068648f
    Given the user set the row count on the Pattern Edit Config screen
    When the user leaves the config screen
    Then that row count is saved as DefaultNewPatternLength
    And it is written to IT.CFG so it survives the next launch of IT

  @shipped @build-verified @hw-untested
  Scenario: A freshly-entered empty pattern uses the remembered length
    # cite: IT_PE.ASM:10163 NewPattern_ApplyDefaultLength reads DefaultNewPatternLength
    #       on entry into an empty slot; clamps to 32..200, falls back to 64 if corrupt
    # cite: commit 068648f
    Given DefaultNewPatternLength was set via F2-F2
    When the user navigates into an empty (never-used) pattern slot
    Then that new pattern is created with DefaultNewPatternLength rows
    And a corrupt stored value is clamped to 32..200 (fallback 64)
