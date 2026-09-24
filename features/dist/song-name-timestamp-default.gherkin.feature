# Pure Gherkin test extracted from features/song-name-timestamp-default.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/song-name-timestamp-default.feature

Feature: A blank song is born named with its creation timestamp
  As a tracker user who wants to know when a tune was started,
  I want a fresh, unnamed song's name pre-filled with the date and time,
  So that I can save the moment of creation into the song without ever
  having to read a clock or type the date myself.

  @shipped @build-verified @runtime-verified @hw-verified
  Scenario: The boot default song is named with the startup timestamp
    # cite: IT.ASM StartUp calls F_SetTimestampSongName after
    #       Music_AutoDetectSoundCard, before M_Object1List (the main loop)
    # cite: IT_F.ASM F_SetTimestampSongName reads Int 21h AH=2Ah (date) +
    #       AH=2Ch (time), writes SongData:4 ; commit 87ad1dd
    Given Impulse Tracker is started with no module on the command line
    And the default song's name field is blank
    When the user opens F12 and looks at the Song Name
    Then it reads the start time as "YYYY-MM-DD HH:MM" (e.g. "2026-06-04 15:07")

  @shipped @build-verified @runtime-verified @hw-verified
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
