# Session — midi-realtime-sync

> The thinkspace leg of the `midi-realtime-sync` report-card triad.
> Faithful, not flattering. This file is the *how we got here* and the audit
> trail behind the grades in `midi-realtime-sync.feature`.

## Honest scope note (read first)

This `.session.md` was written **after** the feature shipped, during the
2026-06-03 carding session — not alongside the original build. The feature
itself was built across several earlier sessions (2026-04-23 → 2026-05-18)
whose transcripts are **not in hand**, so the original moment-to-moment
dialogue cannot be reconstructed faithfully. Rather than fabricate it, the
authoritative thinkspace trail for the *build* is the commit log in the card's
RESULT block. What follows is (a) the reasoning recoverable from those commits
and (b) a faithful record of the carding session.

## Why the decisions are what they are (recovered from commits + code)

- **Intercept in `MIDISend`, not per-driver.** Every driver funnels received
  bytes through the one `MIDISend` in `IT_K.ASM`. Putting the Real-Time logic
  there means one interception point instead of sixteen. (commit ec42bd1)
- **Test `>= 0F8h` before the running-status store.** The MIDI spec says
  System Real-Time is transparent to running status; doing the test first is
  the spec-correct order, not an optimisation. (ec42bd1)
- **FB Continue aliased to Start "for v1".** A deliberate shortcut, marked in
  the code comment and carried as a `@todo` scenario. Real resume needs
  last-known order/row passed to `Music_PlayPartSong`. Not lied about as done.
- **The drivers were silently eating the bytes.** The end-to-end feature did
  NOT work until `CheckMIDI` in 16 drivers stopped dropping everything `>= 0F0h`
  at IRQ time. Note bytes (8x/9x) got through because they're `< 0F0h`, which
  masked the bug for weeks. This is the single most important correction in the
  whole feature and the reason the card grades the driver scenario explicitly.
  (4ebf849 = 14 drivers, 78fb72d = GUSMIXDR + IWDRV)
- **Two independent gates, not one.** Clock sync (`MIDISyncEnable`) and
  transport (`MIDITransportEnable`) were split so a user can slave tempo
  without surrendering transport control, or vice-versa. Transport gate added
  later (731e168) once the clock gate (0a82cb3) proved the pattern.
- **Toggle moved Alt-F12 → Shift-F1.** First shipped on Alt-F12 (ad5d840),
  then relocated to a button on the Shift-F1 MIDI screen (7163709) so it lives
  next to the monitor it affects. ad5d840 is therefore SUPERSEDED, noted as such
  in the RESULT block rather than deleted.

## The honest grade

Everything here is `@build-verified` (assembles + links under TASM 4.1 /
TLINK 3.01) but **`@hw-untested`** for the live paths: DOSBox-X cannot inject
MIDI System Real-Time bytes, so FA/FB/FC/F8 have not been exercised against the
running build on real hardware. The 2026-05-04 project note calls the feature
"complete" — that means *code-complete across 16 drivers*, not hardware-verified.
The card says so plainly; grading it `@hw-verified` would be a lie.

## The carding session (2026-06-03)

The thread that produced this card, in order:
1. "what is your understanding of gherkin style language" → established Gherkin.
2. Read `karpathy-guidelines` skill → mapped think-before-coding / simplicity /
   surgical / goal-driven onto how to write `.feature` files.
3. Read `~/Downloads/karpathy-llm.md` (LLM Wiki) → the `.feature` is the wiki
   page; raw `.ASM` = immutable sources, cards = wiki, CLAUDE.md = schema.
4. "each session adds to the file… the report-card becomes the system… which
   commits relate to which features" → built `features/INDEX.md`, the two-way
   commit↔feature map. Reverse lookup is `grep -rl <hash> features/`.
5. Read `report-card` skill → the triad {card + session + RESULT}, four
   properties, generative-seed framing (codespace/thinkspace/areaspace).
6. "emit triad" → gathered real procs/lines/commits from source (no guessing),
   then wrote this card, this session, and the source back-link.

Wrong-turn logged honestly: during the INDEX build I initially typed an
unverified commit hash for the F4→F3 work, flagged it `?`, then verified it
(`9d626b0`, `672273b`) before finalising — per the no-guessing keybinding rule.

## How to get back

- Transcript (most-recently-modified for this project; inferred to be this
  session — could not be independently confirmed as the live session ID):
  file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/bfba3a95-7804-448c-b2be-5748a8bae097.jsonl
- Session ID (same caveat): `bfba3a95-7804-448c-b2be-5748a8bae097`
- Resume: `claude --resume bfba3a95-7804-448c-b2be-5748a8bae097`
- Carding session timestamp: 2026-06-03 11:31 EEST (run `date` to confirm)
- Build-history window (from git, authoritative): 2026-04-23 → 2026-05-18
