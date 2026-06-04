# =============================================================================
# WIKI PAGE / REPORT CARD: Shift-Enter on a Module Row -> bulk-load its samples
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/shift-enter-bulk-load-from-module.session.md
#
# Durable understanding-store for "what happens when the user presses Shift-Enter
# on a module file (.MOD/.IT/.S3M/.XM/.MTM/.669/.PTM/.FAR) in the sample-loader
# browser reached from F3 Sample List -> Enter (Load Sample)". Every sample in the
# module is loaded into consecutive sample slots, one per row, keeping the module
# samples' original names and loop modes.
#
# Report-card legend (tags):
#   @stock            - upstream Impulse Tracker behaviour
#   @shipped          - fork addition, in origin/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @hw-untested    - NOT run on real DOS hardware (DOSBox-X is emulation, not metal)
#   @runtime-verified - confirmed live against a running IT.EXE in DOSBox-X
#   @runtime-untested - NOT yet confirmed live
#   @bug              - a reported defect; the scenario documents the demand it violated
#   @fixed-pending-verify - a fix is committed + build-verified but not yet runtime-confirmed
#
# WHAT THIS CARD SPAWNS (generative seed)
#   Codespace : LSWindow_ShiftEnter in IT_DISK.ASM; the shared per-format
#               LoadSamplesInModuleTable loaders in IT_D_RIS.INC; LoadSample.
#   Thinkspace: the .session.md (the crash report, the root-cause trace, why the
#               fix mirrors the stock module-browse finalisation).
#   Areaspace : OWNS the Shift-Enter (cond 4 / key 11Ch) binding in LSWindowKeys
#               on the sample-loader browser. MUST NOT change plain Enter
#               (LSWindow_Enter / LSViewWindow_Enter2) or the shared module
#               loaders (they serve the stock browse path too).
#
# Source files linked back to this card:
#   IT_DISK.ASM      - LSWindow_ShiftEnter (7764); LSWindowKeys Shift-Enter entry
#                      (cond 4 / 11Ch, ~988); the FORK FIX finalisation block
#                      (7839); the bulk loop LSWS_Loop (7894); LoadSample (7322);
#                      stock reference path LSViewWindow_Enter2 (7574-7642).
#   IT_D_RIS.INC     - LoadMODSamplesInModule (62) + sibling per-format loaders;
#                      cache-entry contract documented at the top (1-15).
#   IT_G.ASM         - Glbl_F3 (303): where the handler lands after a bulk load.
#
# Commit log (the ingest trail):
#   f541198  Shift-Enter on module row = bulk-load all samples (original feature)
#   (earlier)     MOD hard-hang fix: finalise loader cache before loop/teardown
#   e0b1643  bulk-load exits module back to its directory (this session)
#
# RESULT (third leg of the triad):
#   Feature delivery : f541198 (original) + the hang fix in this session.
#   Build            : full BUILDALL via dosbox-x -conf buildall.conf
#                      2026-06-03 13:28 EEST. IT_DISK.asm assembled
#                      "Error messages: None / Warning messages: None"; tlink
#                      3.01 linked; IT.EXE 476375 -> 476535 bytes (+160).
#   Triad: this .feature <-> shift-enter-bulk-load-from-module.session.md <-> commit
#
# WATCH: LSWindow_ShiftEnter LoadMODSamplesInModule LSViewWindow_Enter2 LoadSample ExitLibraryDirectory SamplesInModule SampleCacheFileComplete
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
#   2026-06-04  direct-commit  touched: LoadSample SamplesInModule
#   2026-06-03  direct-commit  touched: LoadSample
#   2026-06-03  direct-commit  touched: LSViewWindow_Enter2 LoadSample ExitLibraryDirectory SamplesInModule SampleCacheFileComplete
#
# IT.TXT source of truth: the sample loader and module browsing are documented;
# Shift-Enter bulk-load is a fork extension (not in stock IT.TXT).
# =============================================================================

