# =============================================================================
# WIKI PAGE / REPORT CARD: User Presses F11 (Order List + power tools)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/fkey-report-cards.session.md (the vibe diff that spawned this)
#
# Durable understanding-store for "what happens when the user presses F11":
# the stock order-list / panning / volume screen, and the fork's order-list
# power tools (clone, extend, mute-wipe toggle, WAV render, edge gestures).
#
# Report-card legend (tags):
#   @stock          - upstream Impulse Tracker behaviour
#   @shipped        - fork addition, in origin/main
#   @build-verified - assembles + links clean (TASM 4.1 / TLINK 3.01)
#
# Source files linked back to this card:
#   IT_OBJ1.ASM  - GlobalKeyList F11 (3194, scancode 157h) -> Glbl_F11
#   IT_G.ASM     - Glbl_F11 panning<->volume toggle (624-648)
#   IT_OBJ1.ASM  - O1_OrderPanningList (541), O1_OrderVolumeList (4849)
#   IT_PE.ASM    - OrderListKeyChain (1090-1170) + the fork handlers below;
#                  ClonePatternMuteWipe flag (287)
#   IT_MUSIC.ASM - Music_FindFreePattern (9983), Music_GetMuteChannelTable (9964)
#
# Fork order-list handlers (all IT_PE.ASM):
#   PE_OrderList_ClonePattern    2827   Alt-D clone to free slot
#   PE_OrderList_ExtendPattern   3204   Alt-E double row count (tile)
#   PE_OrderList_ToggleMuteWipe  2433   M toggles ClonePatternMuteWipe
#   PE_OrderList_ApplyMuteWipe   2604   wipe muted-channel events on clone
#   PE_OrderList_RenderDispatch  2338   Ctrl-O / Shift-Ctrl-O WAV render
#   PE_OrderList_RenderQuicksave 2374   Ctrl-G render to Quicksave, no import
#   PE_OrderList_GDispatch       2395   Shift-G render+import (plain G = goto)
#   PE_OrderList_RightDispatch   2321   Right edge: render (Shift = Quicksave)
#   PE_OrderList_LeftDispatch    2269   Left edge: clone (Shift = mute-wipe clone)
#
# Commit log (the ingest trail):
#   fb47b32  Import code (upstream base: F11 order list / panning / volume)
#   1a7aa16  F11 order list: render / clone / extend ops + mute-wipe toggle
#   4eee4f8  F11 clone auto-insert + runtime status messages
#   90cfd04  cursor-key edge gestures (note-cut at row 0 for mute-wipe clone)
#   74c3fe8  Shift-Right single-pattern Quicksave render -> LL<HHMMSS>.WAV
#
# RESULT (third leg of the triad: .feature spec + .session convo + what shipped):
#   Feature delivery : 1a7aa16, 4eee4f8, 90cfd04, 74c3fe8  (direct to esaruoho/main, no PR)
#   This card authored: 8ca97e9 (cards) + 009dbab (session + back-links)
#   Triad: this .feature  <->  fkey-report-cards.session.md  <->  those commits
#
# WATCH: Glbl_F11 PE_OrderList_ClonePattern PE_OrderList_ExtendPattern PE_OrderList_ToggleMuteWipe PE_OrderList_ApplyMuteWipe PE_OrderList_RenderDispatch PE_OrderList_RenderQuicksave PE_OrderList_GDispatch PE_OrderList_RightDispatch PE_OrderList_LeftDispatch Music_FindFreePattern Music_GetMuteChannelTable ClonePatternMuteWipe
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
#   2026-06-03  direct-commit  touched: PE_OrderList_ExtendPattern
#
# IT.TXT source of truth: lines 1221-1241 ("2.3 Order List ... (F11)") and 1747.
# =============================================================================

