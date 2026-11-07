# Unsloth Studio example skills

Example [Agent Skills](https://unsloth.ai/docs/new/studio/) for Unsloth Studio, plus a model × skill evaluation. The evaluation asks: did the model pick the skill, did the tools and libraries run, and did the output render?

Context: unslothai/unsloth#14181 (comment thread on testing custom skills).

## Skills

| Skill | What it does | Languages | Libraries | Output |
|---|---|---|---|---|
| [`csv-dashboard`](skills/csv-dashboard/SKILL.md) | CSV → dashboard with KPI cards and charts | Python, JSX | pandas or stdlib csv, react, recharts | React preview |
| [`regex-workbench`](skills/regex-workbench/SKILL.md) | Write, test and explain a regex, with a match table | Python, HTML | stdlib `re` | html code block (Studio renders it) |

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

See [`results/results.csv`](results/results.csv).

### How each column is scored

Values: `y` ✅, `partial` ⚠️, `n` ❌, `wrong` 🔀 (picked a different skill), `na` – (doesn't apply).

| Column | `y` | `partial` | `n` |
|---|---|---|---|
| `picked_skill` | called `read_skill` on the right skill unprompted (prompt a), or loaded it via `@` (prompt b) | read it only after a nudge | never read it (`wrong` = read a different skill) |
| `read_skill_ok` | `read_skill` calls succeeded | some calls errored or asked for files that don't exist | every call failed |
| `read_reference` | read the skill's extra file when the steps point to it | read it late, or asked for a non-existent file | skipped it (`na` if the skill has none) |
| `tools_ran` | the python/terminal calls ran without errors | some errors, which the model recovered from | errors it never recovered from, or no tool calls when the skill needs them |
| `libs_ok` | every library/runtime the skill uses was available, or pip installed it | a fallback was needed | a needed library was missing and the run failed |
| `rendered` | the visual output the skill asks for appeared and shows the real data | something appeared but is broken or off-spec: blank or errored preview, missing charts, HTML/JSX shown as code instead of rendered, made-up numbers, or a different format from the one asked | no visual at all, although the skill requires one (`na` if the skill only asks for text) |

Expected visual output per skill: `sandbox-scout` → `render_html` card grid (impossible in current Studio, see F1) · `train-replay` → React dashboard · `csv-dashboard` → React (```` ```jsx ````) dashboard · `regex-workbench` → ```` ```html ```` match table.

To generate the table:

```bash
python scripts/make_table.py
```

_Table goes here._
