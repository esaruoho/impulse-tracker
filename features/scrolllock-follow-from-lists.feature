# =============================================================================
# WIKI PAGE / REPORT CARD: Scroll Lock on F3/F4 -> Pattern Editor + Follow Mode
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/scrolllock-follow-from-lists.session.md (the vibe diff that spawned this)
#
# Durable understanding-store for "what happens when the user presses Scroll
# Lock while on the Sample List (F3) or Instrument List (F4)". Stock Impulse
# Tracker binds Scroll Lock to Playback Tracing (Pattern Follow Mode) ONLY
# inside the Pattern Editor; on the list screens it did nothing. The fork makes
# Scroll Lock there a one-key "follow playback now": it force-enables Follow
# Mode and jumps the user into the Pattern Editor, exactly as if F2 were pressed.
#
# Report-card legend (tags):
#   @stock          - upstream Impulse Tracker behaviour
#   @shipped        - fork addition, in origin/main (commit 91dfc0b)
#   @build-verified - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @runtime-untested - not yet exercised against a running IT.EXE in DOSBox-X
#
# WHAT THIS CARD SPAWNS (generative seed)
#   Codespace : the new handler PE_ScrollLockFollow in IT_PE.ASM (Pattern seg)
#               + two keylist entries in IT_OBJ1.ASM (Sample + Instrument lists).
#   Thinkspace: scrolllock-follow-from-lists.session.md (why F2-reuse over a
#               re-implementation; why force-ON not toggle; the DS save/restore).
#   Areaspace : OWNS the Scroll Lock (146h) binding on the F3 + F4 list screens.
#               MUST NOT touch the Pattern Editor's own Scroll Lock binding
#               (IT_PE.ASM PEFunction_ToggleTrace, key 146h) or Alt-Scroll-Lock
#               (MIDIInputToggle). Those remain stock/fork as-is.
#
# Source files linked back to this card:
#   IT_PE.ASM    - PE_ScrollLockFollow proc (13339); Global decl (170);
#                  reuses TracePlayback (1053), TraceMsg (1033),
#                  PEFunction_ToggleTrace (13298) as the toggle sibling.
#   IT_OBJ1.ASM  - Extrn PE_ScrollLockFollow (192);
#                  SampleGlobalKeyList entry  DB 0 / DW 146h (3536);
#                  InstrumentGlobalKeyList entry DB 0 / DW 146h (6666).
#   IT_G.ASM     - Glbl_F2 (224): the screen-switch this handler tail-jumps into.
#   IT_K.ASM     - K_SetScrollLock (1912): drives the keyboard Scroll Lock LED.
#
# Commit log (the ingest trail):
#   91dfc0b  Scroll Lock on F3/F4 lists -> Pattern Editor + Follow Mode
#            (direct to esaruoho/main; INDEX.md enrolled in a prior commit)
#
# RESULT (third leg of the triad: .feature spec + .session convo + what shipped):
#   Feature delivery : 91dfc0b (direct to esaruoho/main, no PR).
#                      Files: IT_PE.ASM, IT_OBJ1.ASM, this card + .session.md.
#                      Pushed to origin/main -> CI build.yml fires on the .ASM.
#   Build (local)    : full BUILDALL via dosbox-x -conf buildall.conf
#                      2026-06-03 12:01 EEST. IT_PE.asm + IT_OBJ1.asm assembled
#                      "Error messages: None / Warning messages: None"; tlink
#                      3.01 linked; IT.EXE 476298 -> 476375 bytes (+77).
#   Triad: this .feature <-> scrolllock-follow-from-lists.session.md <-> 91dfc0b
#
# WATCH: PE_ScrollLockFollow TracePlayback PEFunction_ToggleTrace Glbl_F2 K_SetScrollLock SampleGlobalKeyList InstrumentGlobalKeyList
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
#   2026-06-03  direct-commit  touched: PE_ScrollLockFollow TracePlayback Glbl_F2 K_SetScrollLock SampleGlobalKeyList InstrumentGlobalKeyList
#
# IT.TXT source of truth: Scroll Lock = "Toggle playback tracing" (Pattern
# Editor). This fork extends the SAME meaning to the F3/F4 list screens, where
# "toggle" becomes "enable + go to the editor that does the following".
# =============================================================================

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
  Scenario: (not built) Scroll Lock from other screens (Order list F11, Song vars F12)
    # Deliberately OUT OF SCOPE. The binding was added to SampleGlobalKeyList and
    # InstrumentGlobalKeyList only, NOT to GlobalKeyList, to avoid yanking the user
    # into the Pattern Editor from every screen that chains to GlobalKeyList.
    Given the user is on the Order List or Song Variables screen
    When the user presses Scroll Lock
    Then nothing happens (no binding) — this is intentional, revisit only if asked
