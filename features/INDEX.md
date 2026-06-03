# Feature Index — the commit ↔ feature map

> The rollup page for the report-card system (see `../GHERKIN-FEATURE-WIKI-PATTERN.md`).
> Each fork feature is a `.feature` card; each card owns a set of commits. This index
> is the two-way join between `git log` (immutable source of truth) and the cards
> (compounding understanding).
>
> **Forward** (feature → commits): read the card's `Commit log` header + per-scenario
>   `# cite: ... commit XXXX`.
> **Reverse** (commit → feature): `grep -rl <hash> features/`.
> **Audit**: every fork commit below should resolve to exactly one card. A commit with
>   no card is the work surface — bookkeeping not yet done, or a feature not yet carded.
>
> Card status: ✅ carded · 🟡 partial · ⬜ no card yet

---

## Carded features

### ✅ midi-in-multitimbral.feature
Live 16-part sampler; per-instrument MIDI-In channel (hdr 1Fh); Shift-F4 3-state cycle; Shift-F1 router toggle.
- `10c837b` per-instrument MIDI-In channel + Shift-F4 batch v1
- `7e3620a` live any-screen note router (MIDIMulti_Route)
- `2dac7d5` Shift-F4 made a toggle
- `b5a0c66` Shift-F4 gated to Instrument mode *(superseded by 8c32fd2)*
- `8c32fd2` 3-state cycle + Shift-F1 toggle + gate removed
- `7f5b2ff` the card itself + source back-links

### 🟡 wav-render-quicksave.feature
Ctrl-O render → auto-import; Shift-Ctrl-O no-import; Quicksave routing; LL\<HHMMSS\>.WAV naming.
- `35732c3` Ctrl-O renders current pattern (P1)
- `089119a` Ctrl-O toggles ITWAV.DRV render mode (P2a)
- `af03f96` Ctrl-O auto-imports rendered pattern (P2.5+P3)
- `e4c9b4a` deep-dive findings doc for P2/P3
- `1d7910e` `09d7e7d` `bb5e5ea` `9ed42ed` `64b853b` `4d5e9da` `3a626b4` `e3f5815` `f136a7b` `b0690a4` `ce3fb79` `9bd18d1` `81c78aa` `d13a849` `0c02662` P3 hardening chain
- `3537c0d` Ctrl-O hang VRAM markers
- `4ae100e` `b72f541` `f401e39` Ctrl-O robustness (header check, logging, 0-byte cleanup)
- `a98a37c` Shift-Ctrl-O no-import + 15s marker hold
- `18e8da4` Ctrl-O diagnostics / dispatcher trace
- `97712ce` render to Quicksave folder + import open-fail fix
- `6464e15` Quicksave folder: Alt-W save / Shift-Alt-W memorize
- `7fd1abc` F12 Quicksave directory row
- `be595b2` .WAV extension *(carded)*
- `74c3fe8` LL\<HHMMSS\>.WAV naming *(carded)*
- `34b725d` `054f1f0` gitignore rendered samples / repo-root IT.CFG

### ✅ wav-render-reentry-guard.feature  (+ .session.md, full triad)
A second render gesture mid-render (Right then Shift-Right at the F11 order-list right edge; or a second Ctrl-O/Ctrl-G/Shift-G) now early-stops like Esc and finalizes to Quicksave instead of re-entering the teardown and wedging IT. New `WAV_FinalizeRequest` discriminator. Build-verified, runtime-untested.
- `c9ff6b9` guard re-entrant WAV render gesture; second press early-stops to Quicksave
- Card + session authored same session; card-commit hash follows `c9ff6b9`

---

## Carded features (continued)

### ✅ midi-realtime-sync.feature  (+ .session.md, RESULT block, source back-links)
External transport: FA/FB/FC Start/Stop/Continue, F8 Clock tempo sync, driver F8–FF passthrough, Sync/Transport toggles, MIDI Monitor.
- `ec42bd1` start/stop song on MIDI System Real-Time messages
- `ad5d840` MIDI Sync default ON + Alt-F12 toggle *(superseded by 7163709)*
- `7163709` move toggle to Shift-F1 MIDI screen
- `95f628a` MIDI Monitor RT byte counters
- `4ebf849` drivers stop filtering F8–FF (14 drivers)
- `78fb72d` GUSMIXDR + IWDRV stop filtering F8–FF (last 2 = 16 total)
- `03b0a6d` `0a82cb3` MIDI Clock 0xF8 external tempo sync + enable flag
- `731e168` MIDI Transport toggle (independent FA/FB/FC gate)

### ✅ scrolllock-follow-from-lists.feature  (+ .session.md, full triad)
Scroll Lock on F3 Sample List / F4 Instrument List force-enables Pattern Follow Mode and opens the Pattern Editor (= F2). Build-verified, runtime-untested.
- *(uncommitted working tree as of 2026-06-03)* — IT_PE.ASM `PE_ScrollLockFollow` + IT_OBJ1.ASM two keylist entries (146h on Sample/Instrument lists)
- Card + session authored same session; RESULT hash TBD on commit

