# =============================================================================
# WIKI PAGE / REPORT CARD: Blank song name defaults to a creation timestamp
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# When Impulse Tracker boots to its empty default song (no module loaded), the
# Song Name field is auto-filled with the wall-clock moment the song came into
# existence, formatted "YYYY-MM-DD HH:MM" (e.g. "2026-06-04 15:07"). Same when
# the user makes a fresh song via the New Song dialog and blanks the name. The
# point: the user never has to look up the date/time to stamp it into the song
# they save -- it's already there, ready to keep or overwrite.
#
# WHAT THIS CARD SPAWNS (generative SEED, not a description):
#   - CODESPACE  : this .feature + .session.md, PLUS the innards -- the
#                  F_SetTimestampSongName proc in IT_F.ASM and its two call
#                  sites (IT.ASM startup; F_NewSong after the name-clear).
#   - THINKSPACE : the .session.md -- WHY the proc self-guards on a blank first
#                  byte (forward-compat against a future command-line load),
#                  WHY "YYYY-MM-DD HH:MM" (16 of 26 bytes, sortable, no seconds),
#                  and the DOS Int 21h AH=2Ah/2Ch register dance.
#   - AREASPACE  : owns the DEFAULT (blank) song-name value at song-birth. Must
#                  NOT touch a name that already has content, the F12 name editor
#                  itself, or module load/save of the name field.
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01);
#                       IT.asm + IT_F.asm Error/Warning = None, IT.EXE links
#   @hw-untested      - NOT run on real DOS hardware (DOSBox-X is emulation)
#   @runtime-verified - exercised by running IT.EXE and watching the F12 name
#   @runtime-untested - NOT yet run; logic verified by reading + clean build only
#   @stock            - upstream Impulse Tracker behaviour, not a fork addition
#
# Source files linked back to this card (grep "features/song-name-timestamp-default"):
#   IT_F.ASM - F_SetTimestampSongName: reads DOS date/time, writes the 16-char
#              timestamp into SongData:4; Global export; guards on blank name
#   IT_F.ASM - F_NewSong: calls it right after the song-name StosW clear loop
#   IT.ASM   - StartUp: Extrn + call after Music_AutoDetectSoundCard, before the
#              main message loop (the blank boot song)
#
# Commit log (the ingest trail):
#   87ad1dd  default blank song name to creation timestamp (YYYY-MM-DD HH:MM)
#
# SESSION (the vibe record): features/song-name-timestamp-default.session.md
#   The card is incomplete without it.
#
# RESULT (third leg of the triad):
#   Feature delivery : 87ad1dd direct to esaruoho/main, no PR
#   This card authored: the card+session commit that follows 87ad1dd
#   Triad: this .feature <-> .session.md <-> 87ad1dd
#
# WATCH: F_SetTimestampSongName F_NewSong
#
# Sibling: features/f12-song-variables.feature (the F12 screen that shows/edits
#          the Song Name this feature pre-fills).
# =============================================================================

Feature: A blank song is born named with its creation timestamp
  As a tracker user who wants to know when a tune was started,
  I want a fresh, unnamed song's name pre-filled with the date and time,
  So that I can save the moment of creation into the song without ever
  having to read a clock or type the date myself.

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The boot default song is named with the startup timestamp
    # cite: IT.ASM StartUp calls F_SetTimestampSongName after
    #       Music_AutoDetectSoundCard, before M_Object1List (the main loop)
    # cite: IT_F.ASM F_SetTimestampSongName reads Int 21h AH=2Ah (date) +
    #       AH=2Ch (time), writes SongData:4 ; commit 87ad1dd
    Given Impulse Tracker is started with no module on the command line
    And the default song's name field is blank
    When the user opens F12 and looks at the Song Name
    Then it reads the start time as "YYYY-MM-DD HH:MM" (e.g. "2026-06-04 15:07")

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The format is fixed-width 16 chars, zero-padded, no seconds
    # cite: F_SetTimestampSongName emits 4-digit year, "-", 2-digit month, "-",
    #       2-digit day, " ", 2-digit hour, ":", 2-digit minute = 16 bytes
    Given the system clock reads 2026-06-04, 03:07 (3:07 AM)
    When the timestamp name is written
    Then it reads "2026-06-04 03:07" (hours and minutes zero-padded to two digits)
    And it occupies 16 of the song name's 26 bytes, leaving room to append

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Making a fresh song re-stamps the name with the new time
    # cite: IT_F.ASM F_NewSong calls F_SetTimestampSongName immediately after the
    #       "Clear song name" StosW loop (only on the name-reset branch)
    Given a song has been open for a while
    When the user runs New Song and the song-data reset clears the name
    Then the name is re-filled with the current "YYYY-MM-DD HH:MM", not left blank

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: A name that already has content is never clobbered
    # cite: F_SetTimestampSongName does Cmp Byte Ptr [ES:4],0 / JNE done before
    #       writing -- it only stamps a name whose first byte is 0 (blank)
    Given the current song already has a non-empty Song Name
    When F_SetTimestampSongName runs (e.g. a future code path calls it)
    Then the existing name is left exactly as it was

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The stamped name is an ordinary editable name, not a locked field
    # cite: the proc only writes the SongData:4 bytes; the F12 SongNameInput
    #       object (IT_OBJ1.ASM, 26-byte text input) is untouched
    Given the song name shows the creation timestamp
    When the user types over it in the F12 Song Name field
    Then their text replaces the timestamp normally and saves with the module
