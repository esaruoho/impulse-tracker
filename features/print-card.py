#!/usr/bin/env python3
"""print-card.py — turn a report-card .feature into two printable outputs.

For each input .feature (the comment-wrapped report card), emit into
features/dist/:

  <name>.gherkin.feature   the PURE Gherkin test: the top banner-comment block
                           is stripped, leaving Feature/Scenario/Given-When-Then
                           (inline `# cite:` traceability comments kept). This is
                           the file a Gherkin runner would consume.

  <name>.card.md           the printable REPORT CARD: feature title + narrative,
                           then every scenario with its grade tags and steps,
                           plus a grade tally. Render to RTF with `rtfc` to print
                           or paste into Mail/Pages.

It also generates a browsable feature reference:

  features/README.md       one section per card — "what it does" (the Feature
                           intent + behaviour scenarios) and "how it does it"
                           (the procs + source files the behaviour is cited to),
                           with grade + commits. Generated, not hand-edited.

Usage:
  python3 features/print-card.py features/wav-render-reentry-guard.feature [...]
  python3 features/print-card.py --all      # per-card dist/ outputs for every card
  python3 features/print-card.py --readme   # regenerate features/README.md

No dependencies — Apple-native python3. No regex backtracking risk: plain
prefix/string matching only.
"""
import sys
import os

FEATURES_DIR = os.path.dirname(os.path.abspath(__file__))
DIST_DIR = os.path.join(FEATURES_DIR, "dist")

GRADE_TAGS = (
    "@shipped", "@build-verified", "@runtime-verified", "@runtime-untested",
    "@designed", "@built", "@sim-verified", "@hw-verified", "@untested",
    "@todo", "@stock", "@partial",
)


def split_banner(lines):
    """Return (banner_lines, body_lines). Banner = leading block of `#`/blank
    lines before the first `Feature:` line."""
    body_start = 0
    for i, ln in enumerate(lines):
        if ln.lstrip().startswith("Feature:"):
            body_start = i
            break
    return lines[:body_start], lines[body_start:]


def parse_scenarios(body):
    """Yield dicts: {tags:[...], title:str, steps:[str], cites:[str]}."""
    scenarios = []
    pending_tags = []
    cur = None
    for raw in body:
        s = raw.strip()
        if s.startswith("@"):
            pending_tags = [t for t in s.split() if t.startswith("@")]
            continue
        if s.startswith("Scenario:"):
            if cur:
                scenarios.append(cur)
            cur = {"tags": pending_tags, "title": s[len("Scenario:"):].strip(),
                   "steps": [], "cites": []}
            pending_tags = []
            continue
        if cur is None:
            continue
        if s.startswith("# cite:"):
            cur["cites"].append(s[len("# cite:"):].strip())
            continue
        if s.startswith("#") or s == "":
            continue
        # a step line (Given/When/Then/And/But or a continuation)
        cur["steps"].append(s)
    if cur:
        scenarios.append(cur)
    return scenarios


def feature_title_and_narrative(body):
    title = ""
    narrative = []
    for ln in body:
        s = ln.strip()
        if s.startswith("Feature:"):
            title = s[len("Feature:"):].strip()
            continue
        if title and (s.startswith("@") or s.startswith("Scenario:")):
            break
        if title and s and not s.startswith("#"):
            narrative.append(s)
    return title, narrative


def grade_of(tags):
    g = [t for t in tags if t in GRADE_TAGS]
    return g


def write_gherkin(name, banner, body):
    out = os.path.join(DIST_DIR, name + ".gherkin.feature")
    # strip leading blank lines from body
    b = list(body)
    while b and b[0].strip() == "":
        b.pop(0)
    header = (
        "# Pure Gherkin test extracted from features/%s.feature\n"
        "# (report-card banner stripped; inline # cite: traceability kept)\n"
        "# Regenerate: python3 features/print-card.py features/%s.feature\n\n"
        % (name, name)
    )
    with open(out, "w") as f:
        f.write(header)
        f.writelines(b)
    return out