Feature: User Presses F11 (Order List)
  As someone sequencing patterns into a song,
  I want F11 to open the order list and toggle to channel volume, and the fork
  power tools to clone / extend / render patterns right from the order list,
  So that arranging and bouncing patterns happens without leaving this screen.

  @stock @build-verified
  Scenario: F11 opens the order list with channel panning
    # cite: IT_OBJ1.ASM:3194 GlobalKeyList F11 -> Glbl_F11
    # cite: IT_G.ASM:633 Glbl_F11_2 CurrentMode=11, returns O1_OrderPanningList
    # cite: IT.TXT:1221 "2.3  Order List, Channel panning & volume. (F11)"
    Given the user is on a screen other than the order list
    When the user presses F11
    Then CurrentMode becomes 11 and the order list + channel panning screen opens

  @stock @build-verified
  Scenario: A second F11 toggles to channel volume
    # cite: IT_G.ASM:626 Cmp CurrentMode,11 / JE Glbl_F11_1 (CurrentMode=21,
    #       returns O1_OrderVolumeList)
    # cite: IT.TXT:1239 "initial channel volumes ... F11 once you are already on
    #       the Order list and channel panning screen"
    Given the user is already on the order list panning screen (CurrentMode = 11)
    When the user presses F11
    Then CurrentMode becomes 21 and the channel volume screen opens

  @stock @build-verified
  Scenario: Stock order-list editing keys
    # cite: IT.TXT:1233-1238 spacebar mute, S surround, N = prev order's pattern+1
    Given the user is editing the order list
    Then Spacebar mutes a channel (on the panning screen)
    And S sets the initial panning to surround
    And N enters (previous order's pattern + 1)

  # --- Fork power tools (commit 1a7aa16 and follow-ups) ----------------------

  @shipped @build-verified
  Scenario: Alt-D clones the current pattern to the first free slot
    # cite: IT_PE.ASM:2827 PE_OrderList_ClonePattern;
    #       IT_MUSIC.ASM:9983 Music_FindFreePattern (first type-0 slot, 0..199)
    # cite: commits 1a7aa16, 4eee4f8
    Given the user is on the order list with a pattern selected
    When the user presses Alt-D
    Then the pattern is cloned into the first free slot (0..199) and auto-inserted
    And the order cursor advances
    And if mute-wipe is ON, muted channels are wiped with a note-cut at row 0

  @shipped @build-verified
  Scenario: Alt-E doubles the current pattern's length by tiling
    # cite: IT_PE.ASM:3204 PE_OrderList_ExtendPattern; bails if 2*N > 200;
    #       runs under ClI in PEFunction_StorePattern (live-playback-safe)
    # cite: commit 1a7aa16
    Given the current pattern has N rows
    When the user presses Alt-E
    Then rows 0..N-1 are tiled into N..2N-1, giving a 2N-row pattern
    And nothing happens if 2*N would exceed 200

  @shipped @build-verified
  Scenario: M toggles the clone mute-wipe mode
    # cite: IT_PE.ASM:2433 PE_OrderList_ToggleMuteWipe flips ClonePatternMuteWipe
    #       (IT_PE.ASM:287, default ON); IT_PE.ASM:2604 PE_OrderList_ApplyMuteWipe
    # cite: commit 1a7aa16
    Given the user is on the order list
    When the user presses M
    Then ClonePatternMuteWipe flips (default ON) and the info line shows the state
    And while ON, Alt-D's clone wipes events on currently-muted channels

  @shipped @build-verified
  Scenario: Ctrl-O renders the active pattern to WAV (Shift-Ctrl-O = no import)
    # cite: IT_PE.ASM:2338 PE_OrderList_RenderDispatch checks both Shift keys
    #       and runs the Music_ToggleWAVRender pipeline
    # cite: commit 1a7aa16
    Given the user is on the order list
    When the user presses Ctrl-O
    Then the active pattern is rendered to WAV and auto-imported as the next sample
    When the user instead presses Shift-Ctrl-O
    Then it renders to the Quicksave folder only, with no sample-slot import

  @shipped @build-verified
  Scenario: Ctrl-G and Shift-G render variants
    # cite: IT_PE.ASM:2374 PE_OrderList_RenderQuicksave (Ctrl-G, no import);
    #       IT_PE.ASM:2395 PE_OrderList_GDispatch (plain G = goto; Shift-G = render+import)
    # cite: commit 1a7aa16
    Given the user is on the order list
    When the user presses Ctrl-G
    Then the pattern renders to Quicksave with no import
    When the user presses Shift-G
    Then the pattern renders with auto-import (plain G keeps the stock goto behaviour)

  @shipped @build-verified
  Scenario: Cursor-key edge gestures clone (left) and render (right)
    # cite: IT_PE.ASM:2269 PE_OrderList_LeftDispatch (col 0: Left=clone verbatim,
    #       Shift-Left=clone with mute-wipe + ^^^ at row 0)
    # cite: IT_PE.ASM:2321 PE_OrderList_RightDispatch (col 2: Right=render+import,
    #       Shift-Right=Quicksave render named LL<HHMMSS>.WAV)
    # cite: commits 1a7aa16, 90cfd04, 74c3fe8
    Given the order cursor is at the left edge of a 3-digit pattern cell
    When the user presses Left (or Shift-Left)
    Then the pattern is cloned verbatim (or cloned with a mute-wipe note-cut)
    Given the order cursor is at the right edge of the cell
    When the user presses Right (or Shift-Right)
    Then the pattern renders with import (or to Quicksave as LL<HHMMSS>.WAV)
