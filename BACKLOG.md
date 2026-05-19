# Impulse Tracker (esaruoho fork) — Brainstorming Backlog

A living wishlist for "this is what I want for this tracker." Items get added
freely as ideas surface; they get moved between sections as they crystallize,
get scoped, get implemented, or get rejected. Nothing here is locked in stone
until it's in the **Implemented** section and shipped.

**How to use this document:**
1. Drop new ideas into the **💡 Wishlist / brainstorming** section, no friction.
2. As an idea gets scoped (size estimate, dependencies, design sketched), move
   it to **⏳ Confirmed deferrals** or **🟡 In-flight**.
3. When shipped in a build, move it to **✅ Implemented**, note the commit SHA.
4. If an idea gets rejected, move it to **🗑️ Rejected** with the reason —
   keeps the audit trail so we don't re-litigate.
5. Outstanding bug investigations live in **🐛 Open bugs**.

---

## 🟡 In-flight

_(Currently nothing.)_

---

## 🐛 Open bugs / awaiting field test

### Ctrl-O "bad WAV header" import failure

Build `18e8da4` ships diagnostic markers at row 0 of the screen to narrow
which validation rejected the rendered file. **Awaiting field-test readings:**

- Col 27 letter: `R` / `W` / `P` / `F` / `+`
  - `R` = RIFF magic at offset 0 wrong
  - `W` = WAVE magic at offset 8 wrong
  - `P` = PCM format code at offset 20 wrong
  - `F` = fmt chunk size at offset 16 wrong
  - `+` = all 4 checks passed (file's header is fine; bug is downstream)
- Cols 25-26: `d` + `e` visible = `D_GotoRenderDirectory` cd succeeded;
  missing `e` = chdir failed (different error path)

The 15-second hold is now key-dismissable so reading the markers no longer
looks like a crash.

---

## ⏳ Confirmed deferrals (planned, scoped, not yet implemented)

_(Currently empty — both items shipped in `068648f`. See Implemented.)_

---

## 💡 Wishlist / brainstorming (uncategorized, ideas only)

_Drop ideas here freely. No scoping needed yet — just capture the intent and
it gets refined later._

- _(empty — add your ideas)_

---

## ✅ Implemented (current build: `068648f`)

Newest first. Each line cites the commit SHA that landed it.

- `068648f` — Default new-pattern row count is configurable via
  F2-double-press dialog; user's last choice persists across launches.
  Clone-Mute-Wipe (`M` toggle) also persists in IT.CFG. Both stored in a
  new 16-byte PE_ForkExtConfig block appended after the Quicksave
  directory; backward-compatible with older IT.CFG files.
- `90cfd04` — F11 cursor-key edge gestures: Left at col 0 = clone verbatim;
  Shift-Left at col 0 = clone with mute-wipe; Right at col 2 = render +
  auto-import; Shift-Right at col 2 = render to Quicksave. Plain wrap
  preserved at non-edge cursor positions.
- `90cfd04` — `^^^` note-cut at row 0 of muted channels in clone-mute-wipe
  output, prevents lingering-sample bleed from previous pattern into clone.
- `1a7aa16` — F11 order list ops: Ctrl-O / Shift-Ctrl-O / Ctrl-G / Shift-G
  (render variants), Alt-D (clone), Alt-E (extend = double pattern rows
  in place), M (toggle mute-wipe). Mid-playback safe via the existing
  `PEFunction_StorePattern` ClI bracket.
- `18e8da4` — Ctrl-O diagnostic markers (cols 25-27, 40-42), dismissable
  15s hold, `"Rendering pattern to WAV ..."` info line.
- `a98a37c` — Shift-Ctrl-O on F2 = render to Quicksave without auto-import.
  Path-validation safety (pre-flight chdir test before audio teardown).
- `97712ce` — Ctrl-O routes renders to Quicksave folder, re-cd's before
  import open so the driver swap can't strand us in a stale cwd.
- `d8ec842` — F12 Samples → Instruments mode flip preserves drawn
  envelopes (envelope-byte comparison gates per-instrument re-init).
- `f541198` — Shift-Enter on a module row in F9 bulk-loads all samples
  from that module.
- Prior fork features (envelope presets, Alt-W Quicksave, Alt-R Replicate,
  MIDI sync, keyjazz-no-stop, Shift-F1 MIDI Monitor, etc.) — see git log
  for SHAs before `f541198`.

---

## 🗑️ Rejected (audit trail)

_(Currently nothing rejected.)_

---

## Notes

- The fork ships from `esaruoho/impulse-tracker` on GitHub. Upstream
  (`jthlim/impulse-tracker`) is read-only by maintainer policy; feature
  work happens on this fork.
- Bundles live in repo root as `IT2354-esaruoho-<sha>.zip` and on
  `/Volumes/AIFORIA2/` for portability.
- Every zip bundles `IT.CFG` from `/Volumes/AIFORIA2/IT.CFG` for drop-in
  install (see `feedback_zip_bundle_includes_itcfg` in memory).
- VRAM debug markers on row 0 are the established triage tool for hard
  hangs — see `IT_MUSIC.ASM:WAV_DebugMark` + `IT_DISK.ASM:D_DebugMark`.
