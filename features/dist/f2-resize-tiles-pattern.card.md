# Report Card — F2 pattern-length increase duplicates (tiles) the existing content

> Source: `features/f2-resize-tiles-pattern.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone lengthening a pattern from the F2 config screen, I want the existing rows duplicated to fill the new length, So that growing 64 -> 128 (or 192) gives me repeats of my material to edit, not a block of empty rows I have to re-enter.

**Grades:** @build-verified × 6 · @runtime-verified × 3 · @shipped × 6

**Scenarios: 6**


---


## 1. 64 -> 128 duplicates the 64 rows once

`@shipped @build-verified @runtime-verified`


- Given a pattern of 64 rows
- When the user changes the row count to 128 on the F2 config screen
- Then rows 64..127 are a copy of rows 0..63
- And the pattern is 128 rows of the original material, twice

<sub>cite: IT_G.ASM Glbl_F2_1 captures F2_OldRowCount on entry, calls · IT_PE.ASM PE_TilePatternToLength tiles rows 0..OLD-1 into OLD..NEW-1 · commit 05c70c9</sub>


## 2. 64 -> 192 duplicates the 64 rows twice

`@shipped @build-verified @runtime-verified`


- Given a pattern of 64 rows
- When the user changes the row count to 192
- Then rows 64..127 and 128..191 are each a copy of rows 0..63
- And the pattern is the original material, three times

<sub>cite: PE_TilePatternToLength loops dest rows with a wrapping source index</sub>


## 3. Non-multiple lengths get a partial final copy ("until the end")

`@shipped @build-verified @runtime-verified`


- Given a pattern of 64 rows
- When the user changes the row count to 100
- Then rows 64..99 are a copy of rows 0..35 (the source, truncated to fit)

<sub>cite: the row loop fills exactly NEW-OLD rows, wrapping the source; the</sub>


## 4. Shrinking the pattern does not tile

`@shipped @build-verified`


- Given a pattern of 128 rows
- When the user changes the row count to 64
- Then no tiling occurs; the pattern is simply truncated (stock behaviour)

<sub>cite: Glbl_F2_1 only calls the tiler when NumberOfRows > F2_OldRowCount</sub>


## 5. Scope is the F2 config path only

`@shipped @build-verified`


- Given the Ctrl-F2 bulk length editor or the F11 Alt-E extend
- When either is used
- Then its existing behaviour is unchanged by this feature

<sub>cite: only Glbl_F2_1 calls PE_TilePatternToLength; the Ctrl-F2 bulk length</sub>


## 6. The tiled buffer persists via the working-copy model

`@shipped @build-verified`


- Given the rows were tiled in the editor buffer
- When the pattern is later stored (switch pattern / save module)
- Then the duplicated rows are written out, not just shown

<sub>cite: tiling writes the decoded PatternDataArea; PE_SetPatternModified</sub>

