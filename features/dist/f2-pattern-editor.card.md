# Report Card — User Presses F2 (Pattern Editor)

> Source: `features/f2-pattern-editor.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone editing a tune, I want F2 to take me to the pattern editor, and a second F2 to open its configuration, with my chosen pattern length remembered for new patterns, So that the most-used screen is one key away and never forgets my row count.

**Grades:** @build-verified × 4 · @shipped × 2 · @stock × 2

**Scenarios: 4**


---


## 1. First F2 enters the pattern editor

`@stock @build-verified`


- Given the user is on any screen other than the pattern editor
- When the user presses F2
- Then CurrentMode becomes 2 and the pattern editor (O1_PatternEditList) opens
- And the pattern grid for the current pattern is drawn

<sub>cite: IT_OBJ1.ASM:3138 GlobalKeyList F2 (scancode 13Ch) -> Glbl_F2 · IT_G.ASM:231 Glbl_F2_2 sets CurrentMode=2, loads O1_PatternEditList · IT_PE.ASM:3400 PE_DrawPatternEdit draws the grid</sub>


## 2. Second F2 (already in the editor) opens Pattern Edit Config

`@stock @build-verified`


- Given the user is already in the pattern editor (CurrentMode = 2)
- When the user presses F2
- Then CurrentMode becomes 6 and the Pattern Editor Configuration screen opens
- And the current pattern's length (MaxRow + 1) is shown as NumberOfRows
- And the user can set the row count in IT's 32..200 range

<sub>cite: IT_G.ASM:227 Cmp CurrentMode,2 / JE Glbl_F2_1 · IT_G.ASM:243 Glbl_F2_1 sets CurrentMode=6, loads O1_PEConfigList · IT_G.ASM:246-252 reads pattern MaxRow, +1, stores as NumberOfRows · IT.TXT:437 "pressing F2 when alredy in the Pattern Editor"</sub>


## 3. F2-F2 remembers the chosen pattern length for new patterns

`@shipped @build-verified @hw-untested`


- Given the user set the row count on the Pattern Edit Config screen
- When the user leaves the config screen
- Then that row count is saved as DefaultNewPatternLength
- And it is written to IT.CFG so it survives the next launch of IT

<sub>cite: IT_G.ASM:280-291 on leaving config, NumberOfRows -> DefaultNewPatternLength · IT_PE.ASM:286 DefaultNewPatternLength (PE_ForkExtConfig, default 64) · commit 068648f</sub>


## 4. A freshly-entered empty pattern uses the remembered length

`@shipped @build-verified @hw-untested`


- Given DefaultNewPatternLength was set via F2-F2
- When the user navigates into an empty (never-used) pattern slot
- Then that new pattern is created with DefaultNewPatternLength rows
- And a corrupt stored value is clamped to 32..200 (fallback 64)

<sub>cite: IT_PE.ASM:10163 NewPattern_ApplyDefaultLength reads DefaultNewPatternLength · commit 068648f</sub>

