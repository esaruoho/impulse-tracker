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
#                  Display_RenderQuicksave + Display_ResolvePattern in IT_DISPL.ASM
#                  and the DisplayListKeys rows that reach them.
#   - THINKSPACE : the .session.md -- why a modified key must be caught by the
#                  keymap (code 4) and not by the handler, and why the Info Page
#                  resolves the pattern differently from the F11 order list.
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
#   IT_DISPL.ASM - DisplayListKeys: Right registered TWICE (code 0 -> DisplayDown,
#                  code 4 -> Display_RenderQuicksave) plus code 1 / 0Fh for Ctrl-O
#   IT_DISPL.ASM - Display_RenderQuicksave (arm no-import, resolve, render)
#   IT_DISPL.ASM - Display_ResolvePattern  (playing pattern, else editor pattern)
#
# RESULT: hardware-verified by Esa on the DOS PC, 2026-08-14. Shift-Right on F5
# renders the playing pattern to E:\ITNU2026 with no sample slot consumed.
#
# Prior art this leans on (do not re-derive):
#   IT_PE.ASM OrderListKeys:1121-1130     - the plain+shift row pair this copies
#   IT_PE.ASM PE_OrderList_RenderDispatch - arms WAV_NoImport, calls the render
#   IT_MUSIC.ASM Music_ToggleWAVRender    - AX = pattern on enter
#
# WATCH: Display_RenderQuicksave Display_ResolvePattern DisplayListKeys DisplayDown
#        Music_ToggleWAVRender Music_ArmRenderNoImport Music_GetPlayMode
#        PE_GetCurrentPattern K_IsKeyDown
# =============================================================================

Feature: Shift-Right on the F5 Info Page renders the playing pattern to Quicksave
  As someone watching playback on the Info Page,
  I want Shift-Right to write the pattern I can hear out as a WAV,
  So that capturing a loop is one key from the screen I am already looking at,
  without going to F11 first.

  @shipped @build-verified @hw-verified
  Scenario: Shift-Right renders the playing pattern, no sample import
    # cite: IT_DISPL.ASM DisplayListKeys - DB 4 / DW 1CDh -> Display_RenderQuicksave
    # cite: IT_DISPL.ASM Display_ResolvePattern - Music_GetPlayMode CX=CurrentPattern
    # cite: IT_MUSIC.ASM Music_ArmRenderNoImport then Music_ToggleWAVRender (AX=pattern)
    Given the song is playing and the user is on the F5 Info Page
    When the user holds Shift and presses Right
    Then the pattern currently being played is rendered to the Quicksave folder
    And no sample slot is consumed (WAV_NoImport armed)
    And the channel selection does not move

  @shipped @build-verified @hw-verified
  Scenario: Plain Right still moves the channel selection
    # cite: IT_DISPL.ASM DisplayListKeys - DB 0 / DW 1CDh -> DisplayDown, the
    #       upstream row, left exactly as it was
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

  @corrected
  Scenario: It IS a "DB 4" keymap row -- the first attempt got this wrong
    # The first attempt registered ONLY the plain arrow (code 0) and tested shift
    # inside the handler with K_IsKeyDown -- on the mistaken belief that this was
    # how F11 caught Shift-Right. It is not. Code 0 compares the FULL CX, and a
    # held shift changes CH, so the row never matched and the handler was never
    # reached: pressing Shift-Right did nothing whatsoever.
    #
    # OrderListKeys registers the arrow TWICE (IT_PE.ASM:1121-1130): code 0 for
    # the plain press and code 4 for the shifted one. Code 4 gates on Test CH,6
    # and compares CX AND 1FFh, which for Right is 0x100|0xCD = 1CDh. The
    # K_IsKeyDown call inside the F11 handler only chooses import vs no-import
    # AFTER dispatch -- it is not what triggers it.
    #
    # features/KEYMAPS.generated.md now dumps these tables from source, including
    # a "registered more than once" list, so this cannot be misread again.
    Given a modified key must be caught by the keymap, not by the handler
    Then the arrow is registered twice, exactly as OrderListKeys does it

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
