# Session — scrolllock-follow-from-lists

> The thinkspace leg of the `scrolllock-follow-from-lists` report-card triad.
> Faithful, not flattering. This is the *how we got here* and the audit trail
> behind the grades in `scrolllock-follow-from-lists.feature`.

## Honest scope note (read first)

Unlike the older fork cards, this `.session.md` was written **alongside the
build**, in the same session that wrote the code — so the dialogue below is the
actual spawning conversation, not a reconstruction.

## The request (verbatim intent)

Esa asked, mid-session, for a new feature framed as Gherkin:

> "know how Scroll Lock sets Pattern Playback follow on. but when i press it in
> F3 Sample List, it should result in a response. so the Gherkin Feature of this
> is. Feature: User Presses Scroll-Lock while in F3 and F4 / Given that the user
> is in Sample List / And they press Scroll-Lock / Then the Pattern Editor opens
> with Pattern Follow Mode enabled."

Then: "remember, the report card rule applies."

## Why the decisions are what they are

- **Reuse Glbl_F2 instead of re-implementing the screen switch.** The Pattern
  Editor is entered by `Glbl_F2` (IT_G.ASM:224), which on the normal path sets
  `CurrentMode=2` and returns `AX=5 / DX=Offset O1_PatternEditList` to the key
  dispatcher. The new handler tail-jumps (`Jmp Glbl_F2`) so its Far Ret carries
  that same return value back. Pressing Scroll Lock on a list is therefore byte-
  for-byte equivalent to pressing F2, plus the Follow-Mode pre-set. No duplicated
  screen-init logic, nothing to drift out of sync with F2.

- **Force Follow Mode ON, not toggle.** Stock Scroll Lock in the Pattern Editor
  (`PEFunction_ToggleTrace`, IT_PE.ASM:13298) XORs `TracePlayback`. From a list
  the user's intent is unambiguously "start following", so the handler does
  `Mov TracePlayback, 1` (set). A toggle could perversely land you in the editor
  with following OFF if it was already on. The Gherkin literally says "with
  Pattern Follow Mode enabled" — enable, not toggle.

- **DS save/restore around SetInfoLine.** `SetInfoLine` reads its message at
  DS:SI. `TraceMsg` lives in the Pattern code segment. On the list screens DS is
  NOT the Pattern segment, so the handler does `Push CS / Pop DS` to point DS at
  the message (the exact trick `Glbl_Shift_F4` uses in IT_G.ASM), then restores
  the dispatcher's DS with a paired `Push DS` / `Pop DS` before `Jmp Glbl_F2`.
  Belt-and-braces: `Glbl_F2` re-loads DS itself via `Music_GetSongSegment`
  (inside `Glbl_SampleToInstrument`, IT_G.ASM:1063), so the restore isn't strictly
  load-bearing — but it keeps the handler's contract with Glbl_F2 identical to a
  real F2 press, which is the safe default.

- **Bind on the list keylists, NOT GlobalKeyList.** The entry went into
  `SampleGlobalKeyList` (IT_OBJ1.ASM:3536) and `InstrumentGlobalKeyList` (6666)
  only. Adding it to `GlobalKeyList` would have made Scroll Lock teleport the
  user into the Pattern Editor from *every* screen that chains to GlobalKeyList
  (Order list, Song vars, loaders…). The request was F3/F4; scope was held to
  F3/F4. Carried as the `@todo` out-of-scope scenario in the card.

- **Entry order in the Instrument list.** `InstrumentGlobalKeyList` ends with a
  `DB 4 / DW 0 -> I_PlayNote` "always call function" catch-all. The Scroll Lock
  entry was placed BEFORE it so the 146h keyword is matched first; otherwise the
  always-call would swallow the key.

## The honest grade

`@build-verified` + `@runtime-untested`.

- **Build:** real, this session. `dosbox-x -conf buildall.conf` at 2026-06-03
  12:01 EEST. `MAKE.LOG` shows `IT_OBJ1.asm` and `IT_PE.asm` each "Error
  messages: None / Warning messages: None"; TLINK 3.01 linked; `IT.EXE` grew
  476298 -> 476375 bytes (+77, the new handler). The cross-module symbol
  `PE_ScrollLockFollow` resolved (no "undefined symbol" from the linker), proving
  the Extrn/Global wiring between IT_OBJ1 and IT_PE is correct.
- **Runtime:** NOT exercised. I did not launch IT.EXE, load a module, press
  Scroll Lock on the Sample/Instrument list, and watch the cursor follow. Grading
  the behaviour scenarios `@runtime-verified` would be a lie. They are
  `@build-verified @runtime-untested` until someone runs it.

## Open follow-ups

- Runtime-test in DOSBox-X: F3 -> Scroll Lock -> confirm Pattern Editor opens,
  Scroll Lock LED on, cursor follows during F5/F6 playback. Same from F4.
- Commit is still pending — Esa had not asked to commit at the time of writing.
  When committed, backfill the RESULT block hash in the card and INDEX.md.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work/442513b6-4d90-4fef-959c-1ac9d79e8ec0.jsonl
- Session ID: `442513b6-4d90-4fef-959c-1ac9d79e8ec0`
- Resume: `claude --resume 442513b6-4d90-4fef-959c-1ac9d79e8ec0`
- Session timestamp: 2026-06-03 ~12:02 EEST (run `date` to confirm)
- CWD for this session: /Users/esaruoho/work (not the repo root; repo is
  /Users/esaruoho/work/impulse-tracker)
