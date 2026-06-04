# =============================================================================
# WIKI PAGE / REPORT CARD: User Presses F2 (Pattern Editor)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/fkey-report-cards.session.md (the vibe diff that spawned this)
#
# This .feature is the durable understanding-store for "what happens when the
# user presses F2". Each Scenario is a verified claim about behaviour, cited to
# its source proc + line and the commit that shipped it. Tags are the grade.
#
# Report-card legend (tags):
#   @stock          - upstream Impulse Tracker behaviour, not a fork addition
#   @shipped        - fork addition, in origin/main
#   @build-verified - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @hw-untested    - NOT run on real DOS hardware (DOSBox-X is emulation, not metal)
#
# Source files linked back to this card:
#   IT_OBJ1.ASM  - GlobalKeyList F2 dispatch entry (lines 3138-3140)
#   IT_G.ASM     - Glbl_F2 enter / toggle proc (line 224)
#   IT_PE.ASM    - PE_DrawPatternEdit; NewPattern_ApplyDefaultLength (10163);
#                  PE_ForkExtConfig.DefaultNewPatternLength (286)
#   IT_OBJ1.ASM  - O1_PatternEditList (634), O1_PEConfigList (645)
#
# Commit log (the ingest trail):
#   fb47b32  Import code (upstream base: F2 + F2-F2 config)
#   068648f  F2-F2 pattern length persists; M flag persists; IT.CFG ext block
#
# RESULT (third leg of the triad: .feature spec + .session convo + what shipped):
#   Feature delivery : 068648f  (pushed direct to esaruoho/main, no PR)
#   This card authored: 8ca97e9 (cards) + 009dbab (session + back-links)
#   Triad: this .feature  <->  fkey-report-cards.session.md  <->  commit 068648f
#
# WATCH: Glbl_F2 NewPattern_ApplyDefaultLength DefaultNewPatternLength D_SaveDirectoryConfiguration O1_PEConfigList
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
#   2026-06-04  direct-commit  touched: DefaultNewPatternLength D_SaveDirectoryConfiguration
#   2026-06-04  direct-commit  touched: D_SaveDirectoryConfiguration
#   2026-06-03  direct-commit  touched: Glbl_F2
#   2026-06-03  direct-commit  touched: Glbl_F2
#   2026-06-03  direct-commit  touched: Glbl_F2
#
# IT.TXT source of truth: lines 426 ("2.2 Pattern editor (F2)") and 437
#   ("pressing F2 when alredy in the Pattern Editor").
# =============================================================================

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
