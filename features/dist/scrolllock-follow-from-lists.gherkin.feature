# Pure Gherkin test extracted from features/scrolllock-follow-from-lists.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/scrolllock-follow-from-lists.feature

Feature: User Presses Scroll Lock while in F3 (Sample List) or F4 (Instrument List)
  As someone auditioning samples/instruments against a playing song,
  I want Scroll Lock on the list screens to drop me into the Pattern Editor
  with Pattern Follow Mode already on,
  So that one key takes me from "browsing a slot" to "watching the cursor
  follow playback" without a separate F2 then Scroll Lock.

  @stock @build-verified
  Scenario: Scroll Lock inside the Pattern Editor still just toggles Follow Mode
    # cite: IT_PE.ASM:722 pattern-editor keylist DB 0 / DW 146h -> PEFunction_ToggleTrace
    # cite: IT_PE.ASM:13298 PEFunction_ToggleTrace XORs TracePlayback, sets LED + info line
    # This binding is UNCHANGED. The fork only adds the list-screen behaviour.
    Given the user is already in the Pattern Editor
    When the user presses Scroll Lock
    Then Playback Tracing toggles (on->off or off->on) and the screen does not change

  @shipped @build-verified @runtime-untested
  Scenario: Scroll Lock in the Sample List opens the Pattern Editor with Follow Mode on
    # cite: IT_OBJ1.ASM:3536 SampleGlobalKeyList DB 0 / DW 146h -> PE_ScrollLockFollow
    # cite: IT_PE.ASM:13339 PE_ScrollLockFollow: Mov TracePlayback,1; SetInfoLine;
    #       K_SetScrollLock; Jmp Glbl_F2
    # cite: IT_G.ASM:224 Glbl_F2 normal path sets CurrentMode=2, returns
    #       AX=5 / DX=Offset O1_PatternEditList to the key dispatcher
    Given the user is on the Sample List (CurrentMode 3)
    When the user presses Scroll Lock
    Then Pattern Follow Mode (TracePlayback) is forced ON (not toggled)
    And the Scroll Lock LED is lit
    And the Pattern Editor opens, identical to pressing F2

  @shipped @build-verified @runtime-untested
  Scenario: Scroll Lock in the Instrument List does the same
    # cite: IT_OBJ1.ASM:6666 InstrumentGlobalKeyList DB 0 / DW 146h -> PE_ScrollLockFollow
    #       Entry sits BEFORE the DB 4 "always call I_PlayNote" catch-all so the
    #       146h match wins first.
    Given the user is on the Instrument List (CurrentMode 4)
    When the user presses Scroll Lock
    Then Pattern Follow Mode is forced ON, the LED lights, and the Pattern Editor opens

  # Ctrl-F = the Scroll-Lock action, bound ONCE in GlobalKeyList so it works on
  # every screen that falls through there. cite: IT_OBJ1.ASM GlobalKeyList
  # DB 1 / DW 6 / DD PE_ScrollLockFollow. 06h verified free (not in GlobalKeyList's
  # Ctrl block, not in the PE keyword table -- only Ctrl-F7, not on any list) -> a
  # pure ADD, never a rebind. Two bugs found+fixed getting here: DB 0 (the 146h
  # special-key flag) made Ctrl-F do NOTHING at runtime -> must be DB 1 (the
  # Ctrl+letter class, like stock Ctrl-S/Q/R); and a first cut with per-screen
  # F3/F4 copies was collapsed into this one entry.
  @shipped @build-verified @runtime-verified
  Scenario: Ctrl-F in the Sample List (F3) or Instrument List (F4)
    # RUNTIME-VERIFIED 2026-06-03: Esa confirmed on a live IT.EXE (DOSBox-X) that
    # Ctrl-F works in both F3 and F4. (I drove F3 then Ctrl-F via the GUI; Esa
    # confirmed the result.)
    Given the user is on the Sample List (F3) or Instrument List (F4)
    When the user presses Ctrl-F
    Then Pattern Follow Mode is forced ON, the LED lights, and the Pattern Editor opens

  @bug @shipped @build-verified @runtime-untested
  Scenario: Ctrl-F INSIDE the Pattern Editor (F2) toggles Follow Mode, not the config dialog
    # BUG (reported by Esa 2026-06-03): "press Ctrl-F while in the pattern editor and
    # follow pattern is on -> the F2 Pattern Editor Settings dialog opens instead of
    # follow being toggled off." Cause: PE_ScrollLockFollow always tail-jumped to
    # Glbl_F2, and a second F2 (CurrentMode==2) opens Pattern Edit Config.
    # FIX (commit e04be2c): the handler now calls Glbl_GetCurrentMode; when
    # CurrentMode==2 it toggles Follow inline (mirrors PEFunction_ToggleTrace, DS-safe)
    # and returns AX=1 (redraw) instead of re-entering Glbl_F2.
    # cite: IT_PE.ASM PE_ScrollLockFollow -> PE_SLF_Toggle branch ; commit e04be2c
    Given the user is in the Pattern Editor (CurrentMode==2) with Follow Mode ON
    When the user presses Ctrl-F
    Then Follow Mode is toggled OFF (LED + info line update)
    And the F2 Pattern Edit Config dialog does NOT open
    # @runtime-untested: fix built + relaunched; awaiting Esa's confirm

  @shipped @build-verified @runtime-untested
  Scenario: Ctrl-F on the Order List (F11) or Song Variables (F12) enters the editor
    # Same single GlobalKeyList entry; F11=O1_OrderPanningList and F12=O1_ConfigureITList
    # both chain to GlobalKeyList. From these (CurrentMode != 2) the handler forces
    # Follow ON and enters the Pattern Editor via Glbl_F2, same as the F3/F4 path.
    Given the user is on the Order List (F11) or Song Variables (F12)
    When the user presses Ctrl-F
    Then Pattern Follow Mode is forced ON, the LED lights, and the Pattern Editor opens

  @shipped @build-verified
  Scenario: Follow Mode is forced ON, never toggled off, from the lists
    # cite: IT_PE.ASM:13339 uses "Mov TracePlayback, 1" (set), NOT "Xor ...,1" (toggle)
    # Rationale: the Gherkin says "with Follow Mode enabled". Arriving from a list
    # the user's intent is unambiguously "start following", so a set is correct;
    # a toggle could land you in the editor with following OFF if it happened to
    # already be on.
    Given Pattern Follow Mode is already ON
    When the user presses Scroll Lock on the Sample or Instrument List
    Then Follow Mode stays ON (idempotent) and the Pattern Editor opens

  @shipped @build-verified
  Scenario: The handler hands Glbl_F2 the dispatcher's own DS (no segment damage)
    # cite: IT_PE.ASM:13339 Push DS (dispatcher) / Push CS Pop DS (Pattern seg for
    #       TraceMsg) / ... / Pop DS (restore) before Jmp Glbl_F2
    # Why: SetInfoLine reads its string at DS:SI, so DS must briefly point at the
    # Pattern code segment where TraceMsg lives (same trick as Glbl_Shift_F4 in
    # IT_G.ASM). Restoring DS first means Glbl_F2 runs with exactly the DS a real
    # F2 press gives it. Glbl_F2 also re-loads DS itself via Music_GetSongSegment,
    # so this is belt-and-braces, not load-bearing.
    Given Scroll Lock is pressed on a list screen
    When PE_ScrollLockFollow runs
    Then DS is the Pattern segment only across SetInfoLine, then restored for Glbl_F2

  @todo
  Scenario: (not built) Scroll Lock / Ctrl-F from other screens (Order list F11, Song vars F12)
    # Deliberately OUT OF SCOPE for now. Both 146h and 06h were added to
    # SampleGlobalKeyList + InstrumentGlobalKeyList only, NOT to GlobalKeyList, to
    # avoid yanking the user into the Pattern Editor from every screen.
    # F11 specifically is harder: its keys run through IT_PE.ASM OrderListKeyChain,
    # not a simple IT_OBJ1.ASM keylist, so adding Ctrl-F there is a separate change.
    # Esa's first ask included "F11 if free"; the refined Gherkin scoped it to F3/F4,
    # so F11 is parked here as the next step if wanted.
    Given the user is on the Order List (F11) or Song Variables (F12) screen
    When the user presses Scroll Lock or Ctrl-F
    Then nothing happens (no binding) — intentional; F11 is the pending follow-up
