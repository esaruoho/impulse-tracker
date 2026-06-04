# The .feature as a Session Command — Gherkin × Karpathy LLM Wiki

> Synthesis (2026-06-03): how Gherkin feature files, written under the Karpathy
> coding guidelines, become the persistent "wiki" layer of architectural
> understanding for this codebase — and how each `.feature` becomes a loadable
> *command* that reconstitutes the thinkspace for one piece of code.

## The three ideas being fused

1. **Gherkin / Given-When-Then** — plain-text, structured, verifiable descriptions
   of behavior. Readable by humans, parseable by machines.
2. **Karpathy coding guidelines** — think before coding, simplicity first, surgical
   changes, goal-driven execution. Bias toward explicit intent and verifiable goals.
3. **Karpathy LLM Wiki** (`karpathy-llm.md`) — don't re-derive understanding from raw
   sources on every query. Build a persistent, compounding, cross-referenced wiki that
   sits *between* you and the immutable raw sources, and keep it current.

The insight: **the `.feature` file is the wiki page.** Not a test artifact bolted on
afterward — the primary store of architectural understanding, written once and kept
current, that lets any session (human or LLM) reconstitute *what this code is for*
without re-reading thousands of lines of assembly.

## Mapping the LLM Wiki's three layers onto this repo

| LLM Wiki layer | In impulse-tracker |
|----------------|--------------------|
| **Raw sources** (immutable; read, never re-derived) | The `.ASM` files — `IT_K.ASM`, `IT_MUSIC.ASM`, `IT_PE.ASM`, the drivers. 16-bit TASM. The source of truth, but expensive to re-understand every session. |
| **The wiki** (LLM-owned, compounding, cross-referenced) | The `.feature` files. One per behavior cluster: `midi-realtime-sync.feature`, `loader-keyjazz.feature`, `wav-render-quicksave.feature`. Each scenario is a *verified claim* about behavior, cited to a source line. |
| **The schema** (how the wiki is structured + workflows) | `CLAUDE.md`. Already exists. Already tells a session how to behave, where the entry points are, the honesty protocol for keybindings. |

This codebase is **already a partial instance of the pattern.** The CLAUDE.md
keybinding tables that cite `IT_K.ASM:725` and commit `a44c41b` are wiki pages with
citations back to the immutable source. The commit hashes are the `log.md`. Turning
those tables into `.feature` files formalizes what's already happening informally.

## Why each guideline makes the wiki faithful

The Karpathy guidelines are not decoration here — they are what keeps the wiki a *true*
compressed representation of the code instead of a drifting fiction.

- **Think before coding** → the `.feature` is written/revised *before* the assembly is
  touched. It's the place where assumptions are surfaced and intent is *recorded*, not
  reverse-engineered after the fact. The understanding is captured at the moment it's
  clearest — when you decided what the code should do.
- **Simplicity first** → one scenario = one behavior. The wiki only stays a faithful
  compression if it stays simple. Bloated 10-`And` scenarios are the wiki rotting. This
  is the Wiki doc's **lint** operation: kill contradictions, kill stale claims, keep
  pages lean.
- **Surgical changes** → add a scenario for new behavior; don't reword the neighbors.
  Matching step phrasing is what keeps the wiki cross-referenceable (shared step
  definitions = shared vocabulary). Same discipline that keeps a wiki's links intact.
