# Session — f6-play-from-order-list-row

> The thinkspace leg of the `f6-play-from-order-list-row` report-card triad.
> Faithful, not flattering.

## Honest scope note (read first)

Written **alongside the build**, same session as the code.

## The request (verbatim intent)

Esa: "again a test and a development schedule, write it and then make a report
card."

> Feature: When selecting a Order List row and pressing F6, playback starts from
> the Order List Row Pattern
> Given that the User is in Order List (F11)
> When the User presses F6 to start Pattern Playback, or F7 to start "from row"
> playback
> Then the selected Order List starts playing.

## The investigation (what I found before writing code)

- **`Glbl_F6` (IT_G.ASM)** was `PE_GetCurrentPattern -> Music_PlayPattern` — i.e.
  "play the pattern editor's CURRENT pattern," looped. Not tied to the order list
  at all.
- **`Order` (IT_PE.ASM ~1828)** is the selected order ROW in the F11 list
  (`OrderCursor` is just the digit column 0/1/2 within the 3-char cell — a
  different thing). `Order` lives in the Pattern code segment.
- **`Music_PlaySong` (IT_MUSIC.ASM:9106)** takes `AX = Order` and plays the song
  from that order onward — exactly "start from the selected order".
- **`PE_F7` (IT_PE.ASM:13254) is ALREADY order-aware**: it takes the PlayMark (or
  current pattern+Row), maps it onto the order list via the song's order array,
  and plays `Music_PlayPartSong`. So F7's "from row" already works — the only new
  work is F6.
- F6/F7 reach `Glbl_F6`/`PE_F7` from the order list because F11's keylist is
  `GlobalKeyList`, whose `PlayCommandChain` binds F6->Glbl_F6 and F7->PE_F7.

## Why the fix is what it is

- **Gate `Glbl_F6` on `CurrentMode==11`.** That value IS the Order List (IT_G's
  own comment: "11 = order/panning list"). In the list, F6 plays from the order;
  everywhere else (pattern editor = 2, etc.) it keeps the stock "play current
  pattern". Minimal blast radius, one proc.
- **`Music_PlaySong(Order)`, not `Music_PlayPattern`.** "the selected Order List
  starts playing" reads as *play the arrangement from here*, not *loop one
  pattern*. PlaySong starts at the selected order's pattern AND advances through
  the order list. (If Esa actually wants a single looped pattern, that's a one-line
  swap to Music_PlayPattern of the order's pattern — flagged as a design choice in
  the card.)
- **Read `Order` directly in IT_G.** `Order` is in the Pattern segment;
  `Glbl_F2_1` already shows the idiom (`Mov AX, Pattern / Mov DS, AX / Assume
  DS:Pattern`). `Music_PlaySong` and `I_ClearTables` are already Extrn in IT_G, so
  no new imports — the whole change is inside `Glbl_F6`.
- **Left `PE_F7` untouched.** It already does order-aware from-row play; changing
  it would be scope creep and risk regressing F7.

## What was rejected / not done

- **A separate order-list keylist with its own F6 entry.** O1_OrderPanningList has
  no own keylist (it points straight at GlobalKeyList), so that path would mean
  authoring a new keylist + repointing the object. The CurrentMode gate is far
  cheaper and equivalent.
- **Changing F7.** Already works.

## Honest grades

- `@build-verified` is real: DOSBox-X BUILDALL, IT_G.asm Error/Warning = None,
  IT.EXE links.
- `@runtime-verified` (2026-06-04): Esa confirmed on a live IT.EXE — "F6 + F7
  work." F6 starts the song from the selected order row; F7's pre-existing
  order-aware from-row play also confirmed.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/e86aa106-2936-452b-805c-e3418c03140c.jsonl
- Session ID: `e86aa106-2936-452b-805c-e3418c03140c`
- Resume: `claude --resume e86aa106-2936-452b-805c-e3418c03140c`
- Session timestamp: 2026-06-04 ~07:03 EEST (run `date` to confirm)
- CWD: /Users/esaruoho/work/impulse-tracker (repo root)

## Cross-links

- Spec leg: `features/f6-play-from-order-list-row.feature`
- F11 order-list power tools: `features/f11-order-list.feature`
- Feature commit: `8acb41f`
