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

### Setup

- **Models:** `unsloth/gemma-4-E4B-it-GGUF` (small) and `unsloth/gemma-4-12B-it-qat-GGUF` (larger), both UD-Q4_K_XL. Larger models (26B+) don't fit a free T4.
- **Hardware:** Google Colab T4 (16 GB), Studio from `main` via `studio/Unsloth_Studio_Colab.ipynb`, 2026-11-06.
- **Settings:** Thinking on, Search off, Tools on, run automatically, Studio's default context per model (131072 for E4B, 262144 for 12B).
- **Skills enabled:** all 4 at once (`sandbox-scout`, `train-replay`, `csv-dashboard`, `regex-workbench`), so the model has to choose.
- **Prompts:** fixed, in [`samples/prompts.md`](samples/prompts.md). (a) is a natural request; (b) is the same with `@skill-name`.
- **One run per cell.** Treat single cells as anecdotes and the patterns across rows as the result.

### Table (current skill revisions)

| Skill | Model | Prompt | Picked | read_skill | Ref file | Tools ran | Libs | Rendered | Secs | Tok/s |
|---|---|---|---|---|---|---|---|---|---|---|
| csv-dashboard | E4B | a | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | 58 | 70.9 |
| csv-dashboard | E4B | b | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 70 | 75.2 |
| csv-dashboard | 12B | a | ❌ | – | – | ⚠️ | ✅ | ❌ | 195 | 36.4 |
| csv-dashboard | 12B | b | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | 69 | 41.1 |
| regex-workbench | E4B | a | ❌ | – | – | ⚠️ | – | ⚠️ | 23 | 80.3 |
| regex-workbench | E4B | b | ✅ | ✅ | – | ✅ | ✅ | ✅ | 317* | 69.9 |
| regex-workbench | 12B | a | ❌ | – | – | ✅ | – | ⚠️ | 47 | 40.4 |
| regex-workbench | 12B | b | ✅ | ✅ | – | ✅ | ✅ | ✅ | 153 | 40.3 |
| sandbox-scout | E4B | a | ✅ | ⚠️ | – | ✅ | ✅ | ❌ | 55 | 71.2 |
| sandbox-scout | E4B | b | ✅ | ✅ | – | ✅ | ✅ | ❌ | 46 | 62.5 |
| sandbox-scout | 12B | a | ❌ | – | – | ✅ | ✅ | ❌ | 50 | 34.4 |
| sandbox-scout | 12B | b | ✅ | ✅ | – | ✅ | ✅ | ⚠️ | 256 | 39.3 |

\* Includes time waiting for a tool approval. Earlier `csv-dashboard` v1 runs, the per-run notes and the evidence paths are in [`results/results.csv`](results/results.csv). `python scripts/make_table.py` prints the full table.

### What it shows

- **Picking a skill unprompted:** E4B 2 of 3, 12B 0 of 3. 12B gets the larger catalog budget, and all 4 descriptions fit either way, so catalog size doesn't explain it. On `regex-workbench` (a), E4B tried to run the skill as a shell command (`$ regex-workbench`) instead of reading it (F4, F5).
- **Following a loaded skill:** with `@`, both models ran their tools and every run on a current revision produced its output, except `sandbox-scout`, whose `render_html` step is impossible (F1). 12B followed the steps more closely (correct colours, no stray re-read on regex); E4B was about twice as fast.
- **Extra files:** `reference.md` was read in 2 of 5 `csv-dashboard` runs where the skill was loaded. Put anything critical in SKILL.md itself (F2).
- **Long literals:** E4B broke a 723-character one-line JSON when copying it into JSX; printing it pretty over many lines fixed it (F3).
- **Summaries:** both models called the revenue "upward/growth" despite the March dip in 5 of 6 `csv-dashboard` summaries. The numbers on the dashboards were all correct.

Details and code references: [`results/findings.md`](results/findings.md).
