# =============================================================================
# WIKI PAGE / REPORT CARD: Ctrl-F9 inverts every channel mute
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# Ported from schismtracker (Ctrl-Shift-F9, 2026-08-07).
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE  : Music_InvertChannelMutes (IT_MUSIC.ASM) + the GlobalKeyList row.
#   - THINKSPACE : why it loops Music_ToggleChannel instead of writing
#                  MuteChannelTable directly.
#   - AREASPACE  : owns bulk mute inversion. Must NOT change Music_ToggleChannel
#                  or Music_MuteChannel/UnmuteChannel semantics.
#
# Source files linked back to this card:
#   IT_MUSIC.ASM - Music_InvertChannelMutes
#   IT_OBJ1.ASM  - GlobalKeyList: DB 3 / DW 143h -> Music_InvertChannelMutes
#
# WATCH: Music_InvertChannelMutes Music_ToggleChannel MuteChannelTable GlobalKeyList
# =============================================================================

Feature: Flipping every channel mute at once
  As someone auditioning the complement of a mix,
  I want one key to invert all the mutes,
  So that I can flip between two halves of an arrangement without clicking
  through channels.

  @shipped @build-verified @hw-untested
  Scenario: Ctrl-F9 inverts all 64 channels
    # cite: IT_MUSIC.ASM Music_InvertChannelMutes -- loops channels 0..63
    # cite: IT_OBJ1.ASM GlobalKeyList -- DB 3 / DW 143h, so it works on any screen
    Given some channels are muted and others are not
    When the user presses Ctrl-F9
    Then every channel's mute state is inverted

  @shipped @build-verified @hw-untested
  Scenario: Pressing it twice returns exactly to the start
    Given any arrangement of mutes
    When the user presses Ctrl-F9 twice
    Then the mute state is exactly what it was

  @design-note
  Scenario: Why it loops Music_ToggleChannel instead of writing the table
    # A channel's mute lives in TWO places: CS:MuteChannelTable[ch] and bit 7 of
    # SongData[ch+40h], and muting/unmuting also has to reach the mixer via
    # Music_MuteChannel / Music_UnmuteChannel. Music_ToggleChannel already does all
    # of that correctly for one channel, so inverting is 64 calls to proven code
    # rather than a hand-rolled loop that could keep the two records disagreeing.
    Given the mute state is recorded in more than one place
    Then the existing per-channel toggle is reused rather than reimplemented

  @todo
  Scenario: A key that does not need the fn row on a laptop
    # Ctrl-F9 sits next to Alt-F9 (toggle one channel) and Alt-F10 (solo), which is
    # why it was chosen. On a laptop keyboard the function row may need fn.
    Given a keyboard without a dedicated function row
    Then a letter-based chord might be preferable