Feature: Shift-Enter Load from Sample List (bulk-load a module's samples)
  As someone who wants a module's instruments fast,
  I want Shift-Enter on a module file in the Load Sample browser to load every
  sample in that module into consecutive slots, one per row, keeping each
  sample's original name and loop mode,
  So that I can lift a whole module's sample set in a single keystroke.

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Shift-Enter on a module bulk-loads its samples into consecutive slots
    # cite: IT_DISK.ASM:988 LSWindowKeys cond 4 (Shift) / key 11Ch -> LSWindow_ShiftEnter
    # cite: IT_DISK.ASM:7830 calls the per-format LoadSamplesInModuleTable loader
    # cite: IT_DISK.ASM:7894 LSWS_Loop iterates cache entries 1..NumSamples-1,
    #       LoadSample per non-empty entry into LSBulkDstSlot, incrementing
    # cite: IT_G.ASM:303 lands on the F3 Sample List afterwards (Jmp Glbl_F3)
    Given the user is in the Sample List and has opened the Load Sample browser
    And the cursor is on a module file row (type byte [cache+88] >= 20h)
    When they press Shift-Enter on it
    Then every sample in the module is loaded into consecutive sample slots
    And each occupies its own row in the sample list

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Loaded samples keep their original module names and loop modes
    # cite: IT_D_RIS.INC:136 MOD loader copies the 22-char sample name into the
    #       cache entry; :131 sets loop flag (Or AL,16); :155/:161 loop begin/end
    # cite: IT_DISK.ASM:7420 LoadSample copies the 48h-byte sample header (name,
    #       flags, loop points) from the cache entry into the song's sample slot
    Given a module whose samples have names and loop points
    When they are bulk-loaded via Shift-Enter
    Then each loaded sample shows its original name
    And its loop mode (forward / ping-pong / none) is preserved

  # --- The bug this card was spawned to fix ----------------------------------

  @bug @fixed-pending-verify
  Scenario: REGRESSION (reported 2026-06-03) - Shift-Enter on a .MOD hard-hangs IT
    # Reported by Esa: "loading a .mod with shift-enter from F3 Sample List Load
    # Sample, and the whole thing yanked completely."
    #
    # ROOT CAUSE: LSWindow_ShiftEnter ran the shared module loader to populate the
    # DiskDataArea cache, then went straight into the bulk loop and Jmp Glbl_F3 -
    # WITHOUT the cache finalisation the stock single-load path does
    # (LSViewWindow_Enter2, IT_DISK.ASM:7620-7639): it never wrote cache entry 0
    # (the ExitLibraryDirectory row) nor set SampleCacheFileComplete / SamplesInModule
    # / SampleInMemory / SampleCheck / LoadSampleNameCount. On the screen
    # transition the loader teardown walked a malformed cache (entry 0 garbage,
    # module-state globals stale) and hard-hung. The MOD loader and LoadSample are
    # shared with the working stock browse path, which is why single-loads never
    # crashed and only the fork bulk path did.
    #
    # FIX (this commit): mirror the stock finalisation in the bulk path right after
    # the loader runs and BEFORE the loop / no-sample return, so the cache is always
    # the same consistent module-browse state stock leaves.
    # cite: IT_DISK.ASM:7839 FORK FIX block (Xor DI,DI / Rep MovsB ExitLibraryDirectory
    #       + the five module-browse globals), placed before Cmp NumSamples,2
    Given the user is on a .MOD file row in the Load Sample browser
    When they press Shift-Enter
    Then IT must NOT hang
    And it loads the module's samples (or shows "Module contains no samples.")
    And it returns to a consistent screen state
    # @fixed-pending-verify: assembles + links clean and the cache state now equals
    # the proven stock path, but the no-hang outcome is NOT yet confirmed on a
    # running IT.EXE. Flip to @runtime-verified after a live DOSBox-X MOD test.

  @bug @fixed-pending-verify
  Scenario: REGRESSION (reported 2026-06-04) - after bulk-load the loader is parked
            inside the module instead of its directory
    # Reported by Esa: "if i now go down a few steps in Sample List (F3) and then
    # press enter on a different slot to load the Load Sample dialog, what comes up
    # is NOT the Load Sample view that i selected from but a few steps down sample
    # inside the module that i shift-loaded... the Load Sample position does not get
    # remembered after shift-load."
    #
    # ROOT CAUSE: the MOD-hang fix (scenario above) finalises the loader cache into
    # the module-browse state and sets SamplesInModule=1, then Jmp Glbl_F3. That flag
    # is the right end-state for SINGLE-load (you stay inside the module to pick
    # another sample), but wrong for bulk-load (every sample is already grabbed). The
    # next Load Sample open hits D_InitLoadSamples (~5062): Cmp SamplesInModule,0 /
    # JNE -> Jmp LSWindow_EnterLoadInSampleData, re-opening the module's internal
    # cache at the stale CurrentSample rather than re-reading the directory.
    #
    # FIX (e0b1643): at LSWS_LoopEnd, exit the module back to its directory before
    # Jmp Glbl_F3 -- the same move LSWindow_Enter makes on a folder row
    # (LSWindow_EnterInModuleError, IT_DISK.ASM:7562): SamplesInModule=0, call
    # D_InitLoadSamples (re-reads SampleDirectory into a valid directory listing),
    # CurrentSample=0. The "loaded N" info line is set AFTER the re-read so the
    # redraw can't wipe it.
    # cite: IT_DISK.ASM LSWS_LoopEnd exit-to-directory block (after the bulk loop);
    #       mirrors LSWindow_EnterInModuleError (IT_DISK.ASM:7562) ; commit e0b1643
    # cite: IT_DISK.ASM:5062 D_InitLoadSamples SamplesInModule gate (the symptom site)
    Given the user has just bulk-loaded a module's samples with Shift-Enter
    And IT has returned to the F3 Sample List
    When they move the cursor to a different sample slot and press Enter
    Then the Load Sample browser shows the directory the module was picked from
    And NOT the module's internal sample list
    # @fixed-pending-verify: assembles + links clean (IT_DISK.asm Error/Warning None,
    # IT.EXE 477032 bytes). Flip to @runtime-verified after a live DOSBox-X test:
    # bulk-load a module, F3-move, Enter -> confirm the directory reappears.