def write_card(name, body):
    title, narrative = feature_title_and_narrative(body)
    scenarios = parse_scenarios(body)
    tally = {}
    for sc in scenarios:
        for g in grade_of(sc["tags"]):
            tally[g] = tally.get(g, 0) + 1
    out = os.path.join(DIST_DIR, name + ".card.md")
    L = []
    L.append("# Report Card — %s\n" % title)
    L.append("> Source: `features/%s.feature` · printable rendering · "
             "regenerate with `python3 features/print-card.py`\n" % name)
    if narrative:
        L.append("**Intent:** " + " ".join(narrative) + "\n")
    if tally:
        L.append("**Grades:** " +
                 " · ".join("%s × %d" % (g, n) for g, n in sorted(tally.items())) +
                 "\n")
    L.append("**Scenarios: %d**\n" % len(scenarios))
    L.append("\n---\n")
    for i, sc in enumerate(scenarios, 1):
        gr = " ".join(sc["tags"]) if sc["tags"] else "(ungraded)"
        L.append("\n## %d. %s\n" % (i, sc["title"]))
        L.append("`%s`\n" % gr)
        if sc["steps"]:
            L.append("")
            for st in sc["steps"]:
                L.append("- %s" % st)
            L.append("")
        if sc["cites"]:
            L.append("<sub>cite: " + " · ".join(sc["cites"]) + "</sub>\n")
    with open(out, "w") as f:
        f.write("\n".join(L) + "\n")
    return out


def process(path):
    name = os.path.splitext(os.path.basename(path))[0]
    with open(path) as f:
        lines = f.readlines()
    banner, body = split_banner(lines)
    g = write_gherkin(name, banner, body)
    c = write_card(name, body)
    return g, c


# ---------------------------------------------------------------------------
# README generation: turn every card into a "what it does + how it does it"
# entry, sourced straight from the report card.
# ---------------------------------------------------------------------------

def _is_hex7(tok):
    return len(tok) >= 7 and all(c in "0123456789abcdef" for c in tok[:7].lower())


def extract_watch(banner):
    """The procs/symbols the card watches (its 'how' surface)."""
    for ln in banner:
        s = ln.strip()
        if s.startswith("#") and "WATCH:" in s:
            return s.split("WATCH:", 1)[1].strip().split()
    return []


def extract_commits(banner):
    """(hash, desc) pairs: any banner comment line whose first token is a
    7-hex commit hash (covers the 'Commit log' block)."""
    out = []
    seen = set()
    for ln in banner:
        body = ln.strip().lstrip("#").strip()
        toks = body.split()
        if toks and _is_hex7(toks[0]) and toks[0] not in seen:
            seen.add(toks[0])
            out.append((toks[0], " ".join(toks[1:])))
    return out


def extract_files(scenarios):
    """Distinct source files named in the scenario cites (the 'how' innards)."""
    files = []
    for sc in scenarios:
        for c in sc["cites"]:
            for tok in c.replace(",", " ").split():
                up = tok.upper()
                if (up.endswith(".ASM") or up.endswith(".INC")) and tok not in files:
                    files.append(tok)
    return files


