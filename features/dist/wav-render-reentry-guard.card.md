# Report Card — WAV render re-entry guard -- a second render gesture mid-render stops cleanly

> Source: `features/wav-render-reentry-guard.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As a musician who fired a pattern-to-WAV render and then pressed a render key AGAIN before it finished (e.g. Right then Shift-Right at the F11 order-list right edge), I want that second press to halt the in-flight render cleanly -- like Esc -- and let the file finish writing to the Quicksave folder, So that IT.EXE does not glitch/wedge with no way out, and I do not lose the recording or have to kill the tracker.

**Grades:** @build-verified × 7 · @runtime-verified × 2 · @shipped × 7

**Scenarios: 7**


---


## 1. The old behaviour -- a second gesture tore the driver down mid-playback

`@shipped @build-verified`


- Given a single-pattern WAV render is playing (WAV_RenderMode = 1)
- When the user presses a render gesture a second time
- Then (old) the leave path ran re-entrantly mid-playback
- And (old) IT.EXE glitched/wedged with no Esc out -- the reported bug

<sub>cite: before c9ff6b9, Music_ToggleWAVRender entry was "JNE WAV_LeaveMode":</sub>


## 2. Right starts the render, Shift-Right during it halts and finalizes

`@shipped @build-verified @runtime-verified`


- Given the F11 Order List is open with the cursor on the right-most order char
- And the user pressed Right, starting a render of the active pattern
- When the user presses Shift-Right while that render is still going
- Then the render is halted as if Esc were pressed (Music_Stop -> PlayMode 0)
- And IT does NOT re-enter the heavyweight driver-swap leave path
- And the diskwrite to the Quicksave folder finalizes cleanly via Music_Poll
- And IT.EXE does not wedge -- no need to kill it

<sub>cite: IT_PE.ASM PE_OrderList_RightDispatch (2323) at OrderCursor==2 -> · IT_MUSIC.ASM entry "JNE WAV_AlreadyActive" (~5604); WAV_AlreadyActive</sub>


## 3. WAV_FinalizeRequest tells the genuine finalize apart from a re-press

`@shipped @build-verified`


- Given a render is in flight (WAV_RenderMode = 1)
- When Music_ToggleWAVRender is re-entered
- Then if WAV_FinalizeRequest = 1 (Music_Poll's genuine leave) the real
- WAV_LeaveMode path runs and consumes the flag (sets it back to 0)
- And if WAV_FinalizeRequest = 0 (a user re-press) the early-stop path runs

<sub>cite: IT_MUSIC.ASM Music_Poll auto-finalize sets WAV_FinalizeRequest=1 · WAV_AlreadyActive checks the flag: NZ -> real WAV_LeaveMode; Z -></sub>


## 4. The genuine auto-finalize is unchanged -- still leaves + imports

`@shipped @build-verified`


- Given a render whose pattern playback has ended naturally (PlayMode = 0)
- When Music_Poll's finalize delay elapses
- Then it sets WAV_FinalizeRequest and calls the leave path as before
- And the rendered file is imported (or left in Quicksave per the session flag)

<sub>cite: Music_Poll: RenderMode=1 AND AutoFinalize=1 AND PlayMode=0, wait 3</sub>


## 5. Early-stop reuses the existing safe finalize, not a new teardown

`@shipped @build-verified @runtime-verified`


- Given the user re-pressed a render gesture mid-render
- When the early-stop branch runs
- Then it only stops playback and re-arms the async finalize
- And the actual driver close/diskwrite happens via the normal Music_Poll path
- And the status line shows "Render halted -- finalizing to Quicksave ..."

<sub>cite: the early-stop branch does ONLY: Music_Stop; WAV_AutoFinalize=1;</sub>


## 6. All render entry points share the one central guard

`@shipped @build-verified`


- Given any of the WAV-render gestures
- When it re-enters Music_ToggleWAVRender while a render is live
- Then the same early-stop protection applies -- not just the order-list path

<sub>cite: the guard lives in Music_ToggleWAVRender (the single chokepoint),</sub>


## 7. Multi-WAV sweep finalize and chaining are untouched

`@shipped @build-verified`


- Given a multi-channel WAV sweep is running
- When a channel finalizes and the next is kicked
- Then the re-enter is an ENTER (RenderMode=0) and bypasses the guard
- And the existing multi-WAV Esc-abort behaviour is unaffected

<sub>cite: WAV_MultiAdvance / WAV_MultiFinish re-enter Toggle only to ENTER the</sub>

