# Pure Gherkin test extracted from features/f6-play-from-order-list-row.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/f6-play-from-order-list-row.feature

Feature: F6 in the Order List plays the song from the selected order row
  As someone arranging a song in the F11 Order List,
  I want F6 to start playback from the order row I have selected,
  So that I can audition the song from any point in the arrangement without
  jumping back to the pattern editor or to order 0.

  @shipped @build-verified @runtime-untested
  Scenario: F6 on a selected order row starts the song from that order
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

  @stock @build-verified
  Scenario: F7 already plays "from row" relative to the order list
    # cite: IT_PE.ASM PE_F7 (13254): uses PlayMark (or current pattern+Row),
    #       maps it onto Order via the song's order array, plays Music_PlayPartSong
    # Note: F7 was already order-aware, so this feature only adds F6. F7 is
    # documented here for completeness, not changed.
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
