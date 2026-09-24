# Report Card — Feature parity between Impulse Tracker and Schism Tracker

> Source: `features/schismtracker-port-backlog.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As the person maintaining both forks, I want one ledger of what crossed over, what was already here, what cannot be, and what only exists here, So that nothing is ported twice, nothing impossible is attempted again, and the answer to "are they at parity yet" is a count rather than an impression.

**Grades:** @hw-verified × 4 · @todo × 7

**Scenarios: 22**


---


## 1. Right shift tapped on its own drops you into the playing pattern

`@done @hw-verified`


- Given the user is anywhere with a song playing
- When they tap and release right shift without pressing anything else
- Then the pattern editor opens on the playing pattern with follow mode on
- And tapping again inside the editor switches follow mode off


## 2. Shift-Right on the F5 Info Page renders the playing pattern

`@done @hw-verified`


- Given the user is on the Info Page with the song playing
- When they press Shift-Right
- Then the pattern being heard is rendered to the Quicksave folder


## 3. Enter on the Info Page opens the playing pattern at the playing row

`@done @hw-verified`


- Given the user is on the Info Page with a channel selected
- When they press Enter
- Then the pattern editor opens on that pattern, channel and row


## 4. Every sample in the song dumped as its own WAV

`@done @hw-verified`


- Given a song with samples loaded
- When the user presses Ctrl-Shift-Right (or D on the Info Page)
- Then every non-empty sample is written to the Quicksave folder as a WAV


## 5. Rendering from the command line, without the interactive screens

`@done @dosbox-verified @hw-untested`


- Given a module and optionally a pattern number on the command line
- When IT is started with the render switch
- Then the patterns are rendered to WAVs and IT quits on its own

<sub>cite: features/wav-render-quicksave.feature, the @corrected scenario</sub>


## 6. A shortcut inverts every channel mute at once

`@done`


- Given some channels are muted and others are not
- When the user presses the mute-flip key
- Then every channel's mute state is inverted, and pressing it again restores it


## 7. Alt-D clones verbatim and Shift-Alt-D clones wiping muted channels

`@done`


- Given the user is on the F11 order list
- When they press Alt-D, then Shift-Alt-D
- Then the first clone is verbatim and the second has muted channels wiped


## 8. Tiling a pattern clears the pattern breaks it carries into repeats

`@done`


- Given a pattern whose last row carries a C00
- When it is extended or tiled to a greater length
- Then the carried breaks are cleared except the one on the new final row


## 9. The order list follows the playing pattern for the render gestures

`@done`


- Given a song is playing and the user is on the order list
- When they press Shift-Right
- Then the pattern being heard is the one rendered


## 10. Things schism gained in August that IT already had

`@already`


- Given the schismtracker August work is compared against this tree
- Then pattern tiling on a length increase is already here    # f2-resize-tiles-pattern
- And Alt-D clone into the first free slot, with M             # f11-order-list
- And Alt-E doubling a pattern, repeating its content          # f11-order-list
- And render gestures on the order-list cursor keys            # f11-order-list
- And Ctrl-O render to Quicksave, with no import               # wav-render-quicksave
- And per-channel and whole-song WAV export                    # multi-wav
- And the note-cut toggle clearing an existing cut             # note-cut-toggle
- And a blank song named with its creation timestamp           # song-name-timestamp-default
- And F3/F4 carrying the cursor between the lists              # f4-f3-cursor-translate
- And MIDI clock sync, its toggle, and transport               # midi-realtime-sync
- And multitimbral MIDI in, Shift-F4 and the drumkit           # midi-in-multitimbral, shift-f4-drumkit
- And replicating the rows above the cursor                    # alt-r-replicate
- And Shift-Enter bulk-loading a module's samples              # shift-enter-bulk-load-from-module
- And the remembered default pattern length                    # f2-pattern-editor


## 11. One schism commit has no counterpart here at all

`@already`


- Given a platform-specific fix
- Then it is out of scope for this fork


## 12. 512-row patterns cannot be done in this fork

`@impossible`


- Given a 512-row pattern would need 163840 bytes in the editor buffer
- Then it does not fit a real-mode segment and the port is refused

<sub>cite: features/pattern-length-beyond-200.feature · IT_PE.ASM:14687 -- PatternData segment is exactly 64000 bytes, · IT_PE.ASM:8457 -- row offsets are 16-bit (Mul DX, high word dropped), · NetworkPatternBlock passes Row/Height as BYTES</sub>


## 13. Shift-Enter loads a whole folder, or the module you are already inside

`@todo`


- Given the user is inside a module in the sample browser
- When they press Shift-Enter
- Then every sample in that module is loaded, without backing out first


## 14. Remembering MIDI ports and MIDI flags across restarts

`@todo`


- Given MIDI sync was enabled and a port was open
- When IT is restarted
- Then the same flags and the same port are restored


## 15. Ctrl-O works from any screen, not only F2, F11 and F5

`@todo`


- Given the user is on the sample list or the instrument list
- When they press Ctrl-O
- Then the current pattern is rendered, as it would be from F2


## 16. Reopening the module that was loaded last

`@todo`


- Given a module was loaded and IT was restarted
- When IT starts with no module named on the command line
- Then the module that was open last is loaded again


## 17. The quicksave gestures work in the sample loader too

`@todo`


- Given the user is inside a module in the sample loader
- When they press Shift-Right
- Then the pattern is rendered, as it would be from F5


## 18. Enter in the pattern editor lifts the nearest instrument number

`@todo`


- Given the cursor is on an empty row below a note
- When the user presses Enter
- Then the instrument number from the nearest note above is picked up


## 19. Alt-Up/Alt-Down page, Shift-Alt-Up/Down are home and end

`@todo`


- Given the user is in the pattern editor
- When they press Alt-Down
- Then the cursor pages down as Page Down would


## 20. Schism's Shift-F5 Preferences page has nothing worth porting

`@impossible`


- Given schism's Preferences page is compared against IT's driver screen
- Then the differences are host plumbing or per-driver DSP, and none are ported


## 21. Things this fork has that schism does not

`@it-only`


- Given the two forks are compared the other way round
- Then Alt-W quicksave and Shift-Alt-W memorise-folder are IT-only
- And the Shift-F1 MIDI Monitor with its RT byte counters is IT-only
- And IT.CFG's fork extension block is IT-only by construction
- And the driver-level F8-FF passthrough fix across 16 sound drivers has no
- schism counterpart, because schism has no DOS sound drivers
- And the render's synchronous faster-than-realtime pump is IT-only, because
- schism renders through its own disko subsystem


## 22. Why the counts will never reach a literal 1:1

`@design-note`


- Given two forks of different programs
- Then parity means nothing unaccounted for, not an identical feature count