- **Goal-driven execution** → the `Then` *is* the success criterion. A `.feature` is a
  goal-driven loop written down: Given (arrange) / When (act) / Then (the verifiable
  goal). A vague `Then it works` is Karpathy's "weak criteria"; a concrete `Then only
  the preview voice falls silent, song playback continues` is a strong criterion you
  can verify and walk away from.

## The punchline: the .feature is a *command for the session*

Here is the part that ties it together. In the LLM Wiki, you read `index.md` first,
then drill into the relevant page. For a codebase, the relevant `.feature` is both:

1. **The understanding** — the verified, compressed account of what this code does and
   why. Load it and you have the thinkspace without re-deriving it from raw assembly.
2. **The command** — because it's Given/When/Then with verifiable `Then`s, loading it
   also loads the *goal*. It scopes the session: this is the behavior, this is what must
   stay true, this is the boundary of what we're touching.

So starting a session on "MIDI sync" becomes: load `midi-realtime-sync.feature`. That
single file reconstitutes the codespace (what's true now), the thinkspace (why it's
built this way), and the command (what success looks like for any change). The
`.feature` is the durable, compounding artifact; each session adds to it rather than
re-discovering it.

## The card is a generative SEED: codespace / thinkspace / areaspace

The deepest version of "the .feature is a command" (2026-06-03, Esa): the report
card is not a *description* of work already done — it is the **seed the work is
spawned from**. The card comes first; everything else flows back out of it. Given
the card plus its session, you can re-spawn all three spaces:

- **Codespace** — the file structure. Not only the card's own two files
  (`<name>.feature` + `<name>.session.md`), but the innards layout the card cites:
  which source files, which procs, the order they run. From the card you can
  scaffold the files or re-derive the code; the card *is* the build instruction.
- **Thinkspace** — the reasoning. The **session** (`<name>.session.md`) holds the
  dialogue that produced every decision, the wrong turns included. Load it and you
  have the WHY without re-deriving it. This is also what the **vibe diff** diffs.
- **Areaspace** — the domain boundary. The `Feature:` narrative plus the
  "what-keeps-the-old-behaviour" scenarios mark what this unit OWNS and what it
  must NOT touch. The boundary is part of the seed: re-spawning stays in-bounds.

So the pair `{card, session}` is a closed seed. `card` ⇒ codespace + areaspace;
`session` ⇒ thinkspace. A card without its session can spawn the code but not the
vibe — that is why a card alone is INCOMPLETE. Whitelabeled (see the report-card
memory): a circuit block's card spawns its netlist (codespace), its design
conversation (thinkspace), and its interface contract / what-it-must-not-load
(areaspace) the same way.

## How the wiki stays current (the compounding bit)

- **Ingest** = a commit changes behavior. You update the affected scenario and note the
  supersession. Example: when `0xFB` Continue stops being aliased to Start and gets a
  real `Music_Continue`, the scenario flips from `@todo` to `@shipped` and the old claim
  is struck. The commit hash is the log entry.
- **Query** = "what does Ctrl-O do?" → read the feature, get the answer with a citation,
  and if you discovered something new, *file it back* as an updated scenario so it
  compounds instead of vanishing into chat.
- **Lint** = periodically: orphan features (behavior with no source citation), stale
  scenarios (source moved), behaviors mentioned in CLAUDE.md but lacking a feature,
  contradictions between a scenario and the current `.ASM`.

## The grade ladder (and the hardware floor)

A scenario's tags are its honesty grade. The verification ladder, weakest → strongest:

- `@build-verified` — assembles + links clean (full BUILDALL, Error/Warning None).
- `@runtime-verified` — confirmed on a running `IT.EXE` **in DOSBox-X** (emulation).
- `@hw-untested` — **NOT run on real DOS hardware.** DOSBox-X is an emulator, so
  `@runtime-verified` is *not* the same as hardware-proven. **Every fork feature
  carries `@hw-untested` until someone runs it on real DOS metal** — even the
  `@runtime-verified` ones. It is removed only when a feature is actually
  hardware-confirmed (then: `@hw-verified`). (Esa, 2026-06-04: "@hw-untested needs
  to be added to every feature unless tested.")
- `@stock` scenarios are exempt — upstream IT behaviour was proven on hardware over
  two decades; the floor applies to FORK additions (`@shipped`).

So a freshly built fork feature is `@shipped @build-verified @hw-untested`; pressing
it in DOSBox adds `@runtime-verified` (and keeps `@hw-untested`); only a real-hardware
run earns `@hw-verified`.

## The one honest caveat

This is 16-bit TASM assembly with no test runner. Cucumber can't drive `IT.EXE`
directly, so these `.feature` files are *executable-in-principle* — either glued to a
DOSBox-X harness that scripts MIDI input and inspects state, or used as disciplined
human/LLM test scripts and session commands. The wiki value (persistent, compounding,
faithful, loadable-as-command) holds regardless of whether the automation glue is ever
written. The glue is the part that would need real work; the understanding-store is
useful on day one.

## Concrete next step

Convert the CLAUDE.md behavior tables — which are already wiki-shaped — into a
`features/` directory, one file per cluster, each scenario citing its source line and
the commit that shipped it. Start with `midi-realtime-sync.feature` since its behavior
table is the most complete. The schema (`CLAUDE.md`) already documents the conventions;
this just gives them a runnable, loadable home.
