# =============================================================================
# WIKI PAGE / REPORT CARD: F2 pattern-length increase tiles (duplicates) content
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# When the row count is INCREASED on the F2 Pattern-Edit-Config screen, the
# existing pattern content is duplicated to fill the new length instead of
# appending blank rows. Each Scenario is a verified claim, cited to its source
# proc and the commit that shipped it. Tags are the report-card grade.
#
# WHAT THIS CARD SPAWNS (generative SEED, not a description):
#   - CODESPACE  : this .feature + .session.md, PLUS the innards in "Source
#                  files" -- the PE_TilePatternToLength helper and the two
#                  injection points in Glbl_F2_1 (capture old length, tile on
#                  leave).
#   - THINKSPACE : the .session.md -- WHY tiling the decoded buffer is enough
#                  (working-copy model + dirty flag), and why scope is the F2
#                  config path only (not Ctrl-F2 bulk, not Alt-E).
#   - AREASPACE  : owns the F2-config length-increase behaviour; must NOT touch
#                  shrink, the Ctrl-F2 bulk editor, or Alt-E (which already 2x's).
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01);
#                       IT_PE.asm + IT_G.asm Error/Warning = None, IT.EXE links
#   @runtime-verified - exercised by running IT.EXE and watching the rows tile
#   @runtime-untested - NOT yet run; logic verified by reading only
#   @stock            - upstream Impulse Tracker behaviour, not a fork addition
#
# Source files linked back to this card (grep "features/f2-resize-tiles-pattern"):
#   IT_PE.ASM - PE_TilePatternToLength (row word-copy tiler, after
#               PE_OrderList_ExtendPattern); Global export
#   IT_G.ASM  - Glbl_F2_1: F2_OldRowCount captured on entry; tile call on leave
#               before MaxRow is committed
#   IT_PE.ASM - PE_OrderList_ExtendPattern: the 2x prior-art the helper generalises
#
# Commit log (the ingest trail):
#   05c70c9  F2 pattern-length increase tiles content instead of blank rows
#
# SESSION (the vibe record): features/f2-resize-tiles-pattern.session.md
#   The card is incomplete without it.
#
# RESULT (third leg of the triad):
#   Feature delivery : 05c70c9 direct to esaruoho/main, no PR
#   This card authored: the card+session commit that follows 05c70c9
#   Triad: this .feature <-> .session.md <-> 05c70c9
#
# WATCH: PE_TilePatternToLength Glbl_F2 PE_OrderList_ExtendPattern NumberOfRows MaxRow
#
# Sibling: features/f2-pattern-editor.feature (the F2/F2-config screen itself);
#          features/f11-order-list-power-tools.feature (Alt-E 2x extend).
# =============================================================================

Feature: F2 pattern-length increase duplicates (tiles) the existing content
  As someone lengthening a pattern from the F2 config screen,
  I want the existing rows duplicated to fill the new length,
  So that growing 64 -> 128 (or 192) gives me repeats of my material to edit,
  not a block of empty rows I have to re-enter.

  @shipped @build-verified @runtime-untested
  Scenario: 64 -> 128 duplicates the 64 rows once
    # cite: IT_G.ASM Glbl_F2_1 captures F2_OldRowCount on entry, calls
    #       PE_TilePatternToLength on leave when NumberOfRows grew
    # cite: IT_PE.ASM PE_TilePatternToLength tiles rows 0..OLD-1 into OLD..NEW-1
    # cite: commit 05c70c9
    Given a pattern of 64 rows
    When the user changes the row count to 128 on the F2 config screen
    Then rows 64..127 are a copy of rows 0..63
    And the pattern is 128 rows of the original material, twice

  @shipped @build-verified @runtime-untested
  Scenario: 64 -> 192 duplicates the 64 rows twice
    # cite: PE_TilePatternToLength loops dest rows with a wrapping source index
    Given a pattern of 64 rows
    When the user changes the row count to 192
    Then rows 64..127 and 128..191 are each a copy of rows 0..63
    And the pattern is the original material, three times

  @shipped @build-verified @runtime-untested
  Scenario: Non-multiple lengths get a partial final copy ("until the end")
    # cite: the row loop fills exactly NEW-OLD rows, wrapping the source; the
    #       last copy is partial when NEW isn't a multiple of OLD
    Given a pattern of 64 rows
    When the user changes the row count to 100
    Then rows 64..99 are a copy of rows 0..35 (the source, truncated to fit)

  @shipped @build-verified
  Scenario: Shrinking the pattern does not tile
    # cite: Glbl_F2_1 only calls the tiler when NumberOfRows > F2_OldRowCount
    Given a pattern of 128 rows
    When the user changes the row count to 64
    Then no tiling occurs; the pattern is simply truncated (stock behaviour)

  @shipped @build-verified
  Scenario: Scope is the F2 config path only
    # cite: only Glbl_F2_1 calls PE_TilePatternToLength; the Ctrl-F2 bulk length
    #       editor (PE_SetPatternLength) and Alt-E (PE_OrderList_ExtendPattern,
    #       a fixed 2x) are untouched
    Given the Ctrl-F2 bulk length editor or the F11 Alt-E extend
    When either is used
    Then its existing behaviour is unchanged by this feature

  @shipped @build-verified
  Scenario: The tiled buffer persists via the working-copy model
    # cite: tiling writes the decoded PatternDataArea; PE_SetPatternModified
    #       (already called in Glbl_F2_1) marks it dirty so it is encoded to the
    #       module on the next store -- matching how stock length-change persists
    Given the rows were tiled in the editor buffer
    When the pattern is later stored (switch pattern / save module)
    Then the duplicated rows are written out, not just shown
