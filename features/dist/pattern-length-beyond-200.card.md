# Report Card — Pattern length beyond 200 rows (256 / 512)

> Source: `features/pattern-length-beyond-200.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As a user, I want 256- or 512-row patterns, So that I can write longer phrases in a single pattern.

**Grades:** @stock × 1

**Scenarios: 5**


---


## 1. The unpacked editor buffer is a single 64,000-byte segment = 200 rows exactly

`@blocked-by-architecture @analysis-verified`


- Given the pattern editor decodes a pattern into PatternData at 320 bytes/row
- And PatternData is a single real-mode segment of exactly 64,000 bytes
- When a pattern would need 256 rows (81,920 bytes) or 512 rows (163,840 bytes)
- Then it cannot fit — both exceed a 64KB real-mode segment
- And the 200-row limit is therefore architectural, not an arbitrary choice

<sub>cite: IT_PE.ASM:14687-14688  Segment PatternData PARA Public 'Data' / DB 64000 Dup(?)</sub>


## 2. Row offsets are computed with 16-bit math that wraps past ~64KB

`@blocked-by-architecture @analysis-verified`


- Given the editor addresses a cell at offset = row*320 + channel*5
- And that offset is held in a 16-bit register (SI/DI), high word of the Mul discarded
- When row >= 205 the offset exceeds 65,535
- Then the offset silently wraps modulo 64KB and aliases an earlier row (corruption)

<sub>cite: IT_PE.ASM:8457-8461  Mov AX,320 / Mul DX / Add AX,BX / Mov SI,AX  (DX discarded)</sub>


## 3. Block and network ops pack the row index into a byte (cap 255)

`@blocked-by-architecture @analysis-verified`


- Given row-delete / row-insert / block ops pass BH=Row and CH=Height as 8-bit bytes
- When a pattern has more than 255 rows
- Then those operations truncate the row to its low byte (wrong region edited)

<sub>cite: IT_PE.ASM:4523 NetworkPatternBlock BH=Row CH=Height (bytes); :6456/:6519 Mov BH,Byte Ptr Row</sub>


## 4. The on-disk .IT Rows field is a WORD, but the spec defines 32..200

`@stock @analysis-verified`


- Given the .IT pattern header stores Rows as a 16-bit word
- Then the NUMBER 256 or 512 is representable on disk
- But the IT 2.xx format spec defines the valid range as 32..200
- And other IT software (classic IT, Schism) will not reliably read a >200-row pattern

<sub>cite: IT_PE.ASM:9905 DecodePattern LodsW (Rows); :10074 EncodePattern StosW; ITTECH.TXT:369</sub>


## 5. What it would actually take (NOT done — recorded for honesty)

`@blocked-by-architecture`


- Given someone wanted to truly support 256/512 rows
- Then the unpacked buffer must move past 64KB — i.e. 32-bit offset addressing
- (386 address-size override / "unreal mode" big segment) OR an EMS-paged
- multi-segment buffer
- And every PatternData access (dozens of sites: block ops, replicate, encode/
- decode, the mixer's pattern read) must switch to the new addressing
- And the byte-width Row/Height fields in NetworkPatternBlock must widen to words
- And the output ceases to be a spec-conformant .IT file

