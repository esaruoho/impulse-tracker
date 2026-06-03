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

Usage:
  python3 features/print-card.py features/wav-render-reentry-guard.feature [...]
  python3 features/print-card.py --all      # every features/*.feature

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


def main(argv):
    args = argv[1:]
    if not args:
        print(__doc__)
        return 1
    if args == ["--all"]:
        args = [os.path.join(FEATURES_DIR, f) for f in sorted(os.listdir(FEATURES_DIR))
                if f.endswith(".feature")]
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
