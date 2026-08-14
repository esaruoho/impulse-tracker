---
name: WAV render keeps the music going (fast pattern render + MIDI-clock resume)
slug: wav-render-keeps-the-music-going-fast-pattern-render-midi-clock-resume
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/dist/wav-render-keep-playback.gherkin.feature.

## Claims
- Scenario (L13): A single-pattern render runs faster than realtime (brief freeze)
- Scenario (L24): Whole-song render stays realtime
- Scenario (L34): A song that was playing resumes after the render, on the next MIDI clock
- Scenario (L44): No resume if nothing was playing
- Scenario (L53): True simultaneous live-audio + render is NOT done
- Scenario (L68): A single-pattern render runs faster than realtime (brief freeze)
- Scenario (L79): Whole-song render stays realtime
- Scenario (L89): A song that was playing resumes after the render, on the next MIDI clock
- Scenario (L100): Standalone Ctrl-O resumes on its own, with no external clock
- Scenario (L113): Resume matches the play mode that was active at render enter
- Scenario (L125): No resume if nothing was playing
- Scenario (L134): True simultaneous live-audio + render is NOT done

## Relationships
