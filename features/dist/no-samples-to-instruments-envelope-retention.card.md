# Report Card — F12 Samples->Instruments uses upstream clear+remap (no envelope retention)

> Source: `features/no-samples-to-instruments-envelope-retention.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone who needs a NON-CRASHING tracker above all, I want F12 "Initialise Instruments? = YES" to do exactly what upstream IT2.15 does -- clear all instruments and rebuild a clean sample-name + 120-note keymap -- with NO attempt to preserve drawn envelopes across the flip, So that nothing in the load/convert path can ever feed garbage instrument slots to the envelope renderer and hard-crash IT (EMM386 #12).

**Grades:** @build-verified × 4 · @runtime-untested × 1 · @stock × 2 · @todo × 1

**Scenarios: 5**


---


## 1. Initialise Instruments = YES does the upstream clear + remap

`@stock @build-verified @runtime-untested`


- Given the user presses F12 and answers YES to "Initialise Instruments?"
- When the conversion runs
- Then all instrument slots are cleared unconditionally
- And every slot with a matching sample gets a clean name + 120-note keymap
- And NO per-slot envelope-preserve / IMPI check runs

<sub>cite: IT_F.ASM:4831 F_SetControlInstrument; ~4852 Call Music_ClearAllInstruments · commit b5a0c66 (the behaviour this reinstates)</sub>


## 2. The envelope-retention feature and its IMPI checker are gone

`@removed @build-verified`


- Given the source tree after this commit
- When you grep for Music_InstrumentIsReal or a per-slot envelope-preserve loop
- Then the helper proc is absent (only a tombstone remains)
- And F_SetControlInstrument contains no envelope-retention branch

<sub>cite: IT_MUSIC.ASM:4025 Music_InstrumentIsReal tombstone (proc deleted) · IT_F.ASM F_SetControlInstrument no longer references IsReal/ClearInstrument</sub>


## 3. Shift-Enter bulk-load can no longer feed the crash class

`@removed @build-verified`


- Given instrument slots hold uninitialised garbage after a Shift-Enter bulk-load
- When the user runs F12 Initialise Instruments = YES
- Then those slots are cleared to a valid template by Music_ClearAllInstruments
- And no non-IMPI garbage can reach I_MapEnvelope through a preserve branch

<sub>cite: commit b5a0c66 rationale; IT_DISK.ASM LSWindow_ShiftEnter leaves the</sub>


## 4. The I_MapEnvelope MaxNode<=25 clamp stays as defensive insurance

`@stock @build-verified`


- Given any instrument reaches the envelope renderer
- When I_MapEnvelope walks its node list
- Then the node count is clamped to <= 25 so the loop cannot run wild

<sub>cite: IT_I.ASM I_MapEnvelope clamp (commit ed10913) -- KEPT on purpose,</sub>


## 5. (guardrail) Do not re-introduce envelope retention without HW verify

`@todo`


- Given a future proposal to retain envelopes across the flip
- When it is considered
- Then it stays out unless verified on real EMM386 hardware (Esa's standing rule)

