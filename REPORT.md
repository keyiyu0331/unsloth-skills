# Unsloth Studio skills: model × skill report

Follow-up to the skills discussion on unslothai/unsloth#14181. I wrote two example skills (data/viz and general productivity) and tested them, plus the maintainer's `sandbox-scout`, on a small and a larger Gemma model.

## Skills

| Skill | What it does | Languages / libraries | Output |
|---|---|---|---|
| [`csv-dashboard`](skills/csv-dashboard/SKILL.md) | CSV or pasted table → KPI cards + line/bar charts | Python (stdlib `csv`, pandas optional), JSX with react + recharts | React preview (```` ```jsx ````) |
| [`regex-workbench`](skills/regex-workbench/SKILL.md) | Write a regex, test it against should-match / should-not lines, explain it | Python stdlib `re`, HTML | ```` ```html ```` match table |

## Setup

- **Models:** `unsloth/gemma-4-E4B-it-GGUF` (small) and `unsloth/gemma-4-12B-it-qat-GGUF` (larger), both UD-Q4_K_XL. 26B+ models don't fit a free T4.
- **Hardware:** Google Colab T4 (16 GB), Studio `main` via `studio/Unsloth_Studio_Colab.ipynb`, 2026-11-06.
- **Settings:** Thinking on, Search off, Tools on, run automatically, Studio's default context per model.
- **Skills enabled:** all 4 at once (`sandbox-scout`, `train-replay`, `csv-dashboard`, `regex-workbench`), so the model has to choose.
- **Prompts:** fixed, in [`samples/prompts.md`](samples/prompts.md). (a) is a natural request; (b) is the same request with `@skill-name`.

## Results

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

✅ yes · ⚠️ partial · ❌ no · – doesn't apply. \* includes time waiting on a tool approval. How each column is scored is in the [README](README.md#how-each-column-is-scored). Per-run notes, the earlier `csv-dashboard` v1 runs and a screenshot for every cell are in [`results/`](results/).

## Findings

Details and code references: [`results/findings.md`](results/findings.md).

1. **`sandbox-scout` step 4 can't run in current Studio (F1).** It says "Call render_html", but since #12804 the chat UI no longer requests the `render_html` tool. HTML renders from a ```` ```html ```` block instead. Neither model could follow the step: E4B put the verdict in plain text, and 12B wrote `report.html` to a file. Changing step 4 to "reply with one ```` ```html ```` block" should fix it. `regex-workbench` does it that way, and its table rendered on both models.
2. **The larger model never picked a skill unprompted (F5).** 12B used the skill 0 of 3 times on prompt (a); E4B did 2 of 3. All four descriptions fit in either catalog budget, so truncation doesn't explain it. On `csv-dashboard` (a), 12B made about 20 pandas calls writing CSVs, then said "I have created a dashboard" without making one. Once loaded with `@`, 12B followed the steps more closely than E4B, at about half the speed.
3. **The small model sometimes treats a skill as something to execute (F4).** On `regex-workbench` (a), E4B ran `$ regex-workbench` in the terminal, then said the tool "appears to be unavailable" and answered without the skill. On `sandbox-scout` (a), it called `read_skill(resource="sandbox-scout")`.
4. **Reference files are mostly skipped (F2).** `csv-dashboard` keeps its profiling script in `reference.md`; it was read in 2 of 5 runs where the skill was loaded. That supports skill-creator's existing advice to keep everything in SKILL.md.
5. **Smaller observations:**
   - After an `@` load, the models re-read SKILL.md in at least 3 of 6 runs, despite the "do not read an already loaded manifest again" instruction.
   - E4B broke a 723-character one-line JSON when copying it into JSX (F3). "Fix with the model" repaired it in one click, and printing the JSON over many lines prevented it.
   - In 5 of 6 dashboard summaries, the model called the revenue trend "upward" despite a March dip. The numbers on the dashboards were all correct.

## Sandbox inventory (Colab, from `sandbox-scout`)

- **Available:** Python 3.13.16, GCC/G++ 13.3.0, OpenJDK 21, Bash 5.2, Git 2.43, FFmpeg 6.1.1. numpy, pandas, matplotlib, scipy, scikit-learn, sympy, Pillow, requests, bs4, torch, networkx and duckdb all import.
- **Missing:** node, deno, bun, tsc, rustc, go, ruby, and the sqlite3 CLI.

## Proposed PRs

I'd be happy to open either, whichever is useful:

- **A. Ship `regex-workbench` as a bundled default skill** (`studio/backend/core/inference/bundled_skills/regex-workbench/SKILL.md`).
  - It uses only the Python stdlib and renders through the html block that works today.
  - Once loaded, both models produced a tested, correct match table.
  - Before the PR, I'd fix one slip both models made: they didn't escape the `<` in the pattern heading.
- **B. Add a line about visual output to the bundled `skill-creator`.** Something like: "If the skill should show a page, table or chart, reply with one ```` ```html ```` block, or a ```` ```jsx ```` block that exports a React component; don't tell the model to call a render tool." It currently says nothing on this, so skills that models write could hit the same problem as `sandbox-scout`.

## Limitations

- Two models from one family, one quantization, a T4 only.
- One run per cell: read the patterns across rows, not single cells.
- `csv-dashboard` was revised once during testing (v1 → v2, to fix F3); the table above shows v2 only.
