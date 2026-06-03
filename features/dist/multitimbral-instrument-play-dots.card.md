# Report Card — F4 instrument-list play dots in multitimbral Sample mode

> Source: `features/multitimbral-instrument-play-dots.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone playing a multitimbral MIDI rig into IT with the song in Sample mode, I want the F4 Instrument List to show live play dots while notes sound, just like the F3 Sample List already does, So that I can see which routed instruments are active without switching to the sample screen.

**Grades:** @build-verified × 5 · @runtime-untested × 2 · @shipped × 4 · @stock × 1

**Scenarios: 5**


---


## 1. Stock IT hid the F4 dots whenever instrument mode was off

`@shipped @build-verified @runtime-untested`


- Given the song is in Sample mode (instrument mode off)
- And the multitimbral MIDI-in router is enabled and sounding voices
- When the user views the F4 Instrument List
- Then (old) no play dots appeared, even though the F3 Sample List showed them

<sub>cite: IT_I.ASM I_ShowInstrumentPlay opened with Music_GetInstrumentMode / · I_ShowSamplePlay (8488) has NO such gate -> F3 kept showing dots</sub>


## 2. With the router on, F4 shows play dots even in Sample mode

`@shipped @build-verified @runtime-untested`


- Given the song is in Sample mode
- And Music_GetMIDIMultiEnable is set (multitimbral routing on)
- When voices are sounding and the user views F4
- Then the instrument-list play dots are drawn (the gate no longer bails)
- And they track the matched instrument via the slave field [SI+33h]

<sub>cite: IT_I.ASM I_ShowInstrumentPlay (478b638): if Music_GetInstrumentMode</sub>


## 3. Normal Sample mode (router off) is unchanged

`@shipped @build-verified`


- Given the song is in Sample mode and the multitimbral router is OFF
- When the user views F4
- Then no instrument play dots are drawn (stock behaviour preserved)

<sub>cite: the new branch only proceeds when Music_GetMIDIMultiEnable is set;</sub>


## 4. Instrument mode still shows dots exactly as before

`@stock @build-verified`


- Given the song is in Instrument mode
- When the user views F4 during playback
- Then the dots draw as they always did, router on or off

<sub>cite: Music_GetInstrumentMode non-zero takes the proceed branch directly,</sub>


## 5. The dot row is the routed instrument, not a sentinel

`@shipped @build-verified`


- Given a routed note for instrument N is sounding
- When the F4 dot scan runs
- Then InstrumentPlayTable[N] is lit, so the dot appears on instrument N's row

<sub>cite: MIDIMulti_Route -> Music_PlayNote with MMR_Inst (1..99); the slave · I_ShowInstrumentPlay scan reads [SI+33h], skips >=100, lights row BX</sub>

