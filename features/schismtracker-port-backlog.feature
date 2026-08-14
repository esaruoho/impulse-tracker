# =============================================================================
# WIKI PAGE / REPORT CARD: schismtracker <-> impulse-tracker PARITY LEDGER
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# The two forks are developed together and features cross both ways. This card is
# the ledger: every one of the 39 commits on esaruoho/schismtracker
# (branch esa/midi-real-time-sync-slave, 2026-08-04..08-07) mapped to its state in
# THIS fork, plus what this fork has that schism does not.
#
# ANSWER TO "DO WE HAVE 1:1 PARITY?" -- NO, NOT YET. As of 2026-08-14:
#   31 of 39 are covered here (shipped here, or IT had them first)
#    7 are genuinely still open, listed under TODO below
#    1 is architecturally impossible here (512-row patterns)
# Nothing is left unaccounted for -- if it is not in this card, it is not in the
# schism fork either.
#
# WHAT THIS CARD SPAWNS (generative SEED):
#   - CODESPACE  : one child .feature per open item, as each is taken on. This card
#                  is the index; it owns no innards itself.
#   - THINKSPACE : the portability calls -- WHY something is already-here or
#                  impossible -- so the same triage is not re-derived later.
#   - AREASPACE  : owns the cross-fork decision record. Must NOT restate the design
#                  of features that already have their own cards.
#
# Report-card legend (tags):
#   @done         - ported and shipped in this fork
#   @already      - IT had it FIRST; schism was the one catching up. Do not re-port.
#   @todo         - genuinely still missing here
#   @impossible   - architecturally ruled out, with the citation
#   @it-only      - this fork has it, schism does not
#
# Sibling cards are the authority on anything marked @done or @already.
#
# WATCH: schismtracker parity ledger
# =============================================================================

