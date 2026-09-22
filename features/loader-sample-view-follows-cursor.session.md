# Session — loader-sample-view-follows-cursor

Faithful, not flattering. Vibe-diff for `loader-sample-view-follows-cursor.feature`.

## How to get back
- Repo: /Users/esaruoho/work/impulse-tracker · Date: 2026-09-22
- Resume: `claude --resume <id>`

## The request
Esa (on real hardware, in the sample loader): "in load sample mode, the sample
view works. it would be even better though if it showed it the minute you change
from sample to sample. r u able to do that, verify it and push it."

## What was found
- The Load-Sample-from-library window (D_PostLoadSampleWindow) draws a waveform via
  `D_DrawWaveForm`, which reads sample slot **100** (`Music_GetSampleLocation` AX=100).
- The preview slot is populated by `LoadSample` (AX=99). Inside LoadSample, after a
  successful preview load, it draws the waveform ONLY when
  `CurrentSample != SampleInMemory` (IT_DISK.ASM ~7698-7704).
- That preview-load was fired ONLY from the keyjazz branch of D_PostLoadSampleWindow
  (pressing a note key). So the waveform updated on play, not on cursor movement.
- The six cursor moves (LSWindow_Up/Down/PgUp/PgDn/Home/End) just changed
  `CurrentSample` and returned AX=1 -- no reload, no redraw.

## The change
New near proc `LSWindow_PreviewCurrent` that replicates the EXACT keyjazz preview
setup, minus playing a note:
  - guard: if CurrentSample == SampleInMemory -> return (no I/O, no redraw)
  - SI = 96 * CurrentSample (sample header offset)
  - DisableStereoMenu = 1 (suppress the stereo menu during a preview load)
  - MIDI_SetLoaderSuppress ... LoadSample(99) ... MIDI_ClearLoaderSuppress
  - DisableStereoMenu = 0
Fully register-preserving (PushAD/DS/ES). Called from all six cursor-move handlers
right before `Mov AX,1 / Ret`.

Why reuse LoadSample(99) rather than a lighter draw: the waveform is drawn off slot
100, which only holds real PCM after a preview load; LoadSample is the proven path
that fills it AND carries the keyjazz-hang protection (MIDISyncLoaderSuppress). The
SampleInMemory guard keeps rapid scrolling from doing redundant work.

Cost/known limit: each genuine selection change does a real preview load (file
open + PCM read + soundcard upload), same as one keyjazz press. Fine for typical
module samples; very large samples add a brief per-move load. @known-limit.

## Grade
`@build-verified` -- TASM assembles IT_DISK.asm Error/Warning None; TLINK links
IT.EXE (482808 bytes). `@runtime-untested @hw-untested` until Esa confirms on the
DOS box that arrowing through samples repaints the waveform live.