### ✅ shift-enter-bulk-load-from-module.feature  (+ .session.md, full triad)
Sample-loader browser: Shift-Enter on a module row bulk-loads all its samples into
consecutive slots (names + loop modes preserved). Carded while fixing a .MOD
hard-hang (missing loader-cache finalisation). Build-verified, runtime-untested.
- `f541198` Shift-Enter on module row = bulk-load all samples (original)
- *(this session)* MOD hard-hang fix: finalise loader cache before loop/teardown

## Uncarded features (the work surface)

### ⬜ loader-keyjazz-hang.feature
F3/F4 loader keyjazz no longer kills playback; Music_SilenceSampleVoices.
- `a44c41b` Music_SilenceSampleVoices (keep playback alive across reloads)
- `ec91331` F3 loader keyjazz hang VRAM markers
- `64fa1ce` F3 loader keyjazz hang fix via MIDISyncLoaderSuppress

### ⬜ alt-r-replicate.feature  (Paketti port)
- `d506486` Alt-R = Replicate at Cursor
- `aaada5e` Alt-R tile at row 0 + Shift-Alt-R = ClearViews

### ⬜ f11-order-list-power-tools.feature
Ctrl-O/Shift-Ctrl-O/Ctrl-G/Shift-G render, Alt-D clone+insert+advance, Alt-E extend, M toggle, cursor-key edge gestures.
- `1a7aa16` render / clone / extend + mute-wipe toggle
- `90cfd04` cursor-key edge gestures + note-cut at row 0
- `6e15aa7` clone/extend crash fix
- `4eee4f8` clone auto-insert + runtime status *(shared with f12-pickers)*

### ⬜ f12-directory-pickers.feature
Module/Sample/Instrument/Quicksave rows Enter-pickable via D_PickDir_Common.
- `8ca7078` F12 Module Directory Enter opens F9 picker
- `8f11aa6` translate '/' → '\' in F12 input fields
- `4eee4f8` F12 dir pickers *(shared with f11)*

### ⬜ multi-wav.feature
Shift-Alt-M per-pattern; F10 WAV (whole-song single) + MWAV (per-channel) buttons; K_TranslateCondition11 for Shift+Alt.
- `9fb5ac1` Multi-WAV + F10 MWAV + F10 WAV + Shift+Alt keymap condition

### ⬜ f2-pattern-editor-defaults.feature
F2 Pattern Editor config (second F2): default pattern length + M flag, persisted in IT.CFG.
One screen → one runnable scenario.
- `068648f` F2-F2 default pattern length persists + M flag persists (IT.CFG ext block)

### ⬜ f4-f3-cursor-translate.feature
F4 Instrument list ↔ F3 Sample list: carry the cursor selection across the two screens.
- `9d626b0` F4→F3 cursor translation
- `672273b` F4→F3 translate: bounds + note-60-first then scan-all fallback


<!-- REMOVED: samples-to-instruments-envelope (reverted feature). A "here's what
     was removed" bucket is a tombstone, not a behaviour card — the feature map
     describes what works. The parked feature still lives in PR #3 + its project
     memory; it does not belong in the runnable-feature index. -->

<!-- SPLIT RULE (Esa, 2026-06-03): a feature must be small enough to be ONE
     runnable, screenshot-checkable unit. "navigation-and-persist" was a grab-bag
     of F2 / F3-F4 / F9 behaviours that can't be verified in a single screen, so
     it is split per UI surface. F2 Pattern Editor is its own feature; F4↔F3 is
     its own; F9 bulk-load is its own. Features may link to each other. -->


---

## Non-feature commits (infrastructure / docs / base) — carded as process, not behaviour

**build-infra**: `1fa031c` `be79b3c` `5bd73ed` `1c4ca74` `84c7e1b` `3e49ca3` `fc92c77` `1b2bcf1`
**release-workflow** (v2.354): `8d80eff` `62e6991` `141893b` `fe1df01` `c599007` `400ea5b` `e4fafa6` `2eb6088` `87cc192` `53fa15d`
**docs/skill**: `0afd402` `e3e6940` `16d89da` `2051b90` `06ac14a` `eaa34e2` `5260c3d` `0a9fa2d` + (uncommitted) `GHERKIN-FEATURE-WIKI-PATTERN.md`, this index
**backlog**: `ecc745b` `5ece809`
**upstream/base** (pre-fork + version stamp): `fb47b32` `10e9e50` `a7466b7` `f2c9da1` `04a5a9e` `a09c04f` `11f82a2` `7144cd1` `5fe2570` `b09e0ef` `58c44e4` `aa311f5` `7df9edf`

---

## Coverage today
5 behaviour cards exist (multitimbral ✅, wav 🟡, midi-realtime-sync ✅ full triad,
scrolllock-follow-from-lists ✅ full triad, shift-enter-bulk-load-from-module ✅
full triad — the last carded while fixing a .MOD hard-hang);
**6 fork features remain uncarded** and listed above with their commit sets ready to drop
into card headers. Carding them is the remaining bookkeeping — at which point every
behaviour-bearing commit resolves to exactly one card.

Reverse-lookup note: `rg`/ugrep skip untracked + git-ignored files by default, so a
freshly-written card won't resolve until committed (or use `grep -rlF <hash> features/`
/ `rg -F --no-ignore`). After commit, plain `grep -rl <hash> features/` works.
