# =============================================================================
# WIKI PAGE / REPORT CARD: Shift-Right on the F5 Info Page renders to Quicksave
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# Ported from the schismtracker fork (esaruoho/schismtracker), where the same
# gesture landed 2026-08-07 on the order list, the info page and the sample
# loader. This card covers the IT side, F5 Info Page only.
#
# WHAT THIS CARD SPAWNS (generative SEED):
#   - CODESPACE  : this .feature + .session.md, PLUS the innards below --
#                  Display_RightDispatch + Display_ResolvePattern in IT_DISPL.ASM
#                  and the retargeted DisplayListKeys Right-arrow row.
#   - THINKSPACE : the .session.md -- WHY a live-shift dispatcher rather than a
#                  DB 4 (Shift) keymap row, and why the Info Page resolves the
#                  pattern differently from the F11 order list.
#   - AREASPACE  : owns the F5 Info Page right-arrow behaviour. Must NOT touch
#                  the F11 order-list dispatchers, Music_ToggleWAVRender itself,
#                  or the WAV_NoImport flag semantics.
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @hw-verified      - run on the real DOS PC
#   @hw-untested      - NOT run on real hardware yet
#   @runtime-untested - logic verified by reading only
#
# Source files linked back to this card (grep "features/f5-info-page-shift-right"):
#   IT_DISPL.ASM - DisplayListKeys Right-arrow row (~line 234)
#   IT_DISPL.ASM - Display_RightDispatch  (live-shift dispatcher)
#   IT_DISPL.ASM - Display_ResolvePattern (playing pattern, else editor pattern)
#
# Prior art this leans on (do not re-derive):
#   IT_PE.ASM PE_OrderList_RightDispatch  - the same live-shift trick on F11
#   IT_PE.ASM PE_OrderList_RenderDispatch - arms WAV_NoImport, calls the render
#   IT_MUSIC.ASM Music_ToggleWAVRender    - AX = pattern on enter
#
# WATCH: Display_RightDispatch Display_ResolvePattern DisplayListKeys DisplayDown
#        Music_ToggleWAVRender Music_ArmRenderNoImport Music_GetPlayMode
#        PE_GetCurrentPattern K_IsKeyDown
# =============================================================================

Feature: Shift-Right on the F5 Info Page renders the playing pattern to Quicksave
  As someone watching playback on the Info Page,
  I want Shift-Right to write the pattern I can hear out as a WAV,
  So that capturing a loop is one key from the screen I am already looking at,
  without going to F11 first.

  @shipped @build-verified @hw-untested
  Scenario: Shift-Right renders the playing pattern, no sample import
    # cite: IT_DISPL.ASM Display_RightDispatch - K_IsKeyDown(02Ah/036h) live test
    # cite: IT_DISPL.ASM Display_ResolvePattern - Music_GetPlayMode CX=CurrentPattern
    # cite: IT_MUSIC.ASM Music_ArmRenderNoImport then Music_ToggleWAVRender (AX=pattern)
    Given the song is playing and the user is on the F5 Info Page
    When the user holds Shift and presses Right
    Then the pattern currently being played is rendered to the Quicksave folder
    And no sample slot is consumed (WAV_NoImport armed)
    And the channel selection does not move

  @shipped @build-verified @hw-untested
  Scenario: Plain Right still moves the channel selection
    # cite: IT_DISPL.ASM Display_RightDispatch tail-jumps to DisplayDown when no
    #       shift key is held, preserving the upstream binding exactly
    Given the user is on the F5 Info Page
    When the user presses Right without shift
    Then the selected channel moves down, as it always did

  @shipped @build-verified @hw-untested
  Scenario: Stopped, it falls back to the pattern in the editor
    # cite: IT_DISPL.ASM Display_ResolvePattern - PlayMode 0 -> PE_GetCurrentPattern
    Given playback is stopped and the user is on the F5 Info Page
    When the user holds Shift and presses Right
    Then the pattern currently loaded in the editor is rendered instead

  @shipped @build-verified @hw-untested
  Scenario: A bogus pattern number is refused rather than rendered
    # cite: IT_DISPL.ASM Display_ResolvePattern - Cmp AX,200 / JAE fail; CF=1
    Given the resolved pattern number is 200 or higher
    When the user holds Shift and presses Right
    Then nothing is rendered and the gesture is a no-op

  @design-note
  Scenario: Why a live-shift dispatcher and not a "DB 4" keymap row
    # The M_FunctionDivider modifier codes (IT_M.ASM:168) do have a Shift code
    # (4), but IT_K.ASM's K_TranslateKey3 chain decides whether a shifted arrow
    # emits a key word at all, and the Shift+modifier conditions there are
    # exactly where the fork has been bitten before (see the Shift-Alt gotcha
    # that forced Condition 11 in commit 9fb5ac1).
    #
    # PE_OrderList_RightDispatch already sidesteps all of that: it registers on
    # the PLAIN arrow key word (1CDh, modifier code 0) and asks the keyboard
    # table for the live shift state with K_IsKeyDown. That is known to work on
    # real hardware today.
    #
    # This card copies that, deliberately, rather than inventing a second
    # mechanism for the same job.
    Given two ways to detect Shift-Right exist
    Then the one already proven on the F11 order list is the one used

  @design-note
  Scenario: Why the Info Page resolves the pattern differently from F11
    # PE_OrderList_ResolvePattern falls back to the ORDER CURSOR when stopped,
    # which is right on F11 where that cursor is what you are pointing with.
    # The Info Page has no order cursor -- it is a playback view -- so it falls
    # back to the editor's current pattern via PE_GetCurrentPattern instead.
    # Same rule the schismtracker port settled on: playing -> what you hear,
    # stopped -> what you are editing.
    Given the Info Page has no order cursor to point with
    Then the stopped-case fallback is the editor's pattern, not an order row

  # --- TODO: not done on this card ------------------------------------------

  @todo
  Scenario: Ctrl-Shift-Right dumps every sample in the song as WAVs
    # schismtracker: song_samples_to_quicksave_files() -- one .wav per loaded
    # sample, named <song>-smpNNN-<name>.wav, into the sample-loader folder.
    # IT equivalent would write into the Quicksave folder via
    # D_GotoRenderDirectory and reuse the sample save path.
    Given the user is on the F5 Info Page
    When the user holds Ctrl and Shift and presses Right
    Then every loaded sample is written out as its own WAV file

  @todo
  Scenario: Enter on the Info Page jumps to the playing pattern at the playing row
    # schismtracker: info-page Enter opens the pattern being heard, on the
    # highlighted channel, at the row playback reached, with follow mode off.
    # IT equivalent: PE_GotoPattern is already Extrn in IT_DISPL.ASM, and
    # CurrentChannel is the Info Page's own channel cursor.
    Given the user is on the F5 Info Page with a channel selected
    When the user presses Enter
    Then the pattern editor opens on that pattern, that channel and that row
