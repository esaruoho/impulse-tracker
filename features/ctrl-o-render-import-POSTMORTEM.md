# Post-mortem — the 5-hour Ctrl-O render-import crash (2026-06-23)

Honest retrospective. The actual fix was ~20 minutes of work; it took a full workday
because of avoidable process mistakes. Written so it doesn't happen again.

## The three bugs (they were distinct)
1. **REBOOT** — Ctrl-O with an empty order list. `Music_GetPattern` dereferenced an
   out-of-range pattern number (255, from `OrderList[0]=0FFh`) → wild pointer →
   triple-fault. Fix: bound-check `Music_GetPattern`. *(Correct, fast.)*
2. **HANG** — a single-pattern render never terminated. `StopEndOfPlaySection` was
   never set anywhere, so the pattern looped forever and the sync render loop spun to
   its 100000 cap. Fix: set the flag for the render. *(Correct, fast.)*
3. **CRASH ON IMPORT** — only *exposed* once #1/#2 let the render finish: the importer
   read the rendered WAV back **from the network Quicksave drive (`e:\2logic`) into the
   EMS sample buffer**, and reading a network file into EMS / upper memory wedges real
   DOS. Fix: **render the import WAV to LOCAL `C:\TEMP` and load from there.**

## The fix that should have taken 20 minutes
Bug #3 is "render to local, load from local." IT already loads samples from local disk
flawlessly (`D_LoadSampleData`); the *only* thing wrong was the source being a network
drive. Route the import render to `C:\TEMP`, leave the no-import export on the network.
Done.

## Where the hours actually went (the mistakes)
1. **Ignored the biggest clue.** Esa said early: *"we had a fully functioning system
   creating a 1.4MB sample."* That makes it a **REGRESSION** — something changed. The
   first move should have been: *what is different now vs. when it worked?* Answer: the
   Quicksave folder is a network drive now. That points straight at "render to local."
   Instead I treated it as a novel deep bug and theorised about EMS.
2. **Chased the wrong fix.** The diagnosis (network read into EMS crashes) was right;
   the fix was wrong. I pursued a **bounce buffer**, which needs conventional memory IT
   doesn't have: the DOS `48h` alloc fails (IT owns all memory), then a **static 16KB
   buffer STARVED PLAYBACK** ("insufficient memory", loads but won't play). ~2 hours +
   a broken-playback incident, all avoidable.
3. **Didn't listen fast enough.** Esa proposed the actual fix TWICE — *"ctrl-o doesnt
   write to quicksave, just renders to sample"* and *"render to c:/ or c:/temp."* That
   WAS the answer. I kept chasing the buffer instead of building what he said.
4. **Shipped an unverifiable change that broke a core function.** Baking 16KB into a
   memory-constrained real-mode DOS EXE — which I could not runtime-test — and starving
   playback is the cardinal sin of this session.

## What was done right (so the lessons stay calibrated)
- The reboot and hang fixes were correct and quick.
- The `CTRLOLOG` breadcrumb logging was the right instrument — the per-page `PG` log
  localised the crash to **page 0 of the read loop** definitively. That was the turning
  point and is worth keeping.
- Rolled back the instant playback broke.

## Process rules going forward (the point of this document)
1. **"It worked before" ⇒ regression analysis FIRST.** Find what changed and restore /
   route around it. Do not invent a new mechanism before answering "what changed?".
2. **Use the existing working code as the reference.** IT loads local samples fine →
   make the import read a local file. Don't out-think a path that already works.
3. **Never grow a memory-constrained real-mode image blindly** — especially a change I
   can't runtime-test. Check the budget (the `.MAP`) before adding anything to the
   footprint. Playback memory is sacred.
4. **When the user proposes a concrete fix, build THAT first.** Esa diagnosed it
   correctly; implementing his suggestion immediately would have saved ~4 hours.
5. **Minimise crash-test round-trips.** Each one costs the user a reboot. Front-load
   reasoning; only request a hardware test when a specific log will give a yes/no answer
   (the breadcrumb logging did this well — the buffer detours did not).

## The one-line version
It was a regression caused by the Quicksave folder being a network drive; the fix was
"render Ctrl-O to local disk and load from there" — which the user said out loud twice.
I should have done regression analysis on minute one and built the user's suggestion on
minute two, instead of spending hours on a bounce buffer that couldn't fit in memory.
