# =============================================================================
# WIKI PAGE / REPORT CARD: WAV render re-entry guard (second gesture = early-stop)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# This .feature is the durable understanding-store AND the session command for
# what happens when the user fires a WAV-render gesture AGAIN while a render is
# already in flight. Each Scenario is a verified claim about behaviour, cited to
# its source proc and the commit that shipped it. Tags are the report-card grade.
#
# WHAT THIS CARD SPAWNS (the card is a generative SEED, not a description):
#   - CODESPACE  (the file structure): this .feature + the .session.md sibling,
#                PLUS the innards in "Source files" below -- the WAV_FinalizeRequest
#                discriminator, the WAV_AlreadyActive branch in Music_ToggleWAVRender,
#                and the Music_Poll finalize site that sets the flag.
#   - THINKSPACE (the reasoning / vibe): the .session.md -- WHY a re-entrant
#                WAV_LeaveMode wedges IT, why early-stop-via-Music_Stop is the
#                Esc-equivalent, and why the guard lives centrally in the Toggle
#                proc rather than in each of the 4 dispatchers.
#   - AREASPACE  (the domain boundary): what this OWNS (the re-entry decision and
#                the early-stop path) and what it must NOT touch (the enter path,
#                the genuine auto-finalize, multi-WAV chaining, the mixer, MIDI).
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01);
#                       IT_MUSIC.asm Error/Warning = None, IT.EXE links
#   @hw-untested    - NOT run on real DOS hardware (DOSBox-X is emulation, not metal)
#   @runtime-verified - EXERCISED by actually running IT.EXE in DOSBox-X.
#                       2026-06-03: Esa pressed Right then Shift-Right on F11
#                       mid-render -- "it worked without a hitch", the in-flight
#                       render audibly cut ("neutered the stuff it was writing"
#                       = Music_Stop truncating playback), and IT did NOT wedge.
#                       The LL*.WAV files left in the repo root are that run's
#                       Quicksave-folder output (no folder configured -> cwd).
#   @runtime-untested - NOT yet exercised by running IT.EXE.
#   @stock            - upstream Impulse Tracker behaviour, not a fork addition
#
# Source files linked back to this card (grep "features/wav-render-reentry-guard"):
#   IT_MUSIC.ASM  - WAV_FinalizeRequest flag (decl ~4686);
#                   Music_ToggleWAVRender entry branch JNE WAV_AlreadyActive (~5604);
#                   WAV_AlreadyActive block (~5967) + WAV_LeaveMode flag-consume;
#                   Music_Poll sets WAV_FinalizeRequest=1 before the genuine
#                   finalize (~3207); WAV_RenderStopMsg status string
#   IT_PE.ASM     - the 4 render gestures that can re-enter mid-render:
#                   PE_OrderList_RightDispatch (2323) -> PE_OrderList_RenderDispatch
#                   (2340), PE_OrderList_RenderQuicksave (2376),
#                   PE_OrderList_GDispatch (2398), and the pattern-editor Ctrl-O
#
# Commit log (the ingest trail):
#   c9ff6b9  guard re-entrant WAV render gesture; second press early-stops to
#            Quicksave instead of wedging IT
#
# SESSION (the vibe record -- the conversation that spawned this card):
#   features/wav-render-reentry-guard.session.md
#   The card is incomplete without it. The session is the vibe-diff unit:
#   future versions diff the dialogue (requests, refinements, corrections),
#   not just the code and the card.
#
# RESULT (third leg of the triad: .feature spec + .session convo + what shipped):
#   Feature delivery : c9ff6b9 (re-entry guard) direct to esaruoho/main, no PR
#   This card authored: see the card+session commit that follows c9ff6b9
#   Triad: this .feature  <->  wav-render-reentry-guard.session.md  <->  c9ff6b9
#
# WATCH: Music_ToggleWAVRender WAV_AlreadyActive WAV_FinalizeRequest WAV_LeaveMode Music_Poll Music_Stop PE_OrderList_RightDispatch PE_OrderList_RenderDispatch PE_OrderList_RenderQuicksave PE_OrderList_GDispatch
#
# Sibling card: features/wav-render-quicksave.feature (naming + the gestures
# themselves). This card is strictly about re-entry SAFETY, not naming/import.
# =============================================================================

