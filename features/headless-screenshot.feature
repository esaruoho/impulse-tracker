# =============================================================================
# WIKI PAGE / REPORT CARD: the screen grabber (Shift-Alt-Y and the /G switch)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# Esa's idea, 2026-08-14, after three rounds of me adjusting the Shift-F1 layout
# blind: "why not write me a screenshotter so that you can boot up shift-f1
# yourself, trigger the screenshot headlessly and download it and view it". It paid
# for itself on first use -- see the @corrected scenario, which is the layout bug it
# found in one press after arithmetic had failed to.
#
# WHAT THIS CARD SPAWNS (generative SEED):
#   - CODESPACE  : M_ScreenGrab + M_ScreenGrabKey (IT_M.ASM), the /G switch
#                  (IT.ASM), the Shift-Alt-Y translation (IT_K.ASM) and its
#                  GlobalKeyList row (IT_OBJ1.ASM).
#   - THINKSPACE : why a UI on a machine you cannot attach to needs this at all,
#                  and why the file must not land in the current directory.
#   - AREASPACE  : owns screen capture. Owns no UI. Must never change what is
#                  drawn -- it only reads what is already on screen.
#
# Source files linked back to this card:
#   IT_M.ASM     - M_ScreenGrab (the grabber), M_ScreenGrabKey (the key handler),
#                  the ScreenGrab* flags and the idle-path hook
#   IT.ASM       - the /G[hhhh] switch, up to four key words queued
#   IT_K.ASM     - Shift-Alt-Y translation, condition 11, key word 1515h
#   IT_OBJ1.ASM  - GlobalKeyList row DB 1 / DW 1515h
#
# Prior art this leans on (do not re-derive):
#   features/debug-logging-channels.feature - same "get facts off the DOS box" idea
#   features/headless-batch-render.feature  - the idle-path hook and Quit_NoConfirm
#
# WATCH: M_ScreenGrab M_ScreenGrabKey ScreenGrabFlag ScreenGrabKeys ScreenGrabCount
#        ScreenGrabNext ScreenGrabWait ScreenGrabName ScreenGrabRow SCREENGRABROWLEN
#        ScreenGrabOK M_KeyBoardInput1 D_GotoRenderDirectory
# =============================================================================

