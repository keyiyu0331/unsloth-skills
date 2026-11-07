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
