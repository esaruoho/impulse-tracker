# =============================================================================
# WIKI PAGE / REPORT CARD: Ctrl-Shift-Right dumps every sample as a WAV
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# Ported from the schismtracker fork (song_samples_to_quicksave_files, 2026-08-07).
#
# WHAT THIS CARD SPAWNS (generative SEED):
#   - CODESPACE  : this .feature + the innards -- D_DumpAllSamplesWAV and
#                  D_DumpBuildName in IT_DISK.ASM, the reusable
#                  D_SaveRawSampleInternal split out of D_SaveRawSample, and the
#                  DisplayListKeys code-3 row.
#   - THINKSPACE : WHY IT's existing per-sample WAV writer is reused rather than a
#                  new emitter written, and why the header is copied before the
#                  filename is substituted.
#   - AREASPACE  : owns bulk sample export. Must NOT change what D_SaveRawSample
#                  does for a single sample, nor the WAVE* header patching.
#
# Report-card legend: @shipped @build-verified @hw-verified @hw-untested
#
# Source files linked back to this card:
#   IT_DISK.ASM  - D_DumpAllSamplesWAV (loop), D_DumpBuildName (SMPnn.WAV)
#   IT_DISK.ASM  - D_SaveRawSampleInternal (split out; DS:SI=header, BX=slot)
#   IT_DISPL.ASM - DisplayListKeys: DB 3 / DW 1CDh -> D_DumpAllSamplesWAV
#
# WATCH: D_DumpAllSamplesWAV D_DumpBuildName D_SaveRawSampleInternal
#        D_SaveRawSample D_SaveSampleData D_SaveSampleDataConvert
#        D_GotoRenderDirectory DumpSampleName DumpSampleCount
# =============================================================================

Feature: Dumping every sample in the song to WAV in one keystroke
  As someone moving a module's sounds to another machine,
  I want one key to write every loaded sample out as its own WAV,
  So that the whole sample set lands in the Quicksave folder the Mac reads,
  without saving them one at a time.

  @shipped @build-verified @hw-untested
  Scenario: Ctrl-Shift-Right writes every loaded sample
    # cite: IT_DISK.ASM D_DumpAllSamplesWAV -- slots 1..99, Test [SI+12h],1 to skip
    #       empty ones, D_GotoRenderDirectory first so files land in Quicksave
    Given a song with samples loaded
    When the user presses Ctrl-Shift-Right on the F5 Info Page
    Then each non-empty sample is written as SMPnn.WAV in the Quicksave folder
    And the info line reports how many were written

  @shipped @build-verified @hw-untested
  Scenario: 8-bit samples are converted, not dumped raw
    # IT stores 8-bit sample data SIGNED (ITTECH.TXT: "IT 2.02 and above use signed
    # samples") while WAV 8-bit PCM is UNSIGNED. IT's own writer already handles
    # this: it calls D_SaveSampleDataConvert for 8-bit and D_SaveSampleData for
    # 16-bit. Reusing that path is the whole reason this card writes no new WAV
    # emitter -- a fresh one would have dumped 8-bit raw and been quietly wrong.
    Given a song containing 8-bit samples
    When they are dumped
    Then their data is converted to unsigned, so they do not play back inverted

  @shipped @build-verified @hw-untested
  Scenario: The song's own sample filenames are left alone
    # cite: D_SaveRawSampleInternal takes the filename from [SI+4] of the header it
    #       is given, so the dump hands it an 80-byte COPY in DiskDataArea with
    #       SMPnn.WAV spliced in. The song's record is untouched.
    Given a sample whose stored filename is something else
    When the dump runs
    Then the file on disk is SMPnn.WAV and the song's own filename field is unchanged

  @shipped @build-verified @hw-untested
  Scenario: A bad Quicksave path aborts before writing anything
    # cite: D_GotoRenderDirectory returns CF=1 on a configured-but-invalid path
    Given the Quicksave folder in F12 points somewhere that does not exist
    When the user presses Ctrl-Shift-Right
    Then nothing is written and the info line says the folder is invalid

  @design-note
  Scenario: Why the Ctrl row sits before the Shift row in the keymap
    # Code 3 gates on Test CH,18h (Ctrl) and code 4 on Test CH,6 (Shift); neither
    # rejects the other modifier, and M_FunctionDivider takes the FIRST matching
    # row. So with Ctrl+Shift held both rows match and order decides. Ctrl first
    # means Ctrl-Shift-Right dumps and plain Shift-Right still renders.
    # Consequence, accepted: plain Ctrl-Right also dumps, since code 3 only tests
    # Ctrl. Nothing else on this screen wanted Ctrl-Right.
    Given both a Ctrl row and a Shift row match Ctrl-Shift-Right
    Then the Ctrl row is placed first so the more specific chord wins

  @todo
  Scenario: Names carry the sample name, not just the slot
    # 8.3 filenames have no room for a 26-character sample name, so this writes
    # SMPnn.WAV. schismtracker writes <song>-smpNNN-<name>.wav because it has long
    # filenames. Sanitising a sample name into 8.3 without collisions is a
    # separate job.
    Given DOS 8.3 filenames
    Then the slot number is what identifies the file, for now
