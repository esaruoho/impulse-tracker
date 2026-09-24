# Report Card — A rows==0 pattern is survivable on load and unwritable on save

> Source: `features/pattern-rows-guard.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As an Impulse Tracker user, I want a song with a malformed pattern header to load as an empty pattern instead of freezing, and I want IT to never save such a header, So that one bad pattern can never lose me a whole module.

**Grades:** @build-verified × 5 · @runtime-untested × 5 · @shipped × 5

**Scenarios: 5**


---


## 1. Loading a pattern whose header declares zero rows does not hang

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a saved .it whose pattern-offset table points at a pattern header with rows=0
- And that pattern is referenced by the order list (e.g. order[0])
- When IT decodes that pattern to display or play it
- Then the row count is recognised as invalid before "Dec AX" underflows MaxRow to 0FFFFh
- And the pattern is rendered as an empty 64-row pattern with no decode pass
- And IT keeps running instead of trashing memory and freezing

<sub>cite: IT_PE.ASM DecodePattern (~line 10029) -- And AX,AX / JZ DecodePatternEmpty ; commit 63e6ea1</sub>


## 2. An absurd row count is clamped rather than trusted

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a pattern header that declares more than 256 rows
- When IT decodes that pattern
- Then the row count is clamped to 256 before use
- And the decode loop cannot walk past the pattern data area

<sub>cite: IT_PE.ASM DecodePattern (~line 10029) -- Cmp AX,256 / JBE / Mov AX,256 ; commit 63e6ea1</sub>


## 3. IT never stores a pattern with zero rows

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a pattern whose in-memory MaxRow is 0FFFFh (corrupt)
- When IT encodes that pattern to store or save it
- Then "Inc CX" producing 0 is detected and the stored row count is clamped to 64
- And MaxRow is repaired to 63
- And the resulting file cannot contain a rows=0 pattern header

<sub>cite: IT_PE.ASM EncodePattern (~line 10220) -- Inc CX / JNZ / Mov CX,64 ; commit 63e6ea1</sub>


## 4. The F2 "Set Pattern Length" dialog cannot store a zero-row pattern

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the F2 Set Pattern Length dialog returns a length below 32 or above 200 (e.g. 0)
- When PE_SetPatternLength applies it to the pattern(s) in range
- Then the length is clamped to 32..200 before "Dec AX / Mov MaxRow"
- And the stored pattern always has a valid 1..256 row count
- And a normal 48- or 96-row set-length still stores exactly 48 or 96 rows

<sub>cite: IT_PE.ASM PE_SetPatternLength (~line 14300) -- clamp PatternSetLength 32..200 ; commit 1b4caa9</sub>


## 5. A healthy pattern is completely unaffected

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a normal pattern with 1..256 rows (e.g. 192, 96, 48)
- When IT decodes or encodes it
- Then the guards fall through with no change to the row count
- And the packed channel data is decoded and the size-mismatch check behaves as before

<sub>cite: IT_PE.ASM DecodePattern (~line 10029) fall-through DecodePatternRowsOK ; commit 63e6ea1</sub>

