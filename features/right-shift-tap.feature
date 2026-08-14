# =============================================================================
# WIKI PAGE / REPORT CARD: Right-shift TAP -> jump to the playing pattern
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# Ported from esaruoho/schismtracker, where a bare right-shift tap opens the
# playing pattern with Follow on, and toggles Follow off when you are already in
# the pattern editor.
#
# STATUS: behaviour shipped. The tap now synthesizes Scroll Lock's key word from
# inside K_GetKey's idle spin, so it dispatches through IT's own key handler and
# reuses PE_ScrollLockFollow unchanged. The earlier logging probe has been
# REMOVED -- see the @corrected scenario, it could not coexist with the action.
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE  : K_PollRightShiftTap + the K_GetKey injection (IT_K.ASM).
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
#   IT_K.ASM     - K_GetKey idle spin: tap -> CX=DX=146h -> K_GetKey20
#
# Prior art this leans on (do not re-derive):
#   IT_PE.ASM PE_ScrollLockFollow  - the whole action, both halves of it
#   IT_OBJ1.ASM GlobalKeyList:3247 - DB 0 / DW 146h -> PE_ScrollLockFollow
#
# WATCH: K_PollRightShiftTap RShiftTapPrev RShiftTapArmed K_GetKey K_IsKeyWaiting
#        KeyboardTable PE_ScrollLockFollow GlobalKeyList
# =============================================================================

Feature: Tapping right shift jumps to the pattern being played
  As someone jamming with a song running,
  I want a tap of right shift to drop me into the playing pattern with Follow on,
  So that "listening" and "editing what I hear" are one key apart,
  while holding right shift as a modifier keeps working normally.

  @shipped @build-verified @hw-untested
  Scenario: A tap from any other screen opens the playing pattern with Follow on
    # cite: IT_K.ASM K_GetKey1 -- on a tap, CX=DX=146h and control leaves via
    #       K_GetKey20, so the dispatcher sees a key word like any other
    # cite: IT_OBJ1.ASM GlobalKeyList - DB 0 / DW 146h -> PE_ScrollLockFollow
    # cite: IT_PE.ASM PE_ScrollLockFollow - forces TracePlayback=1, lights the
    #       Scroll Lock LED, then tail-jumps PE_GotoPattern at the playing pattern
    Given the song is playing and the user is on the sample, instrument or info page
    When they tap right shift and release it
    Then the pattern editor opens on the pattern being played
    And Follow Mode is on

  @shipped @build-verified @hw-untested
  Scenario: A tap inside the pattern editor toggles Follow Mode off
    # cite: IT_PE.ASM PE_ScrollLockFollow - Glbl_GetCurrentMode == 2 -> PE_SLF_Toggle,
    #       the stock Scroll Lock behaviour. Reaching the editor via Glbl_F2 a second
    #       time is what used to open Pattern Edit Config instead.
    Given the user is in the pattern editor with Follow Mode on
    When they tap right shift
    Then Follow Mode is switched off and the screen does not change

  @shipped @build-verified @hw-untested
  Scenario: Holding it as a modifier is not a tap
    # cite: K_PollRightShiftTap clears RShiftTapArmed as soon as any OTHER key in
    #       KeyboardTable is down, so Shift-Right and friends never register.
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
  Scenario: The probe-first plan was right about the ISR and wrong about the queue
    # This card previously said the poll "cannot act on the tap" because a screen
    # change has to return through the key dispatcher, and listed an ISR patch or a
    # key-queue injection as the options. Neither was needed. K_GetKey's own idle
    # spin (K_GetKey1: Call K_IsKeyWaiting / loop while empty) is inside the
    # function whose RETURN VALUE is the key word -- so it can just set CX/DX and
    # leave via K_GetKey20. No IRQ-level code, no queue surgery, no new key word.
    Given the blocking key fetch has an idle spin of its own
    Then a synthesized key word can be returned from there directly

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