Feature: Feature parity between Impulse Tracker and Schism Tracker
  As the person maintaining both forks,
  I want one ledger of what crossed over, what was already here, what cannot be,
  and what only exists here,
  So that nothing is ported twice, nothing impossible is attempted again, and the
  answer to "are they at parity yet" is a count rather than an impression.

  # --- DONE HERE: ported from schism, 2026-08-14 -----------------------------

  @done @hw-verified
  Scenario: Right shift tapped on its own drops you into the playing pattern
    # card: features/right-shift-tap.feature
    # schism: "Tapping right shift drops you into the playing pattern, following",
    #         "Right shift toggles follow mode inside the pattern editor",
    #         "Right shift works from anywhere, not just three pages"
    # All three schism commits are covered by the one implementation here, because
    # it synthesizes Scroll Lock's key word on the dispatcher's idle path -- which
    # is global by construction, and reuses PE_ScrollLockFollow's existing
    # toggle-inside-the-editor half.
    Given the user is anywhere with a song playing
    When they tap and release right shift without pressing anything else
    Then the pattern editor opens on the playing pattern with follow mode on
    And tapping again inside the editor switches follow mode off

  @done @hw-verified
  Scenario: Shift-Right on the F5 Info Page renders the playing pattern
    # card: features/f5-info-page-shift-right-quicksave.feature
    # schism: "Info page: Enter opens the playing pattern, Shift-Right quicksaves it"
    Given the user is on the Info Page with the song playing
    When they press Shift-Right
    Then the pattern being heard is rendered to the Quicksave folder

  @done @hw-verified
  Scenario: Enter on the Info Page opens the playing pattern at the playing row
    # card: features/f5-info-page-shift-right-quicksave.feature
    # schism: "Info page: Enter lands on the highlighted channel at the playing row",
    #         "info-page Enter lands without following"
    Given the user is on the Info Page with a channel selected
    When they press Enter
    Then the pattern editor opens on that pattern, channel and row

  @done @hw-verified
  Scenario: Every sample in the song dumped as its own WAV
    # card: features/dump-all-samples-wav.feature
    # schism: "Dump the song's samples as wavs: Ctrl-Shift-Right, and --samples
    #          headless" -- both halves are done here too
    Given a song with samples loaded
    When the user presses Ctrl-Shift-Right (or D on the Info Page)
    Then every non-empty sample is written to the Quicksave folder as a WAV

  @done @dosbox-verified @hw-untested
  Scenario: Rendering from the command line, without the interactive screens
    # card: features/headless-batch-render.feature
    # schism: "Headless: --pattern dumps pattern audio instead of the whole song"
    #   IT.EXE S0 Osong.it / N005 Osong.it / Usong.it
    #
    # This entry used to read HARD and near-pointless, on the grounds that the
    # render needed a headless pump loop. That was stale: the single-pattern render
    # had become SYNCHRONOUS, so the pump already existed. It also paid for itself
    # immediately -- rendering in a loop exposed that Music_PlayPattern was being
    # called with BX (the row count) never set, which is what had been making
    # INTERACTIVE renders write no file at all, intermittently.
    # cite: features/wav-render-quicksave.feature, the @corrected scenario
    Given a module and optionally a pattern number on the command line
    When IT is started with the render switch
    Then the patterns are rendered to WAVs and IT quits on its own

  @done
  Scenario: A shortcut inverts every channel mute at once
    # card: features/invert-channel-mutes.feature -- Ctrl-F9, in GlobalKeyList
    # schism: "Ctrl-Shift-F9 flips every channel's mute". Different key, same act:
    # Ctrl-Shift-F9 is not available here because a code-3 row matches Ctrl alone.
    Given some channels are muted and others are not
    When the user presses the mute-flip key
    Then every channel's mute state is inverted, and pressing it again restores it

  @done
  Scenario: Alt-D clones verbatim and Shift-Alt-D clones wiping muted channels
    # schism: "Order list: Alt-D clones verbatim, Shift-Alt-D clones wiping muted
    #          channels". Condition 11 (Shift+Alt) row DB 11 / DW 2020h ->
    #          PE_OrderList_ClonePatternWipe.
    # DECISION: M is KEPT on BOTH trackers -- Esa asked for both keys on both.
    # The 2026-08-14 audit of this ledger caught that schism's M had been dropped by
    # 25ca6296 and never put back, so it was restored there the same day. The two
    # differ slightly in what M means, deliberately:
    #   IT     - M is the pre-existing TOGGLE (ClonePatternMuteWipe), left alone
    #   schism - M is a third DIRECT binding for the wiping clone, because that
    #            fork had already retired the mode, and a key that silently changes
    #            what Alt-D does next is worse than a key that just does the thing
    Given the user is on the F11 order list
    When they press Alt-D, then Shift-Alt-D
    Then the first clone is verbatim and the second has muted channels wiped

  @done
  Scenario: Tiling a pattern clears the pattern breaks it carries into repeats
    # schism: "Tiling a pattern clears the pattern breaks it carries into each
    #          repeat". PE_TilePatternToLength clears cmd 2 (Bxx) / 3 (Cxx) on each
    #          repeat boundary except the new final row, and only when the source's
    #          last row carried one.
    # This was a latent bug in BOTH forks, not a schism feature: a C00 on the last
    # row is the usual end-of-pattern marker, so tiling copied it into every repeat
    # and an extended pattern still stopped dead at the first copy. Found the hard
    # way in schism on 2026-08-07 -- a 128->512 tile rendered only 128 rows.
    Given a pattern whose last row carries a C00
    When it is extended or tiled to a greater length
    Then the carried breaks are cleared except the one on the new final row

  @done
  Scenario: The order list follows the playing pattern for the render gestures
    # schism: "Order list: follow the playing pattern for quicksave and for Enter",
    #         "Order list: while playing, Shift-Right grabs the pattern being heard",
    #         "Order list: G and Enter go where the cursor points, not where
    #          playback is" -- the last of these was schism CORRECTING an overreach
    #          it had just made; this fork never made it, so there is nothing to port.
    Given a song is playing and the user is on the order list
    When they press Shift-Right
    Then the pattern being heard is the one rendered

  # --- ALREADY IN THIS FORK: schism was catching up. Do NOT re-port. ----------

  @already
  Scenario: Things schism gained in August that IT already had
    # Each has its own card here. In every one of these cases IT had it FIRST.
    Given the schismtracker August work is compared against this tree
    Then pattern tiling on a length increase is already here    # f2-resize-tiles-pattern
    And Alt-D clone into the first free slot, with M             # f11-order-list
    And Alt-E doubling a pattern, repeating its content          # f11-order-list
    And render gestures on the order-list cursor keys            # f11-order-list
    And Ctrl-O render to Quicksave, with no import               # wav-render-quicksave
    And per-channel and whole-song WAV export                    # multi-wav
    And the note-cut toggle clearing an existing cut             # note-cut-toggle
    And a blank song named with its creation timestamp           # song-name-timestamp-default
    And F3/F4 carrying the cursor between the lists              # f4-f3-cursor-translate
    And MIDI clock sync, its toggle, and transport               # midi-realtime-sync
    And multitimbral MIDI in, Shift-F4 and the drumkit           # midi-in-multitimbral, shift-f4-drumkit
    And replicating the rows above the cursor                    # alt-r-replicate
      # NOTE: IT had the FEATURE first (Alt-R / Shift-Alt-R, Paketti port) but not
      # schism's BINDING. Ctrl-Down / Ctrl-Shift-Down was added here 2026-08-14 so
      # the two forks agree on the keys as well as the behaviour.
    And Shift-Enter bulk-loading a module's samples              # shift-enter-bulk-load-from-module
    And the remembered default pattern length                    # f2-pattern-editor

  @already
  Scenario: One schism commit has no counterpart here at all
    # "sys/posix: don't call posix_spawn_file_actions_addchdir on older macOS" is a
    # macOS-only startup crash fix, raised upstream as schismtracker PR #844.
    # DOS has no equivalent; nothing to port.
    Given a platform-specific fix
    Then it is out of scope for this fork

  # --- IMPOSSIBLE ------------------------------------------------------------

  @impossible
  Scenario: 512-row patterns cannot be done in this fork
    # schism: "Allow pattern lengths up to 512 rows" -- a soft clamp there, an
    # architectural wall here. Esa's instruction was explicit: do NOT attempt it.
    # cite: features/pattern-length-beyond-200.feature
    # cite: IT_PE.ASM:14687 -- PatternData segment is exactly 64000 bytes,
    #       and 200 rows * 320 bytes/row = 64000 exactly
    # cite: IT_PE.ASM:8457 -- row offsets are 16-bit (Mul DX, high word dropped),
    #       so row >= 205 wraps mod 64KB and aliases an earlier row
    # cite: NetworkPatternBlock passes Row/Height as BYTES
    Given a 512-row pattern would need 163840 bytes in the editor buffer
    Then it does not fit a real-mode segment and the port is refused

  # --- TODO: the 7 genuine gaps, ranked by value -----------------------------

  @todo
  Scenario: Shift-Enter loads a whole folder, or the module you are already inside
    # schism: three commits -- "loads everything in the list you are looking at",
    # "works on the first press", "leaves you where you are".
    # IT has Shift-Enter on a MODULE ROW only (shift-enter-bulk-load-from-module).
    # schism widened the same key to mean "load everything in the list I am looking
    # at": a module under the cursor, a module already zoomed into, or every sample
    # in a plain folder. Its two follow-up commits are worth reading before
    # starting: the first press was being eaten by a pending type-to-find search,
    # and it was acting on key RELEASE.
    # IT approach: extend LSWindow_ShiftEnter to the in-library and plain-directory
    # cases, reusing the per-entry load. CAUTION: this is the loader area with the
    # documented hard hang, and LSWindow_EnterSample's destination-slot contract is
    # not yet pinned down.
    Given the user is inside a module in the sample browser
    When they press Shift-Enter
    Then every sample in that module is loaded, without backing out first

  @todo
  Scenario: Remembering MIDI ports and MIDI flags across restarts
    # schism: "Remember MIDI ports and MIDI flags across restarts; G carries the
    #          channel" -- it stores the PORT NAME and falls back to the index, so a
    # reordered device list does not silently open the wrong port.
    # IT approach: IT.CFG's fork extension block (PE_ForkExtConfig) already persists
    # settings, and MIDISyncEnable / MIDITransportEnable / the F8-stop flag are the
    # obvious first candidates -- those are single bytes and need no new block.
    # A port NAME needs its own appended block, the way QuickSaveDirectory got one.
    # Not previously on this ledger at all -- found during the 2026-08-14 audit.
    Given MIDI sync was enabled and a port was open
    When IT is restarted
    Then the same flags and the same port are restored

  @todo
  Scenario: Ctrl-O works from any screen, not only F2, F11 and F5
    # schism: "Make Ctrl-O global: render a pattern to a sample from any page", and
    # it targets the first FREE sample slot rather than overwriting the selected one.
    # IT approach: GlobalKeyList in IT_OBJ1.ASM, exactly as Scroll Lock and Ctrl-F9
    # were done; the render is already Far-callable. The free-slot half is a separate
    # decision -- IT's import picks its own slot.
    Given the user is on the sample list or the instrument list
    When they press Ctrl-O
    Then the current pattern is rendered, as it would be from F2

  @todo
  Scenario: Reopening the module that was loaded last
    # schism: "Reopen the module that was loaded last" plus "reopening a song
    # resumes playback". It records the path the MOMENT a module is opened, so it
    # survives a crash.
    # IT approach: IT.CFG's fork extension block has only 12 reserved bytes and a
    # path needs ~70, so this wants its own appended block. D_SaveDirectoryConfiguration
    # is the write path. Pairs naturally with the MIDI persistence item above --
    # one new block could carry both.
    Given a module was loaded and IT was restarted
    When IT starts with no module named on the command line
    Then the module that was open last is loaded again

  @todo
  Scenario: The quicksave gestures work in the sample loader too
    # schism: "Quicksave gestures work in the sample loader" -- Shift-Right kept
    # working while zoomed into a .it inside the loader, which is where you most
    # want it, since you are already looking at the folder the file lands in.
    # IT approach: a code-4 row on the loader's key list pointing at the same
    # resolver the F5 card uses. Small, once the loader is being touched anyway --
    # do it in the same pass as the Shift-Enter item.
    Given the user is inside a module in the sample loader
    When they press Shift-Right
    Then the pattern is rendered, as it would be from F5

  @todo
  Scenario: Enter in the pattern editor lifts the nearest instrument number
    # schism: "Enter lifts the nearest instrument" -- searches UP, then DOWN, rather
    # than only lifting one sitting on the cursor's own row. The search already
    # existed there but shipped switched off with no interface.
    # IT approach: LastInstrument tracking already exists in IT_PE.ASM; the walk is
    # a column scan of PatternDataArea at 320-byte stride.
    Given the cursor is on an empty row below a note
    When the user presses Enter
    Then the instrument number from the nearest note above is picked up

  @todo
  Scenario: Alt-Up/Alt-Down page, Shift-Alt-Up/Down are home and end
    # schism: two commits, added for keyboards without page/home/end keys.
    # IT approach: pattern editor keymap rows; Shift+Alt needs Condition 11, which
    # exists. LOW VALUE on a DOS box with a full keyboard -- listed for completeness
    # of the ledger rather than recommended.
    Given the user is in the pattern editor
    When they press Alt-Down
    Then the cursor pages down as Page Down would

  # --- THE OTHER DIRECTION: this fork only -----------------------------------

  @it-only
  Scenario: Things this fork has that schism does not
    # Parity is not one-directional, and these are why "1:1" will never be literal:
    # the two programs have different shapes and some of this has no schism meaning.
    Given the two forks are compared the other way round
    Then Alt-W quicksave and Shift-Alt-W memorise-folder are IT-only
    And the Shift-F1 MIDI Monitor with its RT byte counters is IT-only
    And IT.CFG's fork extension block is IT-only by construction
    And the driver-level F8-FF passthrough fix across 16 sound drivers has no
      schism counterpart, because schism has no DOS sound drivers
    And the render's synchronous faster-than-realtime pump is IT-only, because
      schism renders through its own disko subsystem

  @design-note
  Scenario: Why the counts will never reach a literal 1:1
    # Three permanent reasons, so this is not a target to chase:
    #   1. 512-row patterns are impossible here (real-mode segment arithmetic).
    #   2. Some schism commits are platform fixes with no DOS meaning, and some IT
    #      work is DOS-specific with no schism meaning.
    #   3. Where a key is already taken differently, the ACT is ported and the
    #      binding is not -- Ctrl-Shift-F9 became Ctrl-F9 here, because a code-3
    #      keymap row matches Ctrl alone and would have swallowed Ctrl-F9.
    # The useful question is not "same list?" but "is every schism feature either
    # here, deliberately declined, or written down as open?" -- which this card
    # answers, and which IS true as of 2026-08-14.
    Given two forks of different programs
    Then parity means nothing unaccounted for, not an identical feature count