Feature: WAV render re-entry guard -- a second render gesture mid-render stops cleanly
  As a musician who fired a pattern-to-WAV render and then pressed a render key
  AGAIN before it finished (e.g. Right then Shift-Right at the F11 order-list
  right edge),
  I want that second press to halt the in-flight render cleanly -- like Esc --
  and let the file finish writing to the Quicksave folder,
  So that IT.EXE does not glitch/wedge with no way out, and I do not lose the
  recording or have to kill the tracker.

  # --- The bug this fixes ----------------------------------------------------

  @shipped @build-verified @hw-untested
  Scenario: The old behaviour -- a second gesture tore the driver down mid-playback
    # Documents the pre-fix wedge from the bug report; not re-runnable now that
    # c9ff6b9 fixed it. Kept as the historical "before" half of the contrast.
    # cite: before c9ff6b9, Music_ToggleWAVRender entry was "JNE WAV_LeaveMode":
    #       any re-entry while WAV_RenderMode=1 ran the heavyweight leave swap
    #       (Music_Stop / UnInitSoundCard / UnloadDriver / AutoDetect /
    #       SoundCardLoadAllSamples + import) on top of a LIVE play engine,
    #       before WAVDRV got its Poll(AX=0) file-close window.
    Given a single-pattern WAV render is playing (WAV_RenderMode = 1)
    When the user presses a render gesture a second time
    Then (old) the leave path ran re-entrantly mid-playback
    And (old) IT.EXE glitched/wedged with no Esc out -- the reported bug

  # --- The trigger: Right then Shift-Right at the order-list right edge -------

  @shipped @build-verified @runtime-verified @hw-untested
  Scenario: Right starts the render, Shift-Right during it halts and finalizes
    # cite: IT_PE.ASM PE_OrderList_RightDispatch (2323) at OrderCursor==2 ->
    #       PE_OrderList_RenderDispatch (2340) -> Music_ToggleWAVRender
    # cite: IT_MUSIC.ASM entry "JNE WAV_AlreadyActive" (~5604); WAV_AlreadyActive
    #       (~5967) sees WAV_FinalizeRequest=0 (user re-press) -> Music_Stop +
    #       re-arm auto-finalize + status msg, then WAV_ToggleDone
    Given the F11 Order List is open with the cursor on the right-most order char
    And the user pressed Right, starting a render of the active pattern
    When the user presses Shift-Right while that render is still going
    Then the render is halted as if Esc were pressed (Music_Stop -> PlayMode 0)
    And IT does NOT re-enter the heavyweight driver-swap leave path
    And the diskwrite to the Quicksave folder finalizes cleanly via Music_Poll
    And IT.EXE does not wedge -- no need to kill it

  # --- The discriminator: WAV_FinalizeRequest --------------------------------

  @shipped @build-verified @hw-untested
  Scenario: WAV_FinalizeRequest tells the genuine finalize apart from a re-press
    # cite: IT_MUSIC.ASM Music_Poll auto-finalize sets WAV_FinalizeRequest=1
    #       (~3207) immediately before calling Music_ToggleWAVRender with AX=0
    # cite: WAV_AlreadyActive checks the flag: NZ -> real WAV_LeaveMode; Z ->
    #       early-stop. AX=0 alone could not discriminate -- pattern 0 is valid.
    Given a render is in flight (WAV_RenderMode = 1)
    When Music_ToggleWAVRender is re-entered
    Then if WAV_FinalizeRequest = 1 (Music_Poll's genuine leave) the real
      WAV_LeaveMode path runs and consumes the flag (sets it back to 0)
    And if WAV_FinalizeRequest = 0 (a user re-press) the early-stop path runs

  @shipped @build-verified @hw-untested
  Scenario: The genuine auto-finalize is unchanged -- still leaves + imports
    # cite: Music_Poll: RenderMode=1 AND AutoFinalize=1 AND PlayMode=0, wait 3
    #       frames (WAVDRV closes file), set WAV_FinalizeRequest=1, call Toggle
    Given a render whose pattern playback has ended naturally (PlayMode = 0)
    When Music_Poll's finalize delay elapses
    Then it sets WAV_FinalizeRequest and calls the leave path as before
    And the rendered file is imported (or left in Quicksave per the session flag)

  # --- Why this is the Esc-equivalent ----------------------------------------

  @shipped @build-verified @runtime-verified @hw-untested
  Scenario: Early-stop reuses the existing safe finalize, not a new teardown
    # cite: the early-stop branch does ONLY: Music_Stop; WAV_AutoFinalize=1;
    #       WAV_FinalizeDelay=0; show WAV_RenderStopMsg; Jmp WAV_ToggleDone.
    #       It does NOT touch the driver -- Music_Poll's 3-frame-delayed leave
    #       (the proven path) does the close + diskwrite a tick later.
    Given the user re-pressed a render gesture mid-render
    When the early-stop branch runs
    Then it only stops playback and re-arms the async finalize
    And the actual driver close/diskwrite happens via the normal Music_Poll path
    And the status line shows "Render halted -- finalizing to Quicksave ..."

  # --- Boundary: what this guard does NOT change -----------------------------

  @shipped @build-verified @hw-untested
  Scenario: All render entry points share the one central guard
    # cite: the guard lives in Music_ToggleWAVRender (the single chokepoint),
    #       so PE_OrderList_RenderDispatch, PE_OrderList_RenderQuicksave,
    #       PE_OrderList_GDispatch and the pattern-editor Ctrl-O are all covered
    Given any of the WAV-render gestures
    When it re-enters Music_ToggleWAVRender while a render is live
    Then the same early-stop protection applies -- not just the order-list path

  @shipped @build-verified @hw-untested
  Scenario: Multi-WAV sweep finalize and chaining are untouched
    # cite: WAV_MultiAdvance / WAV_MultiFinish re-enter Toggle only to ENTER the
    #       next channel (RenderMode=0 at that point), so WAV_AlreadyActive is
    #       not taken; the multi-WAV Esc abort in Music_Poll is independent.
    Given a multi-channel WAV sweep is running
    When a channel finalizes and the next is kicked
    Then the re-enter is an ENTER (RenderMode=0) and bypasses the guard
    And the existing multi-WAV Esc-abort behaviour is unaffected
