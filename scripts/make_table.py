"""Turn results/results.csv into the markdown model x skill table for the README / GitHub thread.

Usage: python scripts/make_table.py [results/results.csv]

Cells in the score columns are written as y / n / partial (or wrong for picked_skill)
and are shown as emoji.
"""
import csv
import sys
from pathlib import Path

ICON = {"y": "✅", "yes": "✅", "n": "❌", "no": "❌", "partial": "⚠️", "wrong": "🔀", "": "–", "na": "–"}
SCORE_COLS = ["picked_skill", "read_skill_ok", "read_reference", "tools_ran", "libs_ok", "rendered"]


def icon(v: str) -> str:
    return ICON.get(v.strip().lower(), v)


def main() -> None:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else Path(__file__).parent.parent / "results" / "results.csv")
    with path.open(newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        print("No results yet.")
        return
    rows.sort(key=lambda r: (r["skill"], float(r["params_b"] or 0), r["model"], r["prompt"]))
    head = ["Skill", "Model", "Quant", "Prompt", "Picked", "read_skill", "Ref file", "Tools ran", "Libs", "Rendered", "Secs", "Tok/s", "Notes"]
    print("| " + " | ".join(head) + " |")
    print("|" + "---|" * len(head))
    for r in rows:
        cells = [r["skill"], r["model"], r["quant"], r["prompt"]]
        cells += [icon(r[c]) for c in SCORE_COLS]
        cells += [r["seconds"], r.get("tok_s", ""), r["notes"].replace("|", "\\|")]
        print("| " + " | ".join(cells) + " |")


if __name__ == "__main__":
    main()
