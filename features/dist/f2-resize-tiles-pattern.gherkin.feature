# Pure Gherkin test extracted from features/f2-resize-tiles-pattern.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/f2-resize-tiles-pattern.feature

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
