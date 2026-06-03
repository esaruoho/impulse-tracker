# Session — f2-resize-tiles-pattern

> The thinkspace leg of the `f2-resize-tiles-pattern` report-card triad.
> Faithful, not flattering.

## Honest scope note (read first)

Written **alongside the build**, same session as the code.

## The request (verbatim intent)

Esa, from the feature wantlist:

> Feature: When user resizes, with Pattern Editor F2 extension, the pattern is
> duplicated
> Given that the User has a pattern of 64 rows
> When the User changes from 64 to 128 or to 192 rows
> Then the content of the 64 rows gets duplicated until the end of the pattern

Asked in the same breath: "verify that these are addressed" (the 5-item batch).
This was the ONE item not yet done.

## The investigation

Two existing length-change paths, neither tiled the way Esa wants:

- **F2 config (second F2)** -- `Glbl_F2_1` (IT_G.ASM:243): runs the config UI,
  then `MaxRow = NumberOfRows - 1`. Extending just exposed blank rows. This is
  the path Esa named ("Pattern Editor F2 extension").
- **Ctrl-F2 bulk editor** -- `PE_SetPatternLength` (IT_PE.ASM:13803): sets MaxRow
  over a range of patterns; also no tiling.

The only place that DID tile was the F11 **Alt-E** gesture,
`PE_OrderList_ExtendPattern` (IT_PE.ASM:3206) -- but it's a fixed 2x double
(64->128 only) on the order-list, not the F2 path and not arbitrary N.

## Why the fix is what it is

- **Generalise the proven tiler, don't invent one.** `PE_OrderList_ExtendPattern`
  already had the exact row word-copy idiom (320 bytes/row, MovsW, on
  PatternDataArea). The new `PE_TilePatternToLength` is that loop generalised
  from "one extra copy" to "fill rows OLD..NEW-1 with a wrapping source index",
  giving full copies plus a partial final copy ("...until the end").

- **Capture OLD on entry, tile on leave.** `Glbl_F2_1` already computes the old
  length at entry (`NumberOfRows = MaxRow+1`); stash it in `F2_OldRowCount`. After
  the config UI returns the new `NumberOfRows`, tile only if it grew, then commit
  `MaxRow`. Shrinking takes the original path untouched.

- **No explicit store needed.** Stock F2 length-change relies on the working-copy
  model: the decoded `PatternDataArea` IS the live pattern, re-encoded on the next
  pattern switch / save. `PE_SetPatternModified` (already called in `Glbl_F2_1`)
  marks it dirty. So tiling the buffer is sufficient and consistent -- matching how
  stock length-change persists, rather than bolting on a `StorePattern` the stock
  path doesn't use.

- **Register-safe, segment-safe.** The helper is `PushA` + `Push DS/ES`, sets
  DS=ES=PatternDataArea itself, and restores -- so `Glbl_F2_1`'s DS=Pattern is
  intact across the call. Source region (rows 0..OLD-1) and dest region
  (OLD..NEW-1) never overlap, so `Rep MovsW` forward is safe. 200-row clamp keeps
  it inside the 64 KB buffer (200*320 = 64000 bytes).

## What was rejected / not done

- **Tiling the Ctrl-F2 bulk editor and Alt-E.** Esa named the F2 path; scope kept
  tight. Easy follow-ups if wanted.
- **An explicit PEFunction_StorePattern in the F2 path.** Unnecessary (working-copy
  model) and risked diverging from stock length-change semantics.

## Honest grades

- `@build-verified` is real: DOSBox-X BUILDALL, IT_PE.asm + IT_G.asm
  Error/Warning = None, IT.EXE links.
- `@runtime-untested` is honest: not yet confirmed by running IT.EXE, growing a
  64-row pattern to 128/192 on the F2 config, and eyeballing the duplicated rows.
  IT.EXE is relaunched and ready. Watch specifically: the partial-copy case
  (64->100) and that the tiled content survives a pattern switch (the store path).

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/e86aa106-2936-452b-805c-e3418c03140c.jsonl
- Session ID: `e86aa106-2936-452b-805c-e3418c03140c`
- Resume: `claude --resume e86aa106-2936-452b-805c-e3418c03140c`
- Session timestamp: 2026-06-03 ~15:29 EEST (run `date` to confirm)
- CWD: /Users/esaruoho/work/impulse-tracker (repo root)

## Cross-links

- Spec leg: `features/f2-resize-tiles-pattern.feature`
- The F2 screen: `features/f2-pattern-editor.feature`
- The 2x prior art: `features/f11-order-list-power-tools.feature` (Alt-E)
- Feature commit: `05c70c9`
