# =============================================================================
# WIKI PAGE / REPORT CARD: F4<->F3 cursor translation (carry the selection)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/f4-f3-cursor-translate.session.md
#
# Moving between the F4 Instrument List and the F3 Sample List used to lose your
# place. The fork carries the selection across: from F4, pressing F3 lands on the
# SAMPLE that the selected instrument plays (note 60 / C-5 first, else the first
# non-empty note), and the reverse maps a sample back to an instrument.
#
# Report-card legend (tags):
#   @shipped          - fork addition, in origin/main
#   @build-verified   - the code is in main; main assembles (cards are docs, no rebuild)
#   @hw-untested      - NOT run on real DOS hardware (DOSBox-X is emulation)
#   @runtime-untested - NOT yet exercised against a running IT.EXE
#
# Source files linked back to this card:
#   IT_G.ASM  Glbl_InstrumentToSample -- F4 -> F3: LastInstrument's note-60 sample
#   IT_G.ASM  Glbl_SampleToInstrument -- the reverse mapping
#   (16-bit safe: uses Xor BH,BH / Mov BL,AL, not the 386-only Movzx)
#
# Commit log (the ingest trail):
#   9d626b0  F4 -> F3 cursor translation
#   672273b  translate: bounds + note-60-first then scan-all fallback
#
# RESULT (triad: .feature spec + .session convo + what shipped):
#   Feature delivery : 9d626b0, 672273b  (direct to esaruoho/main, no PR)
#   Triad: this .feature <-> f4-f3-cursor-translate.session.md <-> those commits
#
# WATCH: Glbl_InstrumentToSample Glbl_SampleToInstrument
# RESULT-LOG >> (auto-maintained by .githooks/pre-commit / post-merge)
# =============================================================================

Feature: F4<->F3 carry the cursor selection across the two list screens
  As someone moving between the Instrument List (F4) and Sample List (F3),
  I want the selection to follow me to the matching slot,
  So that switching screens lands on the related sample/instrument instead of
  resetting to wherever the other list's cursor happened to be.

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: F3 from the Instrument List lands on the instrument's note-60 sample
    # cite: IT_G.ASM Glbl_InstrumentToSample -- from LastInstrument, read the sample
    #       byte the instrument maps for note 60 (C-5); F3 selects that sample.
    #       Offset math: instrument note-map base + 65 + 60*2 (= base+185). commit 9d626b0
    Given the user is on the F4 Instrument List with an instrument selected
    When the user presses F3
    Then the Sample List opens with the cursor on the sample that instrument plays at C-5

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Note-60-first, then scan all 120 notes for the first non-empty
    # cite: commit 672273b -- if the C-5 entry is empty, scan notes 0..119 for the
    #       first non-zero sample mapping (so a non-C-5-mapped instrument still lands).
    Given an instrument whose note 60 (C-5) maps to no sample
    When F3 translation runs
    Then it scans all 120 notes and lands on the first non-empty sample mapping

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The reverse maps a sample back to an instrument
    # cite: IT_G.ASM Glbl_SampleToInstrument -- translates the other direction
    Given the user is on the F3 Sample List
    When the user crosses to F4
    Then the instrument selection is translated from the current sample

  @shipped @build-verified
  Scenario: 16-bit safe (no 386-only instruction)
    # cite: 672273b replaced Movzx (386-only) with Xor BH,BH / Mov BL,AL -- IT_G.ASM
    #       must assemble/run in plain 16-bit, so the translation avoids 386 opcodes.
    Given IT_G.ASM is 16-bit real-mode code
    Then the translation uses Xor BH,BH / Mov BL,AL, never the 386-only Movzx
