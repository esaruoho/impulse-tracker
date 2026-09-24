# Report Card — Getting facts back off the DOS PC

> Source: `features/debug-logging-channels.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone whose build target is a machine across the room with no debugger, I want two ready-made log channels and a written record of their gotchas, So that a question about runtime behaviour costs one round trip, not four.

**Grades:** @hw-verified × 4 · @shipped × 4 · @todo × 1

**Scenarios: 9**


---


## 1. PATLOG.TXT -- one character per event, for tracing a state machine

`@shipped @hw-verified`


- Given a state machine that reaches a wrong conclusion somewhere
- When one distinct character is emitted at each transition
- Then the sequence in PATLOG.TXT shows which transition never happened

<sub>cite: IT_MUSIC.ASM PE_LogStage (Global) -- AL = one char, appended raw · IT_MUSIC.ASM PE_LogEndLine (Global) -- writes CRLF · PE_LogOpenForAppend -- open r/w (3D02h), else create (3Ch), seek end</sub>


## 2. A worked example -- the right-shift tap

`@shipped @hw-verified`


- Given the probe wrote nothing at all
- Then the fault is not the logic being probed but the call site of the probe


## 3. CTRLOLOG.TXT -- structured named fields, for one-shot operations

`@shipped @hw-verified`


- Given an operation that runs once and either works or does not
- Then a labelled line with its inputs and its outcome beats a character trace

<sub>cite: WAV_AppendErrorLog -- DS:SI = prefix; prints prefix + RenderedFilename · WAV_LogState -- AL = label char, prints the render's whole state as · WAV_WriteHexAX / WAV_WriteStringDSSI -- the primitives to add a field</sub>


## 4. Probing the filesystem rather than the code

`@shipped @hw-verified`


- Given a report of success with nothing on disk
- Then probe for the file from inside the same cwd and log the DOS error code

<sub>cite: WAV_ProbeRenderedFile -- open + seek-end. bytes=FFFF means the file is · WAV_PreCreateRenderedFile -- does the same Int 21h AH=3Ch the driver</sub>


## 5. Gotcha 1 -- the log lands in cwd, so cwd is part of the question

`@design-note`


- Given two channels that both open by relative name
- Then a missing log file may only mean you are reading the wrong folder


## 6. Gotcha 2 -- log transitions, never polls

`@design-note`


- Given a writer that opens and closes the file per character
- Then it belongs on state changes only, and comes out again afterwards


## 7. Gotcha 3 -- main-loop context only, never the ISR

`@design-note`


- Given DOS calls are not reentrant
- Then instrumentation stays in main-loop context and the ISR only sets flags


## 8. Gotcha 4 -- a clean-looking value can still mean failure

`@design-note`


- Given a field that logs "iterations remaining"
- Then record what untouched looks like, or it will be misread as success


## 9. VRAM markers, for when there is no file to read

`@todo`


- Given a fault that takes the machine down before any file is closed
- Then the surviving evidence has to already be on screen

