# Unsloth Studio example skills

Example [Agent Skills](https://unsloth.ai/docs/new/studio/) for Unsloth Studio, plus a model × skill evaluation. The evaluation asks: did the model pick the skill, did the tools and libraries run, and did the output render?

Context: unslothai/unsloth#14181 (comment thread on testing custom skills).

## Skills

| Skill | What it does | Languages | Libraries | Output |
|---|---|---|---|---|
| [`csv-dashboard`](skills/csv-dashboard/SKILL.md) | CSV → dashboard with KPI cards and charts | Python, JSX | pandas or stdlib csv, react, recharts | React preview |
| [`regex-workbench`](skills/regex-workbench/SKILL.md) | Write, test and explain a regex, with a match table | Python, HTML | stdlib `re` | `render_html` canvas |

More are planned: `jsonl-dataset-stats`, `git-log-digest`, `unit-and-date-calc`, `pip-then-plot`.

## Install

Studio reads skills from `~/.agents/skills/<name>/SKILL.md`. Clone this repo and link each skill into that folder:

```bash
git clone https://github.com/keyiyu0331/unsloth-skills ~/unsloth-skills
mkdir -p ~/.agents/skills
for d in ~/unsloth-skills/skills/*/; do ln -sfn "$d" ~/.agents/skills/$(basename "$d"); done
```

Or zip a skill folder and use **Manage skills → Import** in Studio.

## Results

See [`results/results.csv`](results/results.csv). To generate the table:

```bash
python scripts/make_table.py
```

_Table goes here._
