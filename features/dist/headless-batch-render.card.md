# Report Card — Rendering a module without touching the interface

> Source: `features/headless-batch-render.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone who wants a module's patterns as WAVs without driving the UI, I want IT to load a module, write the files and quit, So that a whole module can be bounced from one command line.

**Grades:** @build-verified × 4 · @shipped × 4 · @todo × 1

**Scenarios: 10**


---


## 1. Every pattern that has data becomes its own WAV

`@shipped @build-verified @dosbox-verified @hw-untested`


- Given a module named on the command line after /O
- When IT is started
- Then each pattern holding data is written to the Quicksave folder as a WAV
- And empty patterns are skipped, so 200 files are never produced
- And IT quits by itself when the last one is done

<sub>cite: IT_MUSIC.ASM Music_BatchRenderPatterns -- AX=0FFFFh walks 0..199</sub>


## 2. One pattern only

`@shipped @build-verified @dosbox-verified @hw-untested`


- Given /N005 is also on the command line
- When IT is started with /O
- Then only pattern 5 is rendered

<sub>cite: IT.ASM BatchPattern1 -- GetDecimalNumber, rejected unless < 200</sub>


## 3. Every sample becomes its own WAV

`@shipped @build-verified @dosbox-verified @hw-untested`


- Given a module named on the command line after /U
- When IT is started
- Then every loaded sample is written as SMPnn.WAV and IT quits

<sub>cite: IT_DISK.ASM D_DumpAllSamplesWAV, reused with no changes</sub>


## 4. No sound card is needed

`@shipped @build-verified @dosbox-verified`


- Given /S0 selects no sound card
- When a batch render runs
- Then the WAVs are still written


## 5. Why the work runs on the idle path and not at startup

`@design-note`


- Given the batch needs a loaded module and an initialised driver
- Then it runs on the first pass where the dispatcher has nothing else to do

<sub>cite: IT_M.ASM M_KeyBoardInput1 -- the flags are checked where the dispatcher</sub>


## 6. Why the filename hangs directly off the switch letter

`@design-note`


- Given every letter on IT's command line is a switch
- Then the module name must be consumed by the switch that takes it


## 7. How a module gets loaded with no interface

`@design-note`


- Given the only way in is the startup keystroke script
- Then batch reuses it and swaps only its tail
- And nothing about /W's behaviour changes


## 8. Batch naming must not be the timestamp

`@design-note`


- Given a timestamp only resolves to one second
- Then a loop that can finish twice in a second cannot be named by it

<sub>cite: IT_MUSIC.ASM -- WAV_BatchNaming forces the <PFX><NNNN> counter path</sub>


## 9. Two assembly traps, both found with breadcrumbs rather than argument

`@corrected`


- Given assembly faults that present as an unexplained wedge
- Then one character per step narrows it to instructions, and guessing does not


## 10. Rendering the whole song rather than per-pattern

`@todo`


- Given the whole-song render is asynchronous
- Then batch does not drive it yet

