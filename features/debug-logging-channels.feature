# =============================================================================
# WIKI PAGE / REPORT CARD: the debug-logging channels (how to instrument IT)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# This fork is developed on a Mac and RUN on a real DOS PC. Nothing can be
# stepped through, and a wrong guess about IT's internals costs a full
# build-deploy-press-a-key round trip. The logging channels below are how a
# question gets answered by the hardware instead of by argument -- they have
# already ended several multi-round-trip hunts, so this card exists so nobody
# re-derives them or re-learns their gotchas.
#
# WHAT THIS CARD SPAWNS (generative SEED):
#   - CODESPACE  : the log writers in IT_MUSIC.ASM (they live there because that
#                  is where the WAV render lives, not because they are musical).
#   - THINKSPACE : which channel suits which question, and the four gotchas that
#                  have each cost a round trip.
#   - AREASPACE  : owns HOW to log. Owns no feature. A card that instruments
#                  something cites this one rather than restating it.
#
# Source files linked back to this card:
#   IT_MUSIC.ASM - PE_LogStage / PE_LogEndLine / PE_LogOpenForAppend  -> PATLOG.TXT
#   IT_MUSIC.ASM - WAV_AppendErrorLog / WAV_LogState / WAV_WriteHexAX -> CTRLOLOG.TXT
#   IT_MUSIC.ASM - WAV_ProbeRenderedFile / WAV_PreCreateRenderedFile
#
# WATCH: PE_LogStage PE_LogEndLine PE_LogOpenForAppend WAV_PatLogName
#        WAV_AppendErrorLog WAV_LogState WAV_ErrorLogName WAV_WriteHexAX
#        WAV_WriteStringDSSI WAV_LastReadBytes WAV_LastFileSize
#        WAV_ProbeRenderedFile WAV_PreCreateRenderedFile
# =============================================================================

