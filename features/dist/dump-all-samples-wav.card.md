# Report Card — Dumping every sample in the song to WAV in one keystroke

> Source: `features/dump-all-samples-wav.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone moving a module's sounds to another machine, I want one key to write every loaded sample out as its own WAV, So that the whole sample set lands in the Quicksave folder the Mac reads, without saving them one at a time.

**Grades:** @build-verified × 6 · @hw-verified × 1 · @runtime-untested × 1 · @shipped × 6 · @todo × 1

**Scenarios: 10**


---


## 1. Ctrl-Shift-Right, or D, writes every loaded sample

`@shipped @build-verified @hw-untested`


- Given a song with samples loaded
- When the user presses Ctrl-Shift-Right on the F5 Info Page
- Then each non-empty sample is written as SMPnn.WAV in the Quicksave folder
- And the info line reports how many were written

<sub>cite: IT_DISK.ASM D_DumpAllSamplesWAV -- slots 1..99, Test [SI+12h],1 to skip · IT_DISPL.ASM Display_RenderQuicksave -- K_IsKeyDown(01Dh) picks the dump</sub>


## 2. Ctrl-Shift-Right from Sample List or Order List uses the shared exporter

`@shipped @build-verified @runtime-untested`


- Given the Sample List or Order List is open
- When I press Ctrl-Shift-Right
- Then every non-empty sample is written as SMPnn.WAV in the Quicksave folder
- And the info line reports how many were written

<sub>cite: IT_I.ASM I_SaveSelectedSampleWAV and IT_PE.ASM</sub>


## 3. 8-bit samples are converted, not dumped raw

`@shipped @build-verified @hw-untested`


- Given a song containing 8-bit samples
- When they are dumped
- Then their data is converted to unsigned, so they do not play back inverted


## 4. The song's own sample filenames are left alone

`@shipped @build-verified @hw-untested`


- Given a sample whose stored filename is something else
- When the dump runs
- Then the file on disk is SMPnn.WAV and the song's own filename field is unchanged

<sub>cite: D_SaveRawSampleInternal takes the filename from [SI+4] of the header it</sub>


## 5. A bad Quicksave path aborts before writing anything

`@shipped @build-verified @hw-untested`


- Given the Quicksave folder in F12 points somewhere that does not exist
- When the user presses Ctrl-Shift-Right
- Then nothing is written and the info line says the folder is invalid

<sub>cite: D_GotoRenderDirectory returns CF=1 on a configured-but-invalid path</sub>


## 6. Dumping while the song plays keeps playing, and the files are correct

`@shipped @build-verified @hw-verified`


- Given the song is playing
- When the user dumps the samples
- Then playback continues, unbroken and quiet
- And every file is correct

<sub>cite: IT_DISK.ASM D_SaveBlockEMSSafe -- per 512-byte chunk: Cli, · both writers route through it while DumpSafeCopy is set --</sub>


## 7. Dumping during playback made the mixer scream

`@corrected`


- Given two readers share one EMS page frame with no interlock
- Then the bulk reader has to interlock with the realtime one


## 8. The 8-bit writer was mutating the song's own sample memory

`@corrected`


- Given a converter that edits the data in place to save it
- Then anything else reading that data at the time hears the conversion


## 9. Ctrl-Shift-Right cannot be a keymap row -- it is a live modifier test

`@corrected`


- Given Ctrl-Left and Ctrl-Right move between patterns
- Then Ctrl+Shift is discriminated inside the handler, not by a keymap row


## 10. Names carry the sample name, not just the slot

`@todo`


- Given DOS 8.3 filenames
- Then the slot number is what identifies the file, for now

