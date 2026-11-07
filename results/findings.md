# Findings

Observations from the model × skill runs that may lead to skill fixes, issues or PRs.
Each finding lists the runs that show it. Only promote a finding to an issue after it shows up on more than one model, or with a clear Studio-side cause.

## F1: The small model treats a skill as a callable function and skips its steps

- **Seen in:** gemma-4-E4B-it UD-Q4_K_XL, `sandbox-scout` prompt (a), Colab T4, 2026-11-06.
- **What happened:**
  1. The model read `SKILL.md` correctly.
  2. Its reasoning then said: "I should now use the actual `sandbox-scout` skill (which is available as a function…)". It also said step 4 `render_html` was "implicitly done by the skill implementation".
  3. It called `read_skill(name="sandbox-scout", resource="sandbox-scout")`, which returned `Error: Skill resource 'sandbox-scout' was not found.`
  4. It ran steps 1–3 and 5 itself, but never called `render_html`.
- **Why it matters:** it confuses "skill" (instructions the model must carry out) with "tool" (something that runs for it). Any step the model believes the skill does "for it" gets skipped.
- **Possible fixes, still to evaluate:**
  - (a) Skill wording: "You must perform every step yourself; this skill is instructions, not a function."
  - (b) Studio: the skill guidance in `_skill_tool_tip` (`studio/backend/routes/inference.py`) could say this once for all skills.
  - (c) Studio: the `read_skill` "not found" error could list the skill's real files, so the model can recover.
- **Next:** check whether gemma-4-12B and Qwen3.5-4B do the same. If more than one model does, (b) and (c) are PR candidates.

## F2: The small model skips the skill's reference file and writes its own code

- **Seen in:** gemma-4-E4B-it, `csv-dashboard` prompt (a).
- **What happened:** step 2 of SKILL.md says to run the profiling script in `reference.md`. The model never called `read_skill(resource="reference.md")`. It wrote its own `csv` + pandas script instead, and the dashboard still came out correct.
- **Why it matters:**
  - Multi-file skills only help if the model opens the files they point to.
  - Here SKILL.md alone was enough, which suggests short skills with inlined essentials hold up better on small models.
  - It also means the template's styling and the column-guessing logic were ignored.
- **Next:** check whether bigger models read `reference.md`, and whether the `@csv-dashboard` prompt (b) changes this. If small models never open extra files, the skill-writing advice is: inline anything critical in SKILL.md.

## F3: Copying a long one-line JSON into the jsx block breaks the compile

- **Seen in:** gemma-4-E4B-it, `csv-dashboard` prompt (b).
- **What happened:** the model followed the template exactly, but the React preview reported `Compile error at line 4, column 722: Unexpected token`. Line 4 is `const DATA = {...}`, which the model retyped from the Python output as a single line of 700+ characters.
- **Cause:** pending. Need the exact text of line 4: a transcription slip, a truncation, or a value that isn't valid JS.
- **Possible skill fix:** have the profiling script print the finished `const DATA = ...;` line, pretty-printed over several lines, so the model copies short lines instead of one huge one. Or have it print the whole jsx block, so the model only copies text.
- **Studio side:** the error card offers "Fix with the model". Note whether that recovers.

## Sandbox inventory (Colab T4, Studio main, 2026-11-06)

- **Works:**
  - Python 3.13.16
  - GCC/G++ 13.3.0
  - OpenJDK 21.0.12.1
  - Bash 5.2.21
  - Git 2.43.0
  - FFmpeg 6.1.1
- **Missing:** node, deno, bun, tsc, rustc, go, ruby, sqlite3 CLI.
- **Python libraries (all imported OK):**
  - numpy 2.4.6, pandas 2.3.3, matplotlib 3.10.9, scipy 1.16.3
  - scikit-learn 1.7.1, sympy 1.14.0, Pillow 11.3.0, requests 2.32.4
  - beautifulsoup4 4.13.5, torch 2.14.1+cu130, networkx 3.7
  - duckdb imported (no 'Not found' line), but the model's script never printed its version.
- **Takeaway for the skills:** the Python data stack is safe to rely on. Anything needing Node, Go or Rust inside the sandbox is not.
