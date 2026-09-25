# Report Card — Shift-Enter Load from Sample List (bulk-load a module's samples)

> Source: `features/shift-enter-bulk-load-from-module.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone who wants a module's instruments fast, I want Shift-Enter on a module file in the Load Sample browser to load every sample in that module into consecutive slots, one per row, keeping each sample's original name and loop mode, So that I can lift a whole module's sample set in a single keystroke.

**Grades:** @build-verified × 3 · @runtime-untested × 3 · @shipped × 3

**Scenarios: 5**


---


## 1. Shift-Enter on a module bulk-loads into empty slots from the cursor

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the user is in the Sample List and has opened the Load Sample browser
- And the cursor is on a module file row (type byte [cache+88] >= 20h)
- When they press Shift-Enter on it
- Then each sample is loaded into an empty slot at or after the current slot
- And every previously occupied sample and instrument remains unchanged
- And each occupies its own row in the sample list

<sub>cite: IT_DISK.ASM:988 LSWindowKeys cond 4 (Shift) / key 11Ch -> LSWindow_ShiftEnter · IT_DISK.ASM:7830 calls the per-format LoadSamplesInModuleTable loader · IT_DISK.ASM:7894 LSWS_Loop iterates cache entries 1..NumSamples-1, · IT_G.ASM:303 lands on the F3 Sample List afterwards (Jmp Glbl_F3)</sub>


## 2. Caps Lock on a module row performs the Shift-Enter bulk load

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the Sample Load browser is showing a module row
- When I press Caps Lock on that row
- Then the module's samples are loaded into empty slots from the current slot
- And occupied samples and instruments remain unchanged

<sub>cite: IT_DISK.ASM LSWindowKeys maps scan word 13Ah to</sub>


## 3. Loaded samples keep their original module names and loop modes

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a module whose samples have names and loop points
- When they are bulk-loaded via Shift-Enter
- Then each loaded sample shows its original name
- And its loop mode (forward / ping-pong / none) is preserved

<sub>cite: IT_D_RIS.INC:136 MOD loader copies the 22-char sample name into the · IT_DISK.ASM:7420 LoadSample copies the 48h-byte sample header (name,</sub>


## 4. REGRESSION (reported 2026-06-03) - Shift-Enter on a .MOD hard-hangs IT

`@bug @fixed-pending-verify`


- Given the user is on a .MOD file row in the Load Sample browser
- When they press Shift-Enter
- Then IT must NOT hang
- And it loads the module's samples (or shows "Module contains no samples.")
- And it returns to a consistent screen state

<sub>cite: IT_DISK.ASM:7839 FORK FIX block (Xor DI,DI / Rep MovsB ExitLibraryDirectory</sub>


## 5. REGRESSION (reported 2026-06-04) - after bulk-load the loader is parked

`@bug @fixed-pending-verify`


- inside the module instead of its directory
- Given the user has just bulk-loaded a module's samples with Shift-Enter
- And IT has returned to the F3 Sample List
- When they move the cursor to a different sample slot and press Enter
- Then the Load Sample browser shows the directory the module was picked from
- And NOT the module's internal sample list

<sub>cite: IT_DISK.ASM LSWS_LoopEnd exit-to-directory block (after the bulk loop); · IT_DISK.ASM:5062 D_InitLoadSamples SamplesInModule gate (the symptom site)</sub>

