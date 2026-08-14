# =============================================================================
# WIKI PAGE / REPORT CARD: schismtracker -> impulse-tracker port backlog
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# Between 2026-08-04 and 2026-08-07, 39 commits landed in esaruoho/schismtracker
# (branch esa/midi-real-time-sync-slave). This card is the triage of that work
# against THIS fork: what is genuinely new here, what IT already has, and what
# cannot be done here at all.
#
# WHAT THIS CARD SPAWNS (generative SEED):
#   - CODESPACE  : one child .feature per @todo scenario below, as each is taken
#                  on. This card is the index; it owns no innards itself.
#   - THINKSPACE : the portability calls -- WHY something is already-here or
#                  impossible -- so the same triage is not re-derived later.
#   - AREASPACE  : owns the schism->IT port decision record. Must NOT restate
#                  the design of features that already have their own cards.
#
# Report-card legend (tags):
#   @done         - shipped in this fork
#   @already      - IT already had it; do NOT re-port. Card named inline.
#   @todo         - genuinely new here, not started
#   @impossible   - architecturally ruled out, with the citation
#
# Sibling cards referenced below are the authority on anything marked @already.
#
# WATCH: schismtracker port backlog triage
# =============================================================================

Feature: Porting the schismtracker August 2026 work into Impulse Tracker
  As the person maintaining both forks,
  I want one triage of what crossed over, what was already here and what cannot be,
  So that nothing is ported twice and nothing impossible is attempted again.

  # --- DONE ------------------------------------------------------------------

  @done @build-verified @hw-untested
  Scenario: Shift-Right on the F5 Info Page renders the playing pattern
    # card: features/f5-info-page-shift-right-quicksave.feature
    # schism: page_info.c -- same gesture, same screen
    Given the user is on the Info Page with the song playing
    When they press Shift-Right
    Then the pattern being heard is rendered to the Quicksave folder

  # --- ALREADY IN THIS FORK: do not re-port ----------------------------------

  @already
  Scenario: Things schism gained in August that IT already had
    # Each already has its own card here, and in several cases IT had it FIRST
    # and schism was the one catching up.
    Given the schismtracker August work is compared against this tree
    Then pattern tiling on a length increase is already here    # f2-resize-tiles-pattern
    And Alt-D clone / Alt-E extend / Ctrl-O on the order list   # f11-order-list
    And Ctrl-O render to Quicksave with no import               # wav-render-quicksave
    And per-channel and whole-song WAV export                   # multi-wav
    And the note-cut toggle                                     # note-cut-toggle
    And a blank song named with its creation timestamp          # song-name-timestamp-default
    And F3/F4 carrying the cursor between the lists             # f4-f3-cursor-translate
    And MIDI clock sync and transport                           # midi-realtime-sync
    And multitimbral MIDI in, Shift-F4 and the drumkit          # midi-in-multitimbral, shift-f4-drumkit
    And Shift-Enter bulk-loading a module's samples             # shift-enter-bulk-load-from-module
    And the remembered default pattern length                   # f2-pattern-editor

  # --- IMPOSSIBLE ------------------------------------------------------------

  @impossible
  Scenario: 512-row patterns cannot be done in this fork
    # schism raised its limit from 200 to 512 rows. That is a soft clamp there
    # and an architectural wall here, already researched as a negative result.
    # cite: features/pattern-length-beyond-200.feature
    # cite: IT_PE.ASM:14687 -- PatternData segment is exactly 64000 bytes,
    #       and 200 rows * 320 bytes/row = 64000 exactly
    # cite: IT_PE.ASM:8457 -- row offsets are 16-bit (Mul DX, high word dropped),
    #       so row >= 205 wraps mod 64KB and aliases an earlier row
    # cite: NetworkPatternBlock passes Row/Height as BYTES
    Given a 512-row pattern would need 163840 bytes in the editor buffer
    Then it does not fit a real-mode segment and the port is refused

  # --- TODO: genuinely new, ranked roughly by value ---------------------------

  @todo
  Scenario: Ctrl-Shift-Right dumps every sample in the song as a WAV
    # schism: song_samples_to_quicksave_files() in disko.c, bound on the order
    # list, the info page and the sample loader. Files named
    # <song>-smpNNN-<name>.wav so the folder is browsable afterwards.
    # IT approach: walk sample slots 1..99, skip empty, write each via the
    # existing sample-save path into D_GotoRenderDirectory's target (Quicksave
    # folder). Sanitise the 26-char sample name into an 8.3 stem -- DOS has no
    # long filenames here, so the slot number has to carry the identity.
    Given a song with samples loaded
    When the user presses Ctrl-Shift-Right
    Then every non-empty sample is written to the Quicksave folder as a WAV

  @todo
  Scenario: Right shift tapped on its own drops you into the playing pattern
    # schism: a tap (pressed and released with nothing else in between) opens
    # the playing pattern with follow mode on; in the pattern editor it toggles
    # following. Held as a modifier it does nothing, so Shift-Right still works.
    # IT approach: IT_K.ASM already tracks the keyboard table (K_IsKeyDown), so
    # the tap test is "shift went down, nothing else was pressed, shift came up".
    # Needs a small state machine near the key ISR, NOT in a keymap row.
    # NOTE: IT already has a related gesture -- scrolllock-follow-from-lists --
    # so check that card first; this may be better as an extra trigger there.
    Given the user is anywhere with a song playing
    When they tap and release right shift without pressing anything else
    Then the pattern editor opens on the playing pattern with follow mode on

  @todo
  Scenario: Enter on the Info Page opens the playing pattern at the playing row
    # schism: lands on the highlighted channel, at the row playback reached,
    # with follow mode off so it stays put.
    # IT approach: PE_GotoPattern is already Extrn in IT_DISPL.ASM and
    # CurrentChannel is the Info Page's own channel cursor, so most of the
    # plumbing exists. Also listed as a @todo on the F5 card.
    Given the user is on the Info Page with a channel selected
    When they press Enter
    Then the pattern editor opens on that pattern, channel and row

  @todo
  Scenario: Tiling a pattern clears the pattern breaks it carries into repeats
    # THIS IS A LATENT BUG HERE TOO, not just a schism feature. A C00 on the
    # source's last row is the usual end-of-pattern marker; tiling copies it into
    # every repeat, so an extended pattern still stops dead at the first copy.
    # Found the hard way in schism on 2026-08-07 (a 128->512 tile rendered only
    # 128 rows of audio). IT's Alt-E / f2-resize-tiles path has the same shape.
    # schism fix: clear Cxx/Bxx on each repeat boundary except the final row.
    # IT approach: after the row-copy loop in PE_OrderList_ExtendPattern and the
    # F2 tiler, walk the boundary rows and blank command bytes C and B.
    Given a pattern whose last row carries a C00
    When it is extended or tiled to a greater length
    Then the carried breaks are cleared except the one on the new final row

  @todo
  Scenario: Alt-D clones verbatim and Shift-Alt-D clones wiping muted channels
    # schism moved this from a remembered mode to the modifier, on the grounds
    # that a key which silently changes what another key does is worse than two
    # keys. IT currently has Alt-D plus an M toggle (ClonePatternMuteWipe).
    # IT approach: Condition 11 (Shift+Alt) already exists since 9fb5ac1, so a
    # "DB 11 / DW 2020h" row on the D scancode can carry the wiping variant.
    # Decide whether to keep M as well or retire it as schism did.
    Given the user is on the F11 order list
    When they press Alt-D, then Shift-Alt-D
    Then the first clone is verbatim and the second has muted channels wiped

  @todo
  Scenario: A shortcut inverts every channel mute at once
    # schism: Ctrl-Shift-F9, exactly reversible -- pressing twice returns to the
    # starting state, so it flips between two halves of an arrangement.
    # IT approach: MuteChannelTable is reachable via Music_GetMuteChannelTable;
    # invert all 64 bytes. Cheap. Pick a key that is free in the global keylist.
    Given some channels are muted and others are not
    When the user presses the mute-flip key
    Then every channel's mute state is inverted, and pressing it again restores it

  @todo
  Scenario: Ctrl-O works from any screen, not only F2 and F11
    # schism made its equivalent global and had it target the first FREE sample
    # slot rather than overwriting the selected one.
    # IT approach: GlobalKeyList in IT_OBJ1.ASM is the place; the render itself
    # is already Far-callable (Music_ToggleWAVRender). The free-slot half is a
    # separate decision -- IT's import currently picks its own slot.
    Given the user is on the sample list or the instrument list
    When they press Ctrl-O
    Then the current pattern is rendered, as it would be from F2

  @todo
  Scenario: Rendering from the command line, without the interactive screens
    # schism: --diskwrite=OUT --pattern=N | all, and --samples to dump the
    # sample set; a 56-pattern module gave 55 WAVs in about five seconds.
    # IT approach: IT.EXE already parses a command line for the module to load
    # (IT.ASM startup). A switch could load, arm WAV render on a chosen pattern,
    # run the render to completion and exit. HARD PART: the render path is a
    # state machine driven by Music_Poll and the WAVDRV driver swap, so "run to
    # completion then exit" needs a headless pump loop, and every failure mode
    # currently surfaces as an on-screen message or a VRAM marker.
    # Worth doing only if batch rendering is actually wanted on the DOS box --
    # otherwise the Quicksave folder handoff already covers the use case.
    Given a module and a pattern number on the command line
    When IT is started with the render switch
    Then that pattern is rendered to a WAV and IT exits without drawing a screen

  @todo
  Scenario: Shift-Enter loads a whole folder, or the module you are inside
    # IT has Shift-Enter on a MODULE ROW (shift-enter-bulk-load-from-module).
    # schism widened the same key to mean "load everything in the list I am
    # looking at": a module under the cursor, a module already zoomed into, or
    # every sample in a plain folder.
    # IT approach: extend LSWindow_ShiftEnter to handle the in-library case and
    # the plain-directory case, reusing the existing per-entry load.
    Given the user is inside a module in the sample browser
    When they press Shift-Enter
    Then every sample in that module is loaded, without backing out first

  @todo
  Scenario: Enter in the pattern editor lifts the nearest instrument number
    # schism: searches up, then down, for the nearest instrument rather than
    # only lifting one sitting on the cursor's own row. The search already
    # existed there but shipped switched off with no interface.
    # IT approach: LastInstrument tracking already exists in IT_PE.ASM; the walk
    # is a column scan of PatternDataArea at 320-byte stride.
    Given the cursor is on an empty row below a note
    When the user presses Enter
    Then the instrument number from the nearest note above is picked up

  @todo
  Scenario: Alt-Up/Alt-Down page, Shift-Alt-Up/Down are home and end
    # schism added these for keyboards without page/home/end keys.
    # IT approach: pattern editor keymap rows; Shift+Alt needs Condition 11,
    # which exists. Low value on a DOS box with a full keyboard -- listed for
    # completeness rather than recommended.
    Given the user is in the pattern editor
    When they press Alt-Down
    Then the cursor pages down as Page Down would

  @todo
  Scenario: Reopening the module that was loaded last
    # schism records the path the moment a module is opened, so it survives a
    # crash, and reopens it on the next start, resuming playback.
    # IT approach: IT.CFG already has a fork extension block (PE_ForkExtConfig,
    # 12 reserved bytes) but a path needs ~70 bytes, so this wants its own
    # block appended the way QuickSaveDirectory was. D_SaveDirectoryConfiguration
    # is the write path.
    Given a module was loaded and IT was restarted
    When IT starts with no module named on the command line
    Then the module that was open last is loaded again
