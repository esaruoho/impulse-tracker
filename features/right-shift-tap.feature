# =============================================================================
# WIKI PAGE / REPORT CARD: Right-shift TAP -> jump to the playing pattern
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# Ported from esaruoho/schismtracker, where a bare right-shift tap opens the
# playing pattern with Follow on, and toggles Follow off when you are already in
# the pattern editor.
#
# STATUS: shipped and HARDWARE-VERIFIED by Esa on the DOS PC, 2026-08-14 -- tapped
# from F5, F3, F4 and F11, each time landing in the pattern editor with Follow Mode
# on, and tapping again inside the editor switches Follow off. BOTH halves are
# confirmed. The tap is polled in the dispatcher's idle path and dispatches Scroll
# Lock's key word, reusing PE_ScrollLockFollow unchanged. The transition probe that
# proved it out has been removed again -- see the @corrected scenarios.
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE  : K_PollRightShiftTap + the disarm in K_GetKey (IT_K.ASM), and
#                  the idle-path injection in IT_M.ASM.
#                  It owns no handler of its own -- the action is
#                  PE_ScrollLockFollow's, which has its own card.
#   - THINKSPACE : why a bare modifier has no key word, why the idle spin is the
#                  only place that can give it one, and why the tap must have
#                  exactly one consumer.
#   - AREASPACE  : owns bare-modifier tap detection and its injection point.
#                  Must NOT change what Scroll Lock or Ctrl-F do, and must not
#                  change how any real key dispatches.
#
# Source files linked back to this card:
#   IT_K.ASM     - K_PollRightShiftTap (+ RShiftTapPrev / RShiftTapArmed)
#   IT_K.ASM     - K_GetKey: any non-36h scancode clears RShiftTapArmed
#   IT_M.ASM     - M_KeyBoardInput1 idle path: tap -> CX=DX=146h -> M_FunctionHandler9
#
# Prior art this leans on (do not re-derive):
#   IT_PE.ASM PE_ScrollLockFollow  - the whole action, both halves of it
#   IT_OBJ1.ASM GlobalKeyList:3247 - DB 0 / DW 146h -> PE_ScrollLockFollow
#
# WATCH: K_PollRightShiftTap RShiftTapPrev RShiftTapArmed K_GetKey K_IsKeyWaiting
#        KeyBoardTable PE_ScrollLockFollow GlobalKeyList M_KeyBoardInput1
# =============================================================================

