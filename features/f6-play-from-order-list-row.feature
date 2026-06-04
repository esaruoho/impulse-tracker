# =============================================================================
# WIKI PAGE / REPORT CARD: F6 in the Order List plays from the selected order row
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# When the user is in the F11 Order List and presses F6, playback starts from the
# SELECTED order row (Music_PlaySong from `Order`) instead of looping the pattern
# editor's current pattern. Each Scenario is a verified claim, cited to its source
# proc and the commit that shipped it. Tags are the report-card grade.
#
# WHAT THIS CARD SPAWNS (generative SEED, not a description):
#   - CODESPACE  : this .feature + .session.md, PLUS the innards -- the
#                  CurrentMode==11 gate in Glbl_F6 and the Order/Music_PlaySong
#                  read.
#   - THINKSPACE : the .session.md -- why F6 (not F7, already order-aware), why
#                  Music_PlaySong(Order) (song-from-order, not loop-one-pattern),
#                  and why the gate keeps F6 stock everywhere else.
#   - AREASPACE  : owns ONLY F6's behaviour in CurrentMode==11; must NOT change
#                  F6 in the pattern editor, nor PE_F7 (F7 is already order-aware).
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01);
#                       IT_G.asm Error/Warning = None, IT.EXE links
#   @runtime-verified - exercised by running IT.EXE and watching playback start
#   @runtime-untested - NOT yet run; logic verified by reading only
#   @stock            - upstream Impulse Tracker behaviour, not a fork addition
#
# Source files linked back to this card (grep "features/f6-play-from-order-list-row"):
#   IT_G.ASM     - Glbl_F6: CurrentMode==11 gate -> Music_PlaySong(Order)
#   IT_PE.ASM    - Order (selected order row, line ~1828); PE_F7 (existing
#                  order-aware "from row" play, the F7 half)
#   IT_MUSIC.ASM - Music_PlaySong (9106, AX=Order); Music_PlayPartSong (9140)
#
# Commit log (the ingest trail):
#   8acb41f  F6 in the Order List plays the song from the selected order row
#
# SESSION (the vibe record): features/f6-play-from-order-list-row.session.md
#   The card is incomplete without it.
#
# RESULT (third leg of the triad):
#   Feature delivery : 8acb41f direct to esaruoho/main, no PR
#   This card authored: the card+session commit that follows 8acb41f
#   Triad: this .feature <-> .session.md <-> 8acb41f
#
# WATCH: Glbl_F6 Music_PlaySong PE_F7 PE_GetCurrentPattern Music_PlayPattern
# =============================================================================

Feature: F6 in the Order List plays the song from the selected order row
  As someone arranging a song in the F11 Order List,
  I want F6 to start playback from the order row I have selected,
  So that I can audition the song from any point in the arrangement without
  jumping back to the pattern editor or to order 0.

  @shipped @build-verified @runtime-verified
  Scenario: F6 on a selected order row starts the song from that order
    # RUNTIME-VERIFIED 2026-06-04: Esa confirmed F6 (and F7) work on a live IT.EXE.
    # cite: IT_G.ASM Glbl_F6: Cmp CurrentMode,11 / JNE stock; in the order list
    #       it reads Order (Pattern seg) and calls Music_PlaySong(AX=Order)
    # cite: IT_MUSIC.ASM Music_PlaySong (9106) AX=Order ; commit 8acb41f
    Given the user is in the Order List (F11, CurrentMode==11)
    And the cursor is on order row N
    When the user presses F6
    Then Music_PlaySong starts the song from order N
    And playback continues through the order list from there

  @shipped @build-verified
  Scenario: F6 outside the Order List keeps its stock "play current pattern"
    # cite: the gate is CurrentMode==11 only; the JNE branch is the original
    #       PE_GetCurrentPattern -> Music_PlayPattern path, unchanged
    Given the user is on any screen other than the Order List
    When the user presses F6
    Then the current pattern is played (stock behaviour), not an order

  @stock @build-verified @runtime-verified
  Scenario: F7 already plays "from row" relative to the order list
    # cite: IT_PE.ASM PE_F7 (13254): uses PlayMark (or current pattern+Row),
    #       maps it onto Order via the song's order array, plays Music_PlayPartSong
    # Note: F7 was already order-aware, so this feature only adds F6. F7 is
    # documented here for completeness, not changed.
    # RUNTIME-VERIFIED 2026-06-04: Esa confirmed F7 works alongside F6.
    Given the user is in the Order List with a playback mark or current row
    When the user presses F7
    Then playback starts from that row at the corresponding order (pre-existing)

  @shipped @build-verified
  Scenario: Song-from-order, not a single looped pattern (design choice)
    # Music_PlaySong(Order) plays the selected order's pattern AND advances
    # through the order list, matching "the selected Order List starts playing".
    # (Music_PlayPattern would loop just one pattern -- deliberately NOT used.)
    Given F6 is pressed on order row N in the Order List
    When playback starts
    Then it does not loop a single pattern; it plays the arrangement from N onward
