# =============================================================================
# WIKI PAGE / REPORT CARD (DIGEST): Impulse Tracker fork — features baked
#   2026-06-03 → 2026-06-04
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/recent-features-2026-06-03_to_04.session.md
#
# A 2-day ROLLUP. Each scenario is one shipped feature, graded and pointing at
# its own full triad card (the detail lives there; this is the index-as-card).
# All feature commits are direct-to-esaruoho/main, no PR.
#
# Report-card legend (tags):
#   @shipped          - in origin/main
#   @build-verified   - assembles + links clean (full BUILDALL, Error/Warning None)
#   @hw-untested    - NOT run on real DOS hardware (DOSBox-X is emulation, not metal)
#   @runtime-verified - confirmed on a live IT.EXE in DOSBox-X
#   @runtime-untested - built, NOT yet exercised against a running IT.EXE
#   @removal          - a feature deliberately taken back out (behaviour = upstream)
#
# (No machine `# WATCH:` line: this is a hand-maintained digest spanning many
#  symbols across many files; the per-feature cards carry the WATCH lines that the
#  .githooks stamper tracks.)
#
# RESULT (the 2-day commit ledger, newest first):
#   e04be2c  Ctrl-F in Pattern Editor toggles Follow (not the F2 config dialog)
#   eb6b4ea  Ctrl-F: one GlobalKeyList entry -> works F2/F3/F4/F11/F12
#   d437f78  Ctrl-F flag fix DB 0 -> DB 1 (was doing nothing)
#   97b28e9  Ctrl-F on F3/F4 = Scroll-Lock action
#   91dfc0b  Scroll Lock on F3/F4 -> Pattern Editor + Follow Mode
#   460a6e1 e5e5c38  Sample Amplify (Alt-M) keeps playback
#   3a6a434 8c32fd2  Shift-F4 multitimbral 3-state cycle + enter Instrument mode
#   478b638  F4 instrument-list play dots in multitimbral Sample mode
#   05c70c9  F2 pattern-length increase tiles content (not blank rows)
#   32e080c  Shift-Enter bulk-load .MOD hard-hang fix
#   c9ff6b9  WAV render re-entry guard (2nd press early-stops to Quicksave)
#   74c3fe8 be595b2  WAV Quicksave render -> LL<HHMMSS>.WAV (.000 -> .WAV)
#   727fc60  Samples->Instruments envelope retention REMOVED (back to upstream)
#   + report cards carded this window: midi-realtime-sync, midi-in-multitimbral,
#     alt-r-replicate, multi-wav, f2/f3/f4/f11/f12 (older features, newly carded)
# =============================================================================

