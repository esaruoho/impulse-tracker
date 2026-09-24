# Report Card — A blank song is born named with its creation timestamp

> Source: `features/song-name-timestamp-default.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As a tracker user who wants to know when a tune was started, I want a fresh, unnamed song's name pre-filled with the date and time, So that I can save the moment of creation into the song without ever having to read a clock or type the date myself.

**Grades:** @build-verified × 5 · @hw-verified × 2 · @runtime-untested × 3 · @runtime-verified × 2 · @shipped × 5

**Scenarios: 5**


---


## 1. The boot default song is named with the startup timestamp

`@shipped @build-verified @runtime-verified @hw-verified`


- Given Impulse Tracker is started with no module on the command line
- And the default song's name field is blank
- When the user opens F12 and looks at the Song Name
- Then it reads the start time as "YYYY-MM-DD HH:MM" (e.g. "2026-06-04 15:07")

<sub>cite: IT.ASM StartUp calls F_SetTimestampSongName after · IT_F.ASM F_SetTimestampSongName reads Int 21h AH=2Ah (date) +</sub>


## 2. The format is fixed-width 16 chars, zero-padded, no seconds

`@shipped @build-verified @runtime-verified @hw-verified`


- Given the system clock reads 2026-06-04, 03:07 (3:07 AM)
- When the timestamp name is written
- Then it reads "2026-06-04 03:07" (hours and minutes zero-padded to two digits)
- And it occupies 16 of the song name's 26 bytes, leaving room to append

<sub>cite: F_SetTimestampSongName emits 4-digit year, "-", 2-digit month, "-",</sub>


## 3. Making a fresh song re-stamps the name with the new time

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a song has been open for a while
- When the user runs New Song and the song-data reset clears the name
- Then the name is re-filled with the current "YYYY-MM-DD HH:MM", not left blank

<sub>cite: IT_F.ASM F_NewSong calls F_SetTimestampSongName immediately after the</sub>


## 4. A name that already has content is never clobbered

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the current song already has a non-empty Song Name
- When F_SetTimestampSongName runs (e.g. a future code path calls it)
- Then the existing name is left exactly as it was

<sub>cite: F_SetTimestampSongName does Cmp Byte Ptr [ES:4],0 / JNE done before</sub>


## 5. The stamped name is an ordinary editable name, not a locked field

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the song name shows the creation timestamp
- When the user types over it in the F12 Song Name field
- Then their text replaces the timestamp normally and saves with the module

<sub>cite: the proc only writes the SongData:4 bytes; the F12 SongNameInput</sub>

