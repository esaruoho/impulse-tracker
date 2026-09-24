# Report Card — Reading the screen from the build machine

> Source: `features/headless-screenshot.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone changing a layout on a tracker that runs on a DOS box across the room, I want the screen written out as text I can read where I build, So that "is this cut off?" is a thing I can see rather than a thing I ask about.

**Grades:** @build-verified × 3 · @hw-verified × 2 · @shipped × 3 · @todo × 1

**Scenarios: 9**


---


## 1. Shift-Alt-Y writes the current screen from any page

`@shipped @build-verified @hw-verified`


- Given the user is on any screen
- When they press Shift-Alt-Y
- Then the 80x50 text screen is written out, characters only
- And the info line confirms it, or says the grab failed

<sub>cite: IT_OBJ1.ASM GlobalKeyList - DB 1 / DW 1515h -> M_ScreenGrabKey · IT_K.ASM - condition 11 on Y's scancode gives Shift-Alt-Y the word 1515h</sub>


## 2. The file lands in the Quicksave folder, under a rotating name

`@shipped @build-verified @hw-verified`


- Given the Quicksave folder is configured in F12
- When a grab happens
- Then it is written there as SCR-nn.TXT, whatever directory IT was browsing

<sub>cite: IT_M.ASM M_ScreenGrab - D_SaveCwd / D_GotoRenderDirectory / D_RestoreCwd</sub>


## 3. /G captures without anyone pressing anything

`@shipped @build-verified @dosbox-verified`


- Given IT is started with the /G switch
- When it reaches its first idle pass
- Then the screen is written out and IT quits on its own

<sub>cite: IT.ASM ScreenGrab1 - /G, plus up to four optional 4-hex-digit key words · IT_M.ASM M_KeyBoardInput1 - sends them one per idle pass, waits for the</sub>


## 4. The layout bug it found in one press, after three blind attempts

`@corrected`


- Given a layout fault reported as "the text is outside the button"
- Then look at the screen before believing the description of it


## 5. Two self-inflicted bugs, both found by using the tool on itself

`@corrected`


- Given a tool whose whole purpose is to show what is really there
- Then the first thing to point it at is itself


## 6. Why it reads B800:0000 and drops the attributes

`@design-note`


- Given the goal is to read a layout
- Then characters are enough, and one line per row keeps it greppable

<sub>cite: IT_M.ASM M_ScreenGrab</sub>


## 7. Why the key binding matters more than the switch

`@design-note`


- Given not every page can be reached by injecting a key word
- Then the operator's own keypress is the more reliable trigger


## 8. Shift-Alt-Y is 1515h, and the pattern editor keeps its own Shift-Alt-Y

`@design-note`


- Given a global key must not steal a screen's own binding
- Then pick a key word that was unbound everywhere, and let local lists win


## 9. Capturing colours

`@todo`


- Given attributes are available in the same VRAM read
- Then a colour-aware variant is possible if a palette question ever comes up

