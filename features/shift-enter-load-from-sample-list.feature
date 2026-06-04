# =============================================================================
# WIKI PAGE / REPORT CARD: Shift-Enter Load from Sample List (bulk module load)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/shift-enter-load-from-sample-list.session.md
#
# What happens when the user presses Shift-Enter on a MODULE in the F3 Sample
# List: every sample in that module is loaded into consecutive sample slots,
# one per row, with the module's ORIGINAL sample names and loop modes intact.
# In Instrument mode each loaded sample is also auto-assigned to an instrument.
#
# Report-card legend (tags):
#   @shipped         - in origin/main
#   @build-verified  - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @code-verified   - confirmed by reading the source this session (cited lines)
#   @hw-untested     - on-screen result NOT yet exercised on real DOS hardware
#
# Innards linked back to this card:
#   IT_DISK.ASM  - LSWindow_ShiftEnter (7764-7986); per-sample Call LoadSample
#                  (7928); Instrument-mode Call Music_AssignSampleToInstrument (7939)
#   IT_MUSIC.ASM - Music_AssignSampleToInstrument (reads sample name, writes the
#                  instrument keymap/name only)
#
# Commit log:
#   (bulk-load shipped earlier; this card added 2026-06-03 after a clash check
#    against the Samples->Instruments envelope-retention re-merge, PR #3 9493101)
#
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
# =============================================================================

Feature: Shift-Enter Load from Sample List
  As a user building a song from an existing module's samples,
  I want Shift-Enter on a module to pull in all its samples at once,
  So that I get every sample, named and loop-configured as in the source.

  @shipped @code-verified @hw-untested
  Scenario: Shift-Enter on a module loads its samples one per row
    # cite: IT_DISK.ASM LSWindow_ShiftEnter (7764-7986), per-sample Call
    #       LoadSample at 7928 into consecutive slots (LSBulkDstSlot), stops at 99
    Given the user is in the F3 Sample List
    And they have a module selected
    When they press Shift-Enter on it
    Then the samples of the module are loaded into consecutive sample slots
    And they display one sample per row

  @shipped @code-verified @hw-untested
  Scenario: Loaded samples keep their original names and loop modes
    # cite: each sample goes through LoadSample (IT_DISK.ASM:7928), the standard
    #       full-header loader -- name (sample header 0x14) and loop flags
    #       (0x12) are read straight from the module, not stripped or defaulted
    Given the module's samples have names and loop modes
    When Shift-Enter loads them
    Then each loaded sample shows its ORIGINAL module name
    And its loop mode (off / forward / ping-pong / sustain) is preserved

  @shipped @code-verified @hw-untested
  Scenario: In Instrument mode each sample is also auto-assigned to an instrument
    # cite: IT_DISK.ASM 7935-7940 -- if LSBulkInstMode != 0, Call
    #       Music_AssignSampleToInstrument (BX = slot); writes the instrument
    #       keymap + name only, never the sample header
    Given the user is in Instrument mode
    When Shift-Enter bulk-loads a module
    Then each loaded sample is assigned to an instrument
    And the sample headers (names, loop modes) are unaffected by that assignment

  # --- The clash the user worried about, checked and disproven ---------------
  @shipped @code-verified @hw-untested
  Scenario: Samples->Instruments envelope retention does NOT clash with this
    # cite: PR #3 (9493101) changed ONLY IT_F.ASM + IT_MUSIC.ASM, NOT IT_DISK.ASM
    # cite: F_SetControlInstrument runs on the F12 mode-flip, not on Shift-Enter;
    #       it reads sample headers + writes INSTRUMENT headers only (envelopes/
    #       keymap/name) -- it never writes sample names or loop flags
    Given the envelope-retention feature is merged (PR #3)
    When the user bulk-loads a module with Shift-Enter
    Then no sample name is lost and no loop mode is lost
    And the two features touch disjoint data (sample headers vs instrument headers)
      and fire on disjoint triggers (Shift-Enter key vs F12 toggle)
