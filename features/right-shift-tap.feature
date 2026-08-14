# =============================================================================
# WIKI PAGE / REPORT CARD: Right-shift TAP -> jump to the playing pattern
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# STATUS: instrumentation shipped, behaviour NOT shipped. Marker-first, per the
# diagnostic-vs-fix discipline: prove the tap is detectable on real hardware
# before touching the keyboard ISR.
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE  : K_PollRightShiftTap (IT_K.ASM), WAV_LogRShiftTap +
#                  the Music_Poll hook (IT_MUSIC.ASM). Later: whatever makes a
#                  tap produce a dispatchable key word.
#   - THINKSPACE : why polling can detect the tap but cannot act on it.
#   - AREASPACE  : owns bare-modifier tap detection. Must NOT change how any
#                  existing key dispatches.
#
# Source files linked back to this card:
#   IT_K.ASM     - K_PollRightShiftTap (+ RShiftTapPrev / RShiftTapArmed)
#   IT_MUSIC.ASM - Music_Poll probe call, WAV_LogRShiftTap
#
# WATCH: K_PollRightShiftTap WAV_LogRShiftTap RShiftTapPrev RShiftTapArmed
#        Music_Poll KeyboardTable PE_ScrollLockFollow
# =============================================================================

Feature: Tapping right shift jumps to the pattern being played
  As someone jamming with a song running,
  I want a tap of right shift to drop me into the playing pattern with Follow on,
  So that "listening" and "editing what I hear" are one key apart,
  while holding right shift as a modifier keeps working normally.

  @shipped @build-verified @hw-untested
  Scenario: A tap is detected and logged
    # cite: IT_K.ASM K_PollRightShiftTap -- reads KeyboardTable (maintained by the
    #       ISR already), so it adds no IRQ-level code and cannot hang.
    # cite: IT_MUSIC.ASM Music_Poll -- polled once per main-loop pass
    Given the user presses and releases right shift with no other key in between
    When the main loop next polls
    Then one "RSTAP" line is written to CTRLOLOG.TXT

  @shipped @build-verified @hw-untested
  Scenario: Holding it as a modifier is not a tap
    # cite: K_PollRightShiftTap clears RShiftTapArmed as soon as any OTHER key in
    #       KeyboardTable is down, so Shift-Right and friends never register.
    Given the user holds right shift and presses another key
    When right shift is released
    Then no tap is logged

  @todo
  Scenario: The tap actually performs the jump
    # NOT DONE, and deliberately so. A screen change must travel back through the
    # key dispatcher as AX=5 / DX=Offset O1_PatternEditList -- that is how
    # PE_ScrollLockFollow works, by tail-jumping into Glbl_F2 from a KEY HANDLER.
    # Polled code has no such return path, so the poll cannot do the jump itself.
    #
    # Options, once the log shows detection is reliable:
    #   a) make the ISR emit a fork key word on a tap (like Condition 11 does for
    #      Shift+Alt), then bind it in GlobalKeyList to the existing handler; or
    #   b) find IT's key-queue enqueue and inject Ctrl-F's key word (06h) from the
    #      poll, reusing PE_ScrollLockFollow untouched.
    # (b) is far less invasive if such an enqueue exists.
    Given the log confirms taps are detected reliably
    When the mechanism is chosen
    Then a tap jumps to the playing pattern with Follow Mode on

  @design-note
  Scenario: Why the probe ships before the behaviour
    # The skill's diagnostic-vs-fix rule: for anything IRQ-adjacent, ship
    # instrumentation first, let the hardware answer, then fix. A speculative ISR
    # patch here risks a worse hang than the missing feature. The probe is a
    # read-only poll plus a main-loop file write.
    Given the trigger lives next to the keyboard interrupt
    Then instrumentation ships first and the ISR is left alone