def build_readme(paths):
    behaviour, meta = [], []
    for p in sorted(paths):
        name = os.path.splitext(os.path.basename(p))[0]
        with open(p) as f:
            lines = f.readlines()
        banner, body = split_banner(lines)
        title, narrative = feature_title_and_narrative(body)
        scenarios = parse_scenarios(body)
        tally = {}
        for sc in scenarios:
            for g in grade_of(sc["tags"]):
                tally[g] = tally.get(g, 0) + 1
        rec = {
            "name": name, "title": title or name, "narrative": narrative,
            "scenarios": scenarios, "tally": tally,
            "watch": extract_watch(banner), "commits": extract_commits(banner),
            "files": extract_files(scenarios),
            "has_session": os.path.exists(
                os.path.join(FEATURES_DIR, name + ".session.md")),
        }
        (meta if name.startswith(("session-", "day-")) else behaviour).append(rec)

    L = []
    L.append("# Impulse Tracker (esaruoho fork) — Feature Reference\n")
    L.append("> **Generated** from the Gherkin report cards in this folder by "
             "`python3 features/print-card.py --readme`. Do not hand-edit — edit "
             "the `.feature` card and regenerate. Each entry below = one card: "
             "*what it does* (the feature intent + behaviour scenarios) and "
             "*how it does it* (the procs/files the behaviour is cited to).\n")
    L.append("Each card is a triad: the `.feature` spec, a `.session.md` (the "
             "conversation that produced it), and a RESULT-LOG of what shipped. "
             "See `GHERKIN-FEATURE-WIKI-PATTERN.md` and `INDEX.md`.\n")

    # Contents
    L.append("## Contents\n")
    for rec in behaviour:
        anchor = rec["name"]
        L.append("- [%s](#%s) — `%s.feature`" % (rec["title"], anchor, rec["name"]))
    L.append("")

    def emit(rec):
        L.append('\n<a id="%s"></a>' % rec["name"])
        L.append("## %s\n" % rec["title"])
        src = "`features/%s.feature`" % rec["name"]
        if rec["has_session"]:
            src += " · [session](%s.session.md)" % rec["name"]
        L.append("%s\n" % src)
        if rec["narrative"]:
            L.append("**What it does:** " + " ".join(rec["narrative"]) + "\n")
        if rec["scenarios"]:
            L.append("**Behaviour (%d scenario%s):**\n" %
                     (len(rec["scenarios"]), "" if len(rec["scenarios"]) == 1 else "s"))
            for sc in rec["scenarios"]:
                tags = " ".join(t for t in sc["tags"] if t in GRADE_TAGS)
                L.append("- %s%s" % (sc["title"], (" — `%s`" % tags) if tags else ""))
            L.append("")
        how = []
        if rec["watch"]:
            how.append("**Key procs:** " + ", ".join("`%s`" % w for w in rec["watch"]))
        if rec["files"]:
            how.append("**Source files:** " + ", ".join("`%s`" % f for f in rec["files"]))
        if how:
            L.append("**How it does it:** " + " · ".join(how) + "\n")
        if rec["tally"]:
            L.append("**Grade:** " +
                     " · ".join("%s ×%d" % (g, n) for g, n in sorted(rec["tally"].items())) + "\n")
        if rec["commits"]:
            L.append("**Commits:** " +
                     " · ".join("`%s` %s" % (h, d) for h, d in rec["commits"][:12]) + "\n")

    for rec in behaviour:
        emit(rec)

    if meta:
        L.append("\n---\n")
        L.append("## Meta / session cards\n")
        L.append("These document the report-card *process* itself, not a tracker "
                 "behaviour.\n")
        for rec in meta:
            L.append("- **%s** — `features/%s.feature`%s" %
                     (rec["title"], rec["name"],
                      " · [session](%s.session.md)" % rec["name"] if rec["has_session"] else ""))
        L.append("")

    out = os.path.join(FEATURES_DIR, "README.md")
    with open(out, "w") as f:
        f.write("\n".join(L) + "\n")
    return out, len(behaviour), len(meta)


def all_feature_paths():
    return [os.path.join(FEATURES_DIR, f) for f in sorted(os.listdir(FEATURES_DIR))
            if f.endswith(".feature")]


def main(argv):
    args = argv[1:]
    if not args:
        print(__doc__)
        return 1
    if "--readme" in args:
        out, nb, nm = build_readme(all_feature_paths())
        print("wrote %s" % os.path.relpath(out, FEATURES_DIR))
        print("   %d behaviour cards, %d meta/session cards" % (nb, nm))
        args = [a for a in args if a != "--readme"]
        if not args:
            return 0
    if args == ["--all"]:
        args = all_feature_paths()
    os.makedirs(DIST_DIR, exist_ok=True)
    for p in args:
        if not os.path.exists(p):
            print("skip (not found): %s" % p)
            continue
        g, c = process(p)
        print("%s" % os.path.basename(p))
        print("   -> %s" % os.path.relpath(g, FEATURES_DIR))
        print("   -> %s" % os.path.relpath(c, FEATURES_DIR))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
