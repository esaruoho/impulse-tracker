# =============================================================================
# WIKI PAGE / REPORT CARD: headless batch render + sample dump from the cmdline
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# Ported from esaruoho/schismtracker's --diskwrite / --pattern / --samples. The
# schismtracker-port-backlog card rated this HARD and possibly not worth doing,
# on the grounds that the render is "a state machine driven by Music_Poll and the
# WAVDRV driver swap" needing a headless pump loop. That assessment is now stale:
# the single-pattern render became SYNCHRONOUS (WAV_SyncRenderLoop), so the pump
# loop already exists and this turned out to be mostly plumbing.
#
# STATUS: shipped, verified under DOSBox-X on the Mac (33 patterns of
# 004_what.it rendered to 33 WAVs of real audio, plus 27 sample WAVs, clean exit).
# NOT yet run on the real DOS PC.
#
# WHAT THIS CARD SPAWNS (generative SEED):
#   - CODESPACE  : the /O /N /U switches in IT.ASM, the batch flags + idle hook in
#                  IT_M.ASM, Music_BatchRenderPatterns in IT_MUSIC.ASM.
#   - THINKSPACE : why the idle path is the only safe place to run it, why the
#                  filename has to hang off the switch letter, and the two
#                  assembly traps found on the way.
#   - AREASPACE  : owns non-interactive operation. Must NOT change any interactive
#                  gesture, and must not become a second render implementation --
#                  it drives Music_ToggleWAVRender exactly as Shift-Ctrl-O does.
#
# Source files linked back to this card:
#   IT.ASM       - /O[file] /N### /U[file], BatchInformation, StartupTailOffset,
#                  Quit_NoConfirm
#   IT_M.ASM     - BatchRenderFlag / BatchRenderPattern / BatchDumpFlag and the
#                  M_KeyBoardInput1 idle hook that runs them
#   IT_MUSIC.ASM - Music_BatchRenderPatterns, MBRP_RenderOne, WAV_BatchNaming
#   IT_DISK.ASM  - D_DumpAllSamplesWAV (reused unchanged)
#
# Prior art this leans on (do not re-derive):
#   features/dump-all-samples-wav.feature      - the sample dump itself
#   features/wav-render-quicksave.feature      - the render and its row-count fix
#   features/debug-logging-channels.feature    - how both traps were found
#
# WATCH: BatchRenderFlag BatchRenderPattern BatchDumpFlag Music_BatchRenderPatterns
#        MBRP_RenderOne WAV_BatchNaming Quit_NoConfirm BatchInformation
#        StartupTailOffset StartupTailEnd M_KeyBoardInput1 D_DumpAllSamplesWAV
# =============================================================================