Feature: Tapping right shift jumps to the pattern being played
  As someone jamming with a song running,
  I want a tap of right shift to drop me into the playing pattern with Follow on,
  So that "listening" and "editing what I hear" are one key apart,
  while holding right shift as a modifier keeps working normally.

  @shipped @build-verified @hw-verified
  Scenario: A tap from any other screen opens the playing pattern with Follow on
    # Verified from F5, F3, F4 and F11 on the DOS PC, 2026-08-14.
    # cite: IT_M.ASM M_KeyBoardInput1 -- on a tap, CX=DX=146h and control jumps to
    #       M_FunctionHandler9, the very instruction K_GetKey would have returned to
    # cite: IT_OBJ1.ASM GlobalKeyList - DB 0 / DW 146h -> PE_ScrollLockFollow
    # cite: IT_PE.ASM PE_ScrollLockFollow - forces TracePlayback=1, lights the
    #       Scroll Lock LED, then tail-jumps PE_GotoPattern at the playing pattern
    Given the song is playing and the user is on the sample, instrument or info page
    When they tap right shift and release it
    Then the pattern editor opens on the pattern being played
    And Follow Mode is on

  @shipped @build-verified @hw-verified
  Scenario: A tap inside the pattern editor toggles Follow Mode off
    # Verified on the DOS PC, 2026-08-14: both halves of the gesture confirmed.
    # cite: IT_PE.ASM PE_ScrollLockFollow - Glbl_GetCurrentMode == 2 -> PE_SLF_Toggle,
    #       the stock Scroll Lock behaviour. Reaching the editor via Glbl_F2 a second
    #       time is what used to open Pattern Edit Config instead.
    Given the user is in the pattern editor with Follow Mode on
    When they tap right shift
    Then Follow Mode is switched off and the screen does not change

  @shipped @build-verified @hw-untested
  Scenario: Holding it as a modifier is not a tap
    # cite: IT_K.ASM K_GetKey -- Cmp SI,36h / else Mov [RShiftTapArmed],0, so any
    #       other scancode processed between down and up disarms it. Shift-Right and
    #       friends therefore never register as taps.
    Given the user holds right shift and presses another key
    When right shift is released
    Then nothing is dispatched and the other key behaves normally

  @corrected
  Scenario: The tap must have exactly ONE consumer
    # K_PollRightShiftTap returns AX=1 exactly once per tap -- it clears
    # RShiftTapArmed as it reports. The first version polled it from Music_Poll to
    # write an "RSTAP" log line. Wiring the action in without removing that call
    # would have been silently broken: Music_Poll runs constantly, so it would have
    # eaten nearly every tap before K_GetKey ever asked. The Music_Poll call was
    # deleted, not merely stopped from logging.
    Given a one-shot poll has two callers
    Then the first caller consumes the event and the second never sees it

  @corrected
  Scenario: K_GetKey's spin is NOT the idle loop -- that cost a whole round trip
    # First working attempt polled the tap inside K_GetKey's spin
    # (K_GetKey1: Call K_IsKeyWaiting / loop while empty), reasoning that it is
    # the one place that runs while IT waits for input. It is not. The dispatcher
    # polls K_IsKeyWaiting ITSELF at IT_M.ASM M_KeyBoardInput1 and only calls
    # K_GetKey once a key is already queued, so that spin is barely ever entered:
    # the probe logged nothing at all, which is what "nothing happens" looked like.
    #
    # The real idle path is M_KeyBoardInput1's fall-through to the IdleList, which
    # is also strictly better: it is inside the dispatcher already, so a tap jumps
    # to M_FunctionHandler9 -- the instruction K_GetKey returns to -- instead of
    # faking a return value.
    Given a loop that waits for a key is not necessarily the loop that idles
    Then the poll belongs where the dispatcher decides it has nothing to do

  @corrected
  Scenario: "Any other key down?" must come from the key QUEUE, not the key-down map
    # The first detector scanned all 256 bytes of KeyBoardTable for any other key
    # held. That map is NOT maintained by the ISR -- K_KBHandler only queues raw
    # scancodes and tracks Ctrl/Alt -- it is written at IT_K.ASM:1295 as K_GetKey
    # drains the queue. So any key whose RELEASE was never processed leaves a 1
    # there for the rest of the session, and from then on every poll concludes
    # "another key is down" and the tap is dead permanently.
    # Now: K_GetKey clears RShiftTapArmed as it processes any scancode that is not
    # right shift's own. Same meaning -- "something happened between down and up" --
    # but read off a queue that is consumed rather than a map that accumulates.
    Given a key-down map is only as good as the releases that reached it
    Then the disarm is driven by processed scancodes instead

  @design-note
  Scenario: The probe shipped, proved the point, and was removed again
    # Three builds in a row "did nothing" for three different reasons. What ended
    # it was one character per state transition in the log: nothing at all meant
    # the poll was not running, which pointed straight at the injection point.
    # Removed again once verified -- PE_LogStage opens/writes/closes per character
    # and a navigation key must not touch a network share.
    Given a gesture that silently does nothing has several possible causes
    Then instrument the transitions, then take the instrument back out

  @design-note
  Scenario: Why Scroll Lock's key word and not a new one
    # PE_ScrollLockFollow already implements both halves of what is wanted here,
    # and Scroll Lock is already global (IT_OBJ1.ASM:3247). Emitting a brand new
    # fork key word would have meant a second binding to maintain and a second
    # place for the two behaviours to drift apart. The tap is a second TRIGGER for
    # an existing gesture, not a second implementation of it.
    Given an existing global key already does exactly this
    Then the new trigger synthesizes that key rather than duplicating its handler

  @todo
  Scenario: Left shift is deliberately untouched
    # Only 36h (right shift) is watched. Left shift stays a pure modifier, so
    # ordinary shifted typing can never trigger a screen change.
    Given the user taps LEFT shift
    Then nothing happens
