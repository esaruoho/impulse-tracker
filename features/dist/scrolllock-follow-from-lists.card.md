# Report Card — User Presses Scroll Lock while in F3 (Sample List) or F4 (Instrument List)

> Source: `features/scrolllock-follow-from-lists.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone auditioning samples/instruments against a playing song, I want Scroll Lock on the list screens to drop me into the Pattern Editor with Pattern Follow Mode already on, So that one key takes me from "browsing a slot" to "watching the cursor follow playback" without a separate F2 then Scroll Lock.

**Grades:** @build-verified × 8 · @runtime-untested × 4 · @runtime-verified × 1 · @shipped × 7 · @stock × 1 · @todo × 1

**Scenarios: 9**


---


## 1. Scroll Lock inside the Pattern Editor still just toggles Follow Mode

`@stock @build-verified`


- Given the user is already in the Pattern Editor
- When the user presses Scroll Lock
- Then Playback Tracing toggles (on->off or off->on) and the screen does not change

<sub>cite: IT_PE.ASM:722 pattern-editor keylist DB 0 / DW 146h -> PEFunction_ToggleTrace · IT_PE.ASM:13298 PEFunction_ToggleTrace XORs TracePlayback, sets LED + info line</sub>


## 2. Scroll Lock in the Sample List opens the Pattern Editor with Follow Mode on

`@shipped @build-verified @runtime-untested`


- Given the user is on the Sample List (CurrentMode 3)
- When the user presses Scroll Lock
- Then Pattern Follow Mode (TracePlayback) is forced ON (not toggled)
- And the Scroll Lock LED is lit
- And the Pattern Editor opens, identical to pressing F2

<sub>cite: IT_OBJ1.ASM:3536 SampleGlobalKeyList DB 0 / DW 146h -> PE_ScrollLockFollow · IT_PE.ASM:13339 PE_ScrollLockFollow: Mov TracePlayback,1; SetInfoLine; · IT_G.ASM:224 Glbl_F2 normal path sets CurrentMode=2, returns</sub>


## 3. Scroll Lock in the Instrument List does the same

`@shipped @build-verified @runtime-untested`


- Given the user is on the Instrument List (CurrentMode 4)
- When the user presses Scroll Lock
- Then Pattern Follow Mode is forced ON, the LED lights, and the Pattern Editor opens

<sub>cite: IT_OBJ1.ASM:6666 InstrumentGlobalKeyList DB 0 / DW 146h -> PE_ScrollLockFollow</sub>


## 4. Ctrl-F in the Sample List (F3) or Instrument List (F4)

`@shipped @build-verified @runtime-verified`


- Given the user is on the Sample List (F3) or Instrument List (F4)
- When the user presses Ctrl-F
- Then Pattern Follow Mode is forced ON, the LED lights, and the Pattern Editor opens


## 5. Ctrl-F INSIDE the Pattern Editor (F2) toggles Follow Mode, not the config dialog

`@bug @shipped @build-verified @runtime-untested`


- Given the user is in the Pattern Editor (CurrentMode==2) with Follow Mode ON
- When the user presses Ctrl-F
- Then Follow Mode is toggled OFF (LED + info line update)
- And the F2 Pattern Edit Config dialog does NOT open

<sub>cite: IT_PE.ASM PE_ScrollLockFollow -> PE_SLF_Toggle branch ; commit e04be2c</sub>


## 6. Ctrl-F on the Order List (F11) or Song Variables (F12) enters the editor

`@shipped @build-verified @runtime-untested`


- Given the user is on the Order List (F11) or Song Variables (F12)
- When the user presses Ctrl-F
- Then Pattern Follow Mode is forced ON, the LED lights, and the Pattern Editor opens


## 7. Follow Mode is forced ON, never toggled off, from the lists

`@shipped @build-verified`


- Given Pattern Follow Mode is already ON
- When the user presses Scroll Lock on the Sample or Instrument List
- Then Follow Mode stays ON (idempotent) and the Pattern Editor opens

<sub>cite: IT_PE.ASM:13339 uses "Mov TracePlayback, 1" (set), NOT "Xor ...,1" (toggle)</sub>


## 8. The handler hands Glbl_F2 the dispatcher's own DS (no segment damage)

`@shipped @build-verified`


- Given Scroll Lock is pressed on a list screen
- When PE_ScrollLockFollow runs
- Then DS is the Pattern segment only across SetInfoLine, then restored for Glbl_F2

<sub>cite: IT_PE.ASM:13339 Push DS (dispatcher) / Push CS Pop DS (Pattern seg for</sub>


## 9. (not built) Scroll Lock / Ctrl-F from other screens (Order list F11, Song vars F12)

`@todo`


- Given the user is on the Order List (F11) or Song Variables (F12) screen
- When the user presses Scroll Lock or Ctrl-F
- Then nothing happens (no binding) — intentional; F11 is the pending follow-up

