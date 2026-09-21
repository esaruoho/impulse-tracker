# =============================================================================
# WIKI PAGE / REPORT CARD: A pattern with rows==0 can neither freeze the loader
#                          nor be written back to disk
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# This .feature is the durable understanding-store for the fork change that
# enforces the invariant "an IT pattern has 1..256 rows" at BOTH the decode
# (load/view) boundary and the encode (store/save) boundary, so a corrupt file
# can never hang IT and IT can never generate such a file.
#
# WHAT THIS CARD SPAWNS (the card is a generative SEED, not a description):
#   - CODESPACE  (the file structure): this .feature + the .session.md sibling,
#                PLUS the innards in "Source files" below -- the rows==0 guard in
#                DecodePattern and the MaxRow+1==0 guard in EncodePattern.
#   - THINKSPACE (the reasoning / vibe): the .session.md -- the ad_stim.it repro,
#                the MaxRow underflow (Dec 0 -> 0FFFFh), why rows==0 must be
#                treated as an empty 64-row pattern, and why the fix is on both
#                boundaries (defense in depth against whatever first produced it).
#   - AREASPACE  (the domain boundary): what this OWNS (row-count sanity at the
#                pattern (de)serialisation seam) and what it must NOT touch (the
#                packed channel-data codec itself, the pattern-length tiling
#                feature, the order list).
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01);
#                       IT_PE.asm Error/Warning = None, IT.EXE links (482680 bytes)
#   @hw-untested      - NOT yet run on real DOS hardware / DOSBox with the file
#   @runtime-untested - not yet confirmed on a running IT.EXE
#
# Source files linked back to this card (grep "features/pattern-rows-guard"):
#   IT_PE.ASM - DecodePattern (~line 10029) rows==0 -> empty 64-row, skip decode
#   IT_PE.ASM - EncodePattern (~line 10220) MaxRow+1==0 -> clamp rows to 64
#   IT_PE.ASM - PE_SetPatternLength (~line 14300) clamp F2 length to 32..200
# Commit log:   63e6ea1  IT_PE.ASM: guard pattern rows==0 on decode (freeze) and encode (save)
# SESSION:      features/pattern-rows-guard.session.md
# RESULT:       Feature delivery 63e6ea1 (direct to main, no PR); deployed IT.EXE to E:\ITNU2026 2026-09-21
# WATCH: DecodePattern EncodePattern PE_SetPatternLength
# =============================================================================

Feature: A rows==0 pattern is survivable on load and unwritable on save
  As an Impulse Tracker user, I want a song with a malformed pattern header to
  load as an empty pattern instead of freezing, and I want IT to never save such
  a header, So that one bad pattern can never lose me a whole module.

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Loading a pattern whose header declares zero rows does not hang
    # cite: IT_PE.ASM DecodePattern (~line 10029) -- And AX,AX / JZ DecodePatternEmpty ; commit 63e6ea1
    Given a saved .it whose pattern-offset table points at a pattern header with rows=0
    And that pattern is referenced by the order list (e.g. order[0])
    When IT decodes that pattern to display or play it
    Then the row count is recognised as invalid before "Dec AX" underflows MaxRow to 0FFFFh
    And the pattern is rendered as an empty 64-row pattern with no decode pass
    And IT keeps running instead of trashing memory and freezing

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: An absurd row count is clamped rather than trusted
    # cite: IT_PE.ASM DecodePattern (~line 10029) -- Cmp AX,256 / JBE / Mov AX,256 ; commit 63e6ea1
    Given a pattern header that declares more than 256 rows
    When IT decodes that pattern
    Then the row count is clamped to 256 before use
    And the decode loop cannot walk past the pattern data area

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: IT never stores a pattern with zero rows
    # cite: IT_PE.ASM EncodePattern (~line 10220) -- Inc CX / JNZ / Mov CX,64 ; commit 63e6ea1
    Given a pattern whose in-memory MaxRow is 0FFFFh (corrupt)
    When IT encodes that pattern to store or save it
    Then "Inc CX" producing 0 is detected and the stored row count is clamped to 64
    And MaxRow is repaired to 63
    And the resulting file cannot contain a rows=0 pattern header

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The F2 "Set Pattern Length" dialog cannot store a zero-row pattern
    # cite: IT_PE.ASM PE_SetPatternLength (~line 14300) -- clamp PatternSetLength 32..200 ; commit 1b4caa9
    # This is the ad_stim.it origin: F2 set-length with a 0/blank value made
    # MaxRow = PatternSetLength-1 = 0FFFFh, stored as rows=0.
    Given the F2 Set Pattern Length dialog returns a length below 32 or above 200 (e.g. 0)
    When PE_SetPatternLength applies it to the pattern(s) in range
    Then the length is clamped to 32..200 before "Dec AX / Mov MaxRow"
    And the stored pattern always has a valid 1..256 row count
    And a normal 48- or 96-row set-length still stores exactly 48 or 96 rows

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: A healthy pattern is completely unaffected
    # cite: IT_PE.ASM DecodePattern (~line 10029) fall-through DecodePatternRowsOK ; commit 63e6ea1
    Given a normal pattern with 1..256 rows (e.g. 192, 96, 48)
    When IT decodes or encodes it
    Then the guards fall through with no change to the row count
    And the packed channel data is decoded and the size-mismatch check behaves as before