Feature: Rendering a module without touching the interface
  As someone who wants a module's patterns as WAVs without driving the UI,
  I want IT to load a module, write the files and quit,
  So that a whole module can be bounced from one command line.

  @shipped @build-verified @dosbox-verified @hw-untested
  Scenario: Every pattern that has data becomes its own WAV
    # cite: IT_MUSIC.ASM Music_BatchRenderPatterns -- AX=0FFFFh walks 0..199
    # Verified: IT.EXE S0 O004_what.it -> WHA0001..WHA0033.WAV, 458KB-1.1MB each
    Given a module named on the command line after /O
    When IT is started
    Then each pattern holding data is written to the Quicksave folder as a WAV
    And empty patterns are skipped, so 200 files are never produced
    And IT quits by itself when the last one is done

  @shipped @build-verified @dosbox-verified @hw-untested
  Scenario: One pattern only
    # cite: IT.ASM BatchPattern1 -- GetDecimalNumber, rejected unless < 200
    Given /N005 is also on the command line
    When IT is started with /O
    Then only pattern 5 is rendered

  @shipped @build-verified @dosbox-verified @hw-untested
  Scenario: Every sample becomes its own WAV
    # cite: IT_DISK.ASM D_DumpAllSamplesWAV, reused with no changes
    # Verified: IT.EXE S0 U004_what.it -> SMP01..SMP27.WAV, clean exit
    Given a module named on the command line after /U
    When IT is started
    Then every loaded sample is written as SMPnn.WAV and IT quits

  @shipped @build-verified @dosbox-verified
  Scenario: No sound card is needed
    # A disk render does not touch the audio hardware, so S0 is the right way to
    # invoke a batch run -- and it is one less thing to go wrong on a machine
    # whose card is not configured.
    Given /S0 selects no sound card
    When a batch render runs
    Then the WAVs are still written

  @design-note
  Scenario: Why the work runs on the idle path and not at startup
    # cite: IT_M.ASM M_KeyBoardInput1 -- the flags are checked where the dispatcher
    #       has decided it has no key to process
    # The first idle pass is the earliest safe moment: the sound driver is loaded
    # (the render swaps it out for WAVDRV and back), the module is loaded, and the
    # screen is up. Running it inside IT.ASM's startup would race all three.
    # It also composes with the module load for free: while the startup key script
    # is still typing the filename, K_IsKeyWaiting reports a key waiting, so the
    # idle path is not reached until the load has finished.
    Given the batch needs a loaded module and an initialised driver
    Then it runs on the first pass where the dispatcher has nothing else to do

  @design-note
  Scenario: Why the filename hangs directly off the switch letter
    # IT's command line has NO '/' or '-' switch prefix -- CmdLine2 capitalises
    # every character and compares it against the switch letters, so any letter
    # anywhere is a switch. "IT.EXE 004_what.it /O" parses the 'w' of "what" as /W
    # (convert module) and the rest as its filename. A module name therefore has to
    # be attached to a letter that consumes it, exactly as /W does:
    #   IT.EXE S0 O004_what.it
    # /O then jumps into SetSoundCardDriver1, which NUL-terminates the name in place
    # and resumes normal switch parsing after it. Because /O's argument is a
    # filename, the single-pattern selector cannot also be digits on /O -- hence a
    # separate /N###.
    Given every letter on IT's command line is a switch
    Then the module name must be consumed by the switch that takes it

  @design-note
  Scenario: How a module gets loaded with no interface
    # IT has no "load this file" API reachable from startup; it has a synthetic
    # KEYSTROKE script (StartupInformation -> GetStartupKeyList2 -> a tail table),
    # which is how /W converts a module: Enter, Tab x3, Ctrl-Backspace, then the
    # filename typed one character at a time, then Enter to load, then its tail
    # (Ctrl-S, Ctrl-Q, Y) to save and quit.
    # The tail was hard-coded. It is now StartupTailOffset/StartupTailEnd, and the
    # batch switches point it at BatchInformation -- one key-loss entry, then the
    # script simply ENDS, handing control to the idle path.
    Given the only way in is the startup keystroke script
    Then batch reuses it and swaps only its tail
    And nothing about /W's behaviour changes

  @design-note
  Scenario: Batch naming must not be the timestamp
    # cite: IT_MUSIC.ASM -- WAV_BatchNaming forces the <PFX><NNNN> counter path
    # The interactive single-pattern render names files LLHHMMSS, accurate to the
    # SECOND. Several patterns render within one second, so a batch on timestamp
    # naming would have overwritten its own output and left one file where there
    # should have been thirty. Batch uses the counter naming instead.
    Given a timestamp only resolves to one second
    Then a loop that can finish twice in a second cannot be named by it

  @corrected
  Scenario: Two assembly traps, both found with breadcrumbs rather than argument
    # 1. A bare label CALLed inside a Proc Far. MBRP_RenderOne started as a label,
    #    so its Ret assembled as a FAR return -- TASM takes the width from the
    #    enclosing Proc -- while Call had pushed only IP. It returned into garbage
    #    and IT wedged after the first pattern, with that pattern's WAV already
    #    written correctly. Now a real "Proc ... Near".
    # 2. A cross-segment Call the linker would not take. Calling PE_LogStage from
    #    IT.ASM produced five "Fixup overflow" errors under /jSMART; the breadcrumb
    #    writer had to be a local proc in IT.ASM's own segment instead.
    # Both were located by one character per step in a log file, not by reasoning:
    # "Rr" with no following mark isolated the bad Ret to three instructions.
    Given assembly faults that present as an unexplained wedge
    Then one character per step narrows it to instructions, and guessing does not

  @todo
  Scenario: Rendering the whole song rather than per-pattern
    # WAV_SongMode already renders order 0 to the end via Music_PlaySong, and F10's
    # WAV button uses it -- but it takes the ASYNC finalize path, so a batch caller
    # would have to pump Music_Poll itself until WAV_RenderMode clears. Worth adding
    # as /O with no pattern restriction meaning "the song", once the per-pattern
    # path has been used in anger.
    Given the whole-song render is asynchronous
    Then batch does not drive it yet