Feature: Getting facts back off the DOS PC
  As someone whose build target is a machine across the room with no debugger,
  I want two ready-made log channels and a written record of their gotchas,
  So that a question about runtime behaviour costs one round trip, not four.

  @shipped @hw-verified
  Scenario: PATLOG.TXT -- one character per event, for tracing a state machine
    # cite: IT_MUSIC.ASM PE_LogStage (Global) -- AL = one char, appended raw
    # cite: IT_MUSIC.ASM PE_LogEndLine (Global) -- writes CRLF
    # cite: PE_LogOpenForAppend -- open r/w (3D02h), else create (3Ch), seek end
    #       (4202h); returns BX=0FFFFh on failure and the caller silently no-ops
    # File: WAV_PatLogName = "PATLOG.TXT", opened by RELATIVE name -> it lands in
    #       IT's CURRENT DIRECTORY, which for an idle-path probe is IT's startup
    #       directory (E:\ITNU2026), NOT the Quicksave folder.
    # Both are Far and Global, so any .ASM can Extrn them. Every register and the
    # flags are preserved (PushF / PushAD), which is what makes it safe to drop
    # into the middle of an existing proc without reading its register contract.
    Given a state machine that reaches a wrong conclusion somewhere
    When one distinct character is emitted at each transition
    Then the sequence in PATLOG.TXT shows which transition never happened

  @shipped @hw-verified
  Scenario: A worked example -- the right-shift tap
    # features/right-shift-tap.feature: 'D' on down, 'U' on up, 'T' on tap
    # reported. Three builds had "done nothing" for three different reasons; the
    # log settled it in one press. An EMPTY file is itself the answer -- it means
    # the code holding the probe never ran, which is what pointed at the wrong
    # injection point. Working output was "DUT" once per press, seven presses,
    # no spurious taps.
    Given the probe wrote nothing at all
    Then the fault is not the logic being probed but the call site of the probe

  @shipped @hw-verified
  Scenario: CTRLOLOG.TXT -- structured named fields, for one-shot operations
    # cite: WAV_AppendErrorLog -- DS:SI = prefix; prints prefix + RenderedFilename
    #       + " bytes=HHHH size=HHHH" + CRLF. Self-rotates at 32 KB to CTRLOLOG.OLD.
    # cite: WAV_LogState -- AL = label char, prints the render's whole state as
    #       "pat= pm= sm= mm= o0= se= it= p2=" in one line
    # cite: WAV_WriteHexAX / WAV_WriteStringDSSI -- the primitives to add a field
    # File: WAV_ErrorLogName = "CTRLOLOG.TXT", also relative, so it lands wherever
    #       cwd is -- for the render that is the Quicksave folder by design, which
    #       is why a render's log and its output sit side by side.
    # Adding a field is three lines: a DB " name=",0, a WAV_WriteStringDSSI, and a
    # WAV_WriteHexAX. Cheaper than a new log.
    Given an operation that runs once and either works or does not
    Then a labelled line with its inputs and its outcome beats a character trace

  @shipped @hw-verified
  Scenario: Probing the filesystem rather than the code
    # cite: WAV_ProbeRenderedFile -- open + seek-end. bytes=FFFF means the file is
    #       not there at all; size=002C means header only; larger means real audio.
    # cite: WAV_PreCreateRenderedFile -- does the same Int 21h AH=3Ch the driver
    #       does, from the same cwd, and logs the DOS error code. This splits "our
    #       code is wrong" from "DOS/the share refused" in a single press.
    # Both are the answer to "it says it saved but there is no file": ask the
    # filesystem, in the same directory, at the same moment.
    Given a report of success with nothing on disk
    Then probe for the file from inside the same cwd and log the DOS error code

  @design-note
  Scenario: Gotcha 1 -- the log lands in cwd, so cwd is part of the question
    # Both channels open by relative name. A render chdirs to the Quicksave folder
    # first, so its log lands there; an idle-path probe never chdirs, so its log
    # lands in the startup directory. Looking in the wrong folder reads exactly
    # like "the probe never fired". When adding a probe, decide which directory it
    # will land in BEFORE deciding the feature is broken.
    Given two channels that both open by relative name
    Then a missing log file may only mean you are reading the wrong folder

  @design-note
  Scenario: Gotcha 2 -- log transitions, never polls
    # PE_LogStage opens, writes and closes per CHARACTER. That is fine a few times
    # per keypress and catastrophic inside anything polled -- and lethal on a
    # network share. Log edges, not states. And take the probe back out once it
    # has answered: a navigation key must not touch the disk in shipped code.
    Given a writer that opens and closes the file per character
    Then it belongs on state changes only, and comes out again afterwards

  @design-note
  Scenario: Gotcha 3 -- main-loop context only, never the ISR
    # Both channels use Int 21h. That is safe from the dispatcher, the idle path
    # and Music_Poll, all of which are main-loop context. It is NOT safe from
    # K_KBHandler or the mixer IRQ. If the thing being probed lives at IRQ level,
    # have the ISR set a byte and log it from the main loop.
    Given DOS calls are not reentrant
    Then instrumentation stays in main-loop context and the ISR only sets flags

  @design-note
  Scenario: Gotcha 4 -- a clean-looking value can still mean failure
    # "it=86A0" was read as a healthy render for a whole session. ECX starts at
    # 100000 = 0186A0h and the log stores the LOW WORD, so 86A0 is the counter
    # UNTOUCHED -- the loop exited on its first pass. Any counter logged as a
    # remainder needs its full-scale value written down next to it, or the healthy
    # reading and the never-ran reading are indistinguishable.
    Given a field that logs "iterations remaining"
    Then record what untouched looks like, or it will be misread as success

  @todo
  Scenario: VRAM markers, for when there is no file to read
    # Row-0 character pokes: the only channel that survives a hang or a reboot,
    # since nothing has to be flushed or closed. Used previously for the render
    # reboot hunt. Not currently wrapped in a reusable proc -- worth doing before
    # the next hang investigation rather than during one.
    Given a fault that takes the machine down before any file is closed
    Then the surviving evidence has to already be on screen
