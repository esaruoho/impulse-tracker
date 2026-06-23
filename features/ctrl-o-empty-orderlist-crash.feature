# =============================================================================
# WIKI PAGE / REPORT CARD: Order-list render gestures must not crash, reboot, or hang
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# All the single-pattern WAV-render gestures funnel into Music_ToggleWAVRender:
#   - Ctrl-O (F2 pattern editor)            -> render + auto-import to next sample
#   - Right-arrow at the order-list edge    -> promote to render + auto-import
#   - Shift-Right at the order-list edge    -> render to Quicksave only (no import)
#   - Ctrl-G / Shift-G (F11)                -> render to Quicksave / render+import
# Two independent bugs made every one of them dangerous. Esa, 2026-06-23:
#   "zero patterns in order list, F6 playing, pressed Ctrl-O -> immediately crashed
#    and REBOOTED the whole drive" ; and "added 000 pattern, pressed right-arrow ->
#    impulsetracker.exe also became UNRESPONSIVE."
#
# BUG 1 -- REBOOT (invalid pattern -> wild pointer). After a render, resume-after-
#   render calls Music_PlayPartSong (IT_MUSIC.ASM ~9402), which reads OrderList[order]
#   straight into CurrentPattern with NO marker check. An empty order list is
#   OrderList[0]=0FFh, so CurrentPattern=255. The next tick calls Music_GetPattern(255)
#   which did LEA SI,[63912+EAX*4] with no bound -> indexes 220 bytes PAST the
#   200-entry pattern table -> LodsW dereferences a wild segment -> real-mode
#   triple-fault -> the machine REBOOTS. (F6 alone is safe: the engine's order-advance
#   UpdateData_Song gates markers with Cmp CL,200/JB; the resume shortcut bypasses it.)
#   FIX: bound-check the chokepoint -- Music_GetPattern Cmp AX,200 / JAE EmptyPattern.
#
# BUG 2 -- HANG (single-pattern render never terminates). Music_PlayPattern LOOPS the
#   pattern by default; the single-pattern render then drives a synchronous Music_Poll
#   loop (WAV_SyncRenderLoop) that waits for PlayMode==0. The only stop-at-pattern-end
#   mechanism is StopEndOfPlaySection (read at UpdateData_Pattern1 ~8946) -- declared
#   DW 0 and NEVER set anywhere in the codebase -- so the pattern looped forever and
#   the sync loop spun to its 100000-iteration cap: IT went 'unresponsive'.
#   FIX: set StopEndOfPlaySection=1 before the single-pattern Music_PlayPattern (render
#   ONE pass then stop), cleared back to 0 at WAV_LeavePostImport so normal F5/F6
#   playback still loops. Song-mode render already terminates (order-advance double-wrap).
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE  : this .feature + .session.md, the Music_GetPattern bound guard, the
#                  StopEndOfPlaySection set/clear in Music_ToggleWAVRender, and the
#                  documented leak source Music_PlayPartSong.
#   - THINKSPACE : the .session.md -- why F6 is safe but resume is not; why the sink
#                  guard is the right altitude; why a looping pattern wedges the sync
#                  loop and StopEndOfPlaySection is the terminator.
#   - AREASPACE  : owns the pattern-number bound in Music_GetPattern and the one-pass
#                  render terminator. Must NOT change valid-pattern resolution (0..199)
#                  and must NOT let StopEndOfPlaySection leak into normal playback.
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean; IT_MUSIC.asm Error/Warning = None, IT.EXE links
#   @runtime-untested - not yet run
#   @hw-untested      - not yet confirmed on the real DOS hardware that rebooted/hung
#   @known-limit      - a deliberately-not-done boundary, recorded honestly
#
# Source files linked back to this card (grep "features/ctrl-o-empty-orderlist-crash"):
#   IT_MUSIC.ASM - Music_GetPattern: `Cmp AX,200 / JAE Music_GetPattern_Empty` guard (~3504)
#   IT_MUSIC.ASM - Music_ToggleWAVRender: `StopEndOfPlaySection=1` before single-pattern
#                  Music_PlayPattern; cleared at WAV_LeavePostImport
#   IT_MUSIC.ASM - Music_PlayPartSong (~9402): documented leak SOURCE (no marker check)
#   IT_PE.ASM    - PE_OrderList_RightDispatch / RenderDispatch / RenderQuicksave / GDispatch
# Commit log:   128ab04  bound-check Music_GetPattern (reboot)
#               4041e66  terminate single-pattern WAV render (hang)
# SESSION:      features/ctrl-o-empty-orderlist-crash.session.md
# RESULT-LOG >> (auto-maintained by convey hooks — newest below)
#   2026-06-23  direct-commit  touched: StopEndOfPlaySection WAV_LogState
# WATCH: Music_GetPattern Music_GetPattern_Empty Music_PlayPartSong StopEndOfPlaySection WAV_LogState
# =============================================================================

