# Report Card — Sample Amplify keeps the song playing

> Source: `features/sample-amplify-keeps-playback.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As a musician tweaking a sample's level while a tune is running, I want pressing Alt-M (Amplify / normalize) and confirming it to scale the sample WITHOUT stopping playback, So that I can hear the change in context and keep my flow, instead of the whole song cutting out every time I amplify a sample.

**Grades:** @build-verified × 8 · @runtime-untested × 2 · @shipped × 5 · @stock × 3

**Scenarios: 8**


---


## 1. Amplifying a sample mid-playback does not stop the song

`@shipped @build-verified @runtime-untested`


- Given a song is playing
- And the user is on the Sample List with a sample selected
- When the user presses Alt-M and confirms the amplification dialog
- Then the sample is amplified (scaled in place, clipped)
- And the song keeps playing -- only voices using THIS sample fall silent

<sub>cite: IT_I.ASM I_AmplifySample apply path (~3997): Music_Stop replaced by · commit e5e5c38</sub>


## 2. Alt-M Maximize/Normalize during playback keeps playing through OK/Process

`@shipped @build-verified @runtime-untested`


- Given the user is playing a pattern or a song
- When they press Alt-M to Maximize/Normalize a sample
- And they set the slider amount and press OK/Process
- Then the sample is scaled by that amount
- And the playback does not stop

<sub>cite: IT_I.ASM I_AmplifySample10 runs the O1_SampleAmplificationList · commit e5e5c38</sub>


## 3. Alt-M on the Sample List is the Amplify gesture

`@stock @build-verified`


- Given the Sample List (F3) with a sample selected
- When the user presses Alt-M
- Then I_AmplifySample runs: peak-scan, then the amplification dialog

<sub>cite: IT_OBJ1.ASM:3471 sample-list keylist DW 3200h (Alt-'M', scancode</sub>


## 4. The dialog pre-fills the no-clip (normalize) amplification

`@stock @build-verified`


- Given the peak scan found the sample's max deviation from mean
- When the dialog opens
- Then it pre-fills the percentage that scales the peak to full-scale
- And that default is why users call Amplify "Normalize"

<sub>cite: IT_I.ASM I_AmplifySample10: Amplification = (8000h/MaxDev)*100,</sub>


## 5. Only the amplified sample's voices are silenced, not all channels

`@shipped @build-verified`


- Given several channels are sounding different samples
- When the user amplifies one of those samples
- Then the mixer marks only that sample's slave voices voice-off (200h)
- And channels playing other samples are unaffected

<sub>cite: IT_MUSIC.ASM Music_SilenceSampleVoices (9284): walks the slave table,</sub>


## 6. The mixer never reads the sample while it is being rewritten

`@shipped @build-verified`


- Given the amplify apply loop rewrites the sample's PCM in place
- When the mixer runs during that rewrite
- Then it skips the silenced voices and reads no partially-scaled data

<sub>cite: the silence happens BEFORE the in-place scaling loop; a voice marked</sub>


## 7. AX (the sample number) survives the silence call

`@shipped @build-verified`


- Given the apply path needs the sample number after silencing
- When Music_SilenceSampleVoices returns
- Then AX still holds the sample number for Music_GetSampleLocation

<sub>cite: Music_SilenceSampleVoices is wrapped PushA..PopA, so AX is intact for</sub>


## 8. Other Sample-List operations that still stop the song are untouched

`@stock @build-verified`


- Given a destructive op other than Amplify (e.g. cut, resize)
- When the user runs it
- Then its existing stop-the-song behaviour is unchanged by this feature

<sub>cite: IT_I.ASM has ~16 other Music_Stop call sites (cut, resize, convert,</sub>