Feature: Impulse Tracker fork — what got baked in 2026-06-03 → 04
  As the musician driving this fork,
  I want one page that lists every behaviour added/changed in the last two days,
  each graded honestly and linked to its own detailed card,
  So that I can see at a glance what is live, what is only build-verified, and
  what still needs a runtime check.

  # --- Navigation / Follow ---------------------------------------------------

  @shipped @build-verified @runtime-verified @hw-untested
  Scenario: Ctrl-F (and Scroll Lock) jump to the Pattern Editor with Follow ON
    # detail: features/scrolllock-follow-from-lists.feature
    # Scroll Lock or Ctrl-F on F3/F4 -> force Follow Mode + open Pattern Editor.
    # Ctrl-F is one GlobalKeyList entry, so it reaches F2/F3/F4/F11/F12; F2 has a
    # dedicated handler so Ctrl-F there toggles Follow, not the config dialog.
    # RUNTIME-VERIFIED on F3/F4 (Esa, live IT.EXE). F11/F12 same binding, to-confirm.
    Given the user is on F3/F4 (verified) or F2/F11/F12 (same binding)
    When the user presses Ctrl-F (or Scroll Lock on F3/F4)
    Then Follow Mode is forced ON and the Pattern Editor opens

  # --- WAV render ------------------------------------------------------------

  @shipped @build-verified @runtime-verified @hw-untested
  Scenario: Single-pattern Quicksave renders are LL<HHMMSS>.WAV
    # detail: features/wav-render-quicksave.feature  (commits be595b2, 74c3fe8)
    Given a single-pattern Quicksave render (F11 Shift-Right, Ctrl-O, etc.)
    Then the file is a real .WAV named by wall-clock time, e.g. LL163422.WAV

  @shipped @build-verified @runtime-verified @hw-untested
  Scenario: A second render gesture mid-render no longer wedges IT
    # detail: features/wav-render-reentry-guard.feature  (commit c9ff6b9)
    Given a render is in progress
    When a second render gesture arrives
    Then it early-stops like Esc and finalizes to Quicksave instead of re-entering teardown

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Multi-WAV per-channel + whole-song WAV/MWAV  (NOT runtime-tested)
    # detail: features/multi-wav.feature -- carries a READ-FIRST untested banner
    Given Shift-Alt-M, or the F10 WAV / MWAV buttons
    Then per-channel / whole-song WAVs are rendered -- machinery shipped, NOT yet run

  # --- Loading ---------------------------------------------------------------

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Shift-Enter on a module row bulk-loads all its samples (.MOD hang fixed)
    # detail: features/shift-enter-bulk-load-from-module.feature (+ load-from-sample-list)
    #         commit 32e080c fixed a .MOD hard-hang (loader-cache finalisation)
    Given a module row in the Sample List loader browser
    When the user presses Shift-Enter
    Then all its samples load into consecutive slots (names + loop modes preserved)

  # --- Multitimbral MIDI-in --------------------------------------------------

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Shift-F4 cycles multitimbral build + enters Instrument mode
    # detail: features/midi-in-multitimbral.feature + shift-f4-enters-instrument-mode.feature
    #         commits 8c32fd2 (3-state cycle 16->96->16 + Shift-F1 toggle), 3a6a434
    Given samples loaded
    When the user presses Shift-F4 and confirms
    Then 01-16 instruments are built, the router is enabled, and Instrument mode shows

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: F4 instrument list shows live play dots in multitimbral Sample mode
    # detail: features/multitimbral-instrument-play-dots.feature  (commit 478b638)
    Given multitimbral MIDI-in playing while in Sample mode
    Then F4 mirrors F3 and shows live play dots

  # --- Pattern editor / sample ops -------------------------------------------

  @shipped @build-verified @runtime-verified @hw-untested
  Scenario: F2 pattern-length increase tiles the existing rows
    # detail: features/f2-resize-tiles-pattern.feature  (commit 05c70c9)
    Given an F2 Pattern-Edit-Config row-count increase (e.g. 64 -> 128)
    Then the existing rows are duplicated to fill, not padded with blanks

  @shipped @build-verified @runtime-verified @hw-untested
  Scenario: Sample Amplify (Alt-M) no longer stops the song
    # detail: features/sample-amplify-keeps-playback.feature (commits e5e5c38, 460a6e1)
    Given a song is playing
    When the user amplifies/normalizes a sample with Alt-M
    Then only that sample's voices are silenced; every other channel keeps playing

  # --- Removal (honest tombstone) --------------------------------------------

  @shipped @build-verified @removal @hw-untested
  Scenario: F12 Samples->Instruments envelope retention was removed (back to upstream)
    # detail: features/no-samples-to-instruments-envelope-retention.feature (commit 727fc60)
    # The brittle envelope-preserve feature (EMM386 #12 crash class) is removed
    # for good; F12 Samples->Instruments now clears+remaps like upstream.
    Given F12 Samples->Instruments
    Then it behaves as upstream (clear + remap), the retention path is gone

  # --- Carded-this-window (older features that GOT their report card) ---------

  @shipped @build-verified @hw-untested
  Scenario: Pre-existing features that received their triad card in this window
    # No code change -- just the wiki catching up. Detail in each card:
    #   midi-realtime-sync, midi-in-multitimbral, alt-r-replicate, multi-wav,
    #   f2-pattern-editor, f3-sample-list, f4-instrument-list, f11-order-list,
    #   f12-song-variables.
    Given the report-card system was stood up this window
    Then these existing behaviours each gained a graded, source-linked card