Feature: Order-list and Ctrl-O render gestures must never crash, reboot, or hang
  As an Impulse Tracker user rendering a pattern to WAV,
  I want every render gesture to be safe regardless of order-list state,
  So that Ctrl-O, right-arrow, and Shift-right can't reboot DOS or wedge the program.

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: an out-of-range pattern number resolves to EmptyPattern, never a wild pointer
    # cite: IT_MUSIC.ASM Music_GetPattern (~3504) — Cmp AX,200 / JAE Music_GetPattern_Empty
    #       guards before LEA SI,[63912+EAX*4]; commit 128ab04
    Given the playback engine asks for a pattern numbered 200 or higher
    When Music_GetPattern is called with that number
    Then it returns the safe EmptyPattern instead of indexing past the 200-entry table
    And no LodsW dereferences a segment read from out-of-bounds garbage

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: empty order list, F6 playing, Ctrl-O — no longer reboots
    # cite: trigger Music_PlayPartSong (~9402) sets CurrentPattern=0FFh; the
    #       Music_GetPattern guard (~3504) neutralises it; commit 128ab04
    Given the order list has zero pattern entries (OrderList[0] = 0FFh end marker)
    And a song is playing because the user pressed F6
    When the user presses Ctrl-O to render the pattern to WAV
    Then the resume sets CurrentPattern to 255 but the next Music_GetPattern returns EmptyPattern
    And Impulse Tracker keeps running instead of triple-faulting and rebooting DOS

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: a single-pattern render stops after one pass instead of hanging
    # cite: IT_MUSIC.ASM Music_ToggleWAVRender — StopEndOfPlaySection=1 before the
    #       single-pattern Music_PlayPattern; UpdateData_Pattern1 (~8946) stops at end;
    #       cleared at WAV_LeavePostImport; commit 4041e66
    Given one pattern (000) in the order list and the cursor on the order list
    When the user presses right-arrow at the edge (promotes to a render)
    Then the pattern renders exactly one pass, PlayMode hits 0, the sync loop exits
    And IT finalizes the WAV instead of spinning the 100000-iteration cap (the hang)

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: the render terminator never leaks into normal playback
    # cite: IT_MUSIC.ASM WAV_LeavePostImport clears StopEndOfPlaySection to 0; commit 4041e66
    Given a single-pattern render has finished and cleaned up
    When the user afterwards presses F5 or F6 to play normally
    Then playback loops as before (StopEndOfPlaySection is back to 0)

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: all three gestures share the one hardened render path
    # cite: IT_PE.ASM PE_OrderList_RightDispatch -> RenderDispatch (shift = Quicksave-only),
    #       PEFunction_RenderPattern (Ctrl-O), all -> Music_ToggleWAVRender
    Given Ctrl-O (auto-import), right-arrow (auto-import), and Shift-right (Quicksave-only)
    When any of them triggers a single-pattern render
    Then all flow through Music_ToggleWAVRender with the bound guard and the terminator
    And none can reboot or hang on an empty or one-pattern order list

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: each render writes a back-and-forth debug line to CTRLOLOG.TXT
    # cite: IT_MUSIC.ASM WAV_LogState — 'E' line after START (inputs), 'X' line at
    #       sync exit (outcome); lands in the Quicksave dir E:\ITNU2026 = /Volumes/netdrive/ITNU2026
    Given a render gesture runs with the Quicksave folder set to E:\ITNU2026
    When the render enters and (for a single pattern) finishes its sync loop
    Then CTRLOLOG.TXT gains an "E pat=.. o0=.. se=.." inputs line and an "X .. it=.." outcome line
    And the operator on the Mac reads it at /Volumes/netdrive/ITNU2026/CTRLOLOG.TXT
    And it=0000 on the X line flags a render that hit the cap (hung); o0=00FF flags an empty order list

  @known-limit
  Scenario: the reboot leak SOURCE (Music_PlayPartSong) is documented, not yet hardened
    # cite: IT_MUSIC.ASM Music_PlayPartSong (~9402) still stores OrderList[order] with no marker check
    Given Music_PlayPartSong is a public proc used by resume and other callers
    When it starts at an order whose byte is a 0FEh/0FFh marker
    Then it still stores that marker as CurrentPattern (semantically wrong)
    But the Music_GetPattern sink guard prevents the catastrophic out-of-bounds dereference