Feature: Reading the screen from the build machine
  As someone changing a layout on a tracker that runs on a DOS box across the room,
  I want the screen written out as text I can read where I build,
  So that "is this cut off?" is a thing I can see rather than a thing I ask about.

  @shipped @build-verified @hw-verified
  Scenario: Shift-Alt-Y writes the current screen from any page
    # cite: IT_OBJ1.ASM GlobalKeyList - DB 1 / DW 1515h -> M_ScreenGrabKey
    # cite: IT_K.ASM - condition 11 on Y's scancode gives Shift-Alt-Y the word 1515h
    # Verified on the DOS PC 2026-08-14: Esa captured the Shift-F1 MIDI page.
    Given the user is on any screen
    When they press Shift-Alt-Y
    Then the 80x50 text screen is written out, characters only
    And the info line confirms it, or says the grab failed

  @shipped @build-verified @hw-verified
  Scenario: The file lands in the Quicksave folder, under a rotating name
    # cite: IT_M.ASM M_ScreenGrab - D_SaveCwd / D_GotoRenderDirectory / D_RestoreCwd
    # SCR-01.TXT, SCR-02.TXT, ... so a run of grabs does not overwrite itself, and
    # 8.3-legal: "scr-midiscr.txt" has 11 characters before the dot and DOS would
    # mangle it.
    Given the Quicksave folder is configured in F12
    When a grab happens
    Then it is written there as SCR-nn.TXT, whatever directory IT was browsing

  @shipped @build-verified @dosbox-verified
  Scenario: /G captures without anyone pressing anything
    # cite: IT.ASM ScreenGrab1 - /G, plus up to four optional 4-hex-digit key words
    # cite: IT_M.ASM M_KeyBoardInput1 - sends them one per idle pass, waits for the
    #       page to be drawn, grabs, then Quit_NoConfirm
    #   IT.EXE S0 G                boot screen, then quit
    #   IT.EXE S0 G11C G001C       Enter press + release first (clears the card
    #                              detection dialog), then grab
    Given IT is started with the /G switch
    When it reaches its first idle pass
    Then the screen is written out and IT quits on its own

  @corrected
  Scenario: The layout bug it found in one press, after three blind attempts
    # The Shift-F1 buttons kept being wrong and I kept adjusting geometry by
    # arithmetic. The first capture showed the actual cause immediately: the MIDI
    # monitor's counters draw at FIXED rows 35-36 --
    #     35  Counters  FA:0  FB:0  FC:0  F8:0
    #     36  Last RT byte: 0  tick=0
    # -- straight over the bottom border of a button at rows 33-35. The button was
    # never too narrow, it was being overwritten. Widening it, which is what the
    # report sounded like, could not have fixed it.
    # The six buttons now live at rows 37-47, below the counters.
    Given a layout fault reported as "the text is outside the button"
    Then look at the screen before believing the description of it

  @corrected
  Scenario: Two self-inflicted bugs, both found by using the tool on itself
    # 1. The first version wrote SCREEN.TXT by RELATIVE name, so it landed in
    #    whatever directory the file browser had last moved IT into -- Esa pressed
    #    the key, the info line said nothing, and the file was nowhere on the share.
    #    Exactly gotcha 1 of features/debug-logging-channels.feature, walked into
    #    while building a diagnostic tool. Hence D_GotoRenderDirectory.
    # 2. SCREENGRABROWLEN was "EQU $ - ScreenGrabRow" with the info-line message
    #    strings defined in between, so the length included them and every captured
    #    row carried both messages: a 9350-byte file where 4100 was expected. It is
    #    a literal 82 now (80 columns + CRLF).
    Given a tool whose whole purpose is to show what is really there
    Then the first thing to point it at is itself

  @design-note
  Scenario: Why it reads B800:0000 and drops the attributes
    # cite: IT_M.ASM M_ScreenGrab
    # IT draws through its own buffer but blits to VRAM, so by the time the idle
    # list has run the text really is at B800. That is the same primitive the fork's
    # VRAM debug markers use. Attributes are dropped and NULs become spaces: this is
    # for reading a layout, not reproducing colours, and a NUL mid-row would truncate
    # the line for anything reading the file as text.
    Given the goal is to read a layout
    Then characters are enough, and one line per row keeps it greppable

  @design-note
  Scenario: Why the key binding matters more than the switch
    # /G cannot reach every page. Shift-F1's GlobalKeyList row is DB 6 / DW 13Bh,
    # and code 6 is the MIDI code -- M_FunctionDivider9 SKIPS those rows for a
    # keypress (Test CL,CL / JNZ), so that row cannot be what makes Shift-F1 work,
    # and injecting 13Bh, 154h, 33Bh and 53Bh all left the page unchanged. Rather
    # than keep guessing key words, the grab got a key of its own: one press by
    # whoever is at the machine beats four guesses from the build machine.
    Given not every page can be reached by injecting a key word
    Then the operator's own keypress is the more reliable trigger

  @design-note
  Scenario: Shift-Alt-Y is 1515h, and the pattern editor keeps its own Shift-Alt-Y
    # The pattern editor already binds Shift-Alt-G (2222h) to halve+tile. Y had no
    # condition-11 entry at all, so 1515h was free everywhere. An object's own key
    # list is consulted before GlobalKeyList, so nothing inside F2 changes.
    Given a global key must not steal a screen's own binding
    Then pick a key word that was unbound everywhere, and let local lists win

  @todo
  Scenario: Capturing colours
    # Attributes are read and thrown away. A variant that emits them (or ANSI) would
    # let a palette problem be seen too. Not needed yet -- every layout question so
    # far has been answerable from characters alone.
    Given attributes are available in the same VRAM read
    Then a colour-aware variant is possible if a palette question ever comes up
