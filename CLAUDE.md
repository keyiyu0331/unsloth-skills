# Context for Claude Code: Unsloth Studio skills contribution

## Who and what
- Keyi Yu (GitHub `keyiyu0331`) is contributing to unslothai/unsloth. This is their second contribution; the first was a Studio UI fix.
- Fork: `keyiyu0331/unsloth`. On the Mac it is checked out at `~/unsloth`, with remotes `origin` (the fork) and `upstream`.
- **This repo** (`unsloth-skills`) holds the example skills, sample inputs, test prompts and results.

## The task (from the maintainer, on the unslothai/unsloth#14181 thread)
1. Write more example skills for Unsloth Studio and test their limits.
2. Build a **model × skill table** across several models and sizes, at least one small and one big. Columns: did it pick the skill, did the tools run, did the output render, which model did better or worse.
3. If something is broken, file an issue or PR on unslothai/unsloth and link it in the thread.
4. Share the skills collection. Good ones might ship as default skills, in `studio/backend/core/inference/bundled_skills/`.

**Already done by others, don't redo:**
- skill import/export (#14181)
- jonc04's `dataset-lint` skill
- the `read_skill` error fix (#15706)
- the maintainer's `sandbox-scout` and `train-replay` examples

pip install in the sandbox already works. Packages go to `<workdir>/.unsloth-packages`.

**Chosen focus:** data/viz skills and general-productivity skills.

## How Studio skills work (verified in the code, `~/unsloth/studio`)
- **Search paths:** `~/.agents/skills` → `~/.claude/skills` → bundled (`_skill_roots`, `backend/core/inference/skills.py`). Folders linked with symlinks are followed.
- **SKILL.md header** (YAML frontmatter):
  - `name` is required: `[a-z0-9-]`, at most 64 chars, and it **must equal the folder name**.
  - `description` is required, at most 1024 chars.
  - Optional fields: `compatibility` (≤500), `metadata` (string → string map), `allowed-tools` (informational only), `license`.
- **What the model sees:** a catalog with one line per skill, `- name: description`. It is capped at **1536 bytes for models under 9B** and 4096 otherwise, so descriptions get cut off when many skills are enabled.
- **`read_skill(name, resource="SKILL.md", offset)`** reads files page by page. It **never runs scripts**, so code must be inlined or read and then run through the `python` tool.
- **`@skill-name`** in the user message force-loads the full SKILL.md (`skill_mentions.py`).
- **Tools:**
  - `python` and `terminal`: run in a sandbox with a 300 s timeout and a persistent working folder per chat. The network is open.
  - `render_html`: NOT available from the Studio UI since #12804 (Canvas removed). The UI never puts it in `enabled_tools`. HTML renders from a ```` ```html ```` block in the reply instead.
  - A ```` ```jsx ```` / ```` ```tsx ```` block in the reply is compiled into a React preview. It must `export default` a component (or define `App`). The only importable packages are react, recharts, lucide-react, motion/framer-motion, plus Tailwind classes.

## Where things run
- **Mac:** Claude Code, the unsloth fork (bug-fix PRs), and editing skills in this repo.
- **Stanford FarmShare:** runs Studio on a GPU.
  - Login: `login.farmshare.stanford.edu` (password + Duo, no SSH keys).
  - GPU: `salloc -p gpu --gpus=1 --time=...`.
  - Storage: `HF_HOME=/scratch/users/$USER/hf`.
  - Start Studio with `unsloth studio --secure -H 0.0.0.0 -p 8888`.
  - Open it from the Mac with `ssh -N -L 8888:<node>:8888 farmshare`.
  - Skills are linked into `~/.agents/skills` there (see the README install section).

## Layout
- `skills/<name>/SKILL.md` (+ `reference.md`): one folder per skill. Every SKILL.md has a `## Libraries` table.
- `samples/`: fixed inputs. `samples/prompts.md` has the exact test prompts, (a) natural and (b) `@skill`.
- `results/results.csv`: one row per run. Use y / n / partial / wrong / na in the score columns. Each row's `evidence` column holds the path to a screenshot or chat export.
- `scripts/make_table.py`: CSV → markdown table.

## Plan / status
- [x] Repo scaffold; `csv-dashboard` and `regex-workbench` written
- [x] FarmShare scripts written (`farmshare/`: studio.sbatch auto-starts Studio + emails on start, prefetch_models.sh)
- [ ] FarmShare setup (GPUs were busy on 2026-11-06; switched to Google Colab T4 using studio/Unsloth_Studio_Colab.ipynb plus a skills cell); run `sandbox-scout` to record the libraries available there
- [ ] Test those 2 skills on 1 small model (e.g. gemma-4-E4B) and 1 big model; adjust the protocol
- [ ] Write `jsonl-dataset-stats`, `git-log-digest`, `unit-and-date-calc`, `pip-then-plot`
- [ ] Run the full table: ≥4 models, both prompt types, all skills enabled together
- [ ] Limit probes:
  - catalog truncation with 15+ skills on a <9B model
  - reading the reference file
  - two `render_html` calls in one reply
  - pip install
  - the 300 s timeout
- [ ] File issues/PRs for bugs (branch off an up-to-date `main` in the fork; title prefix `Studio:`; add tests)
- [ ] Publish this repo; post the summary, table and links on #14181; nominate 1–2 default skills

## Where we left off (2026-11-06)
- Testing on Colab T4, model gemma-4-E4B-it UD-Q4_K_XL, Thinking on, Search off, Approve-for-me on, 4 skills enabled.
- Done for E4B: sandbox-scout (a); csv-dashboard (a) and (b) on v1 and v2.
- Still to do for E4B: sandbox-scout (b), regex-workbench (a) and (b). Stats (total/tokens) are missing for the two csv-dashboard v2 rows.
- Larger model: unsloth/gemma-4-12b-it-GGUF UD-Q4_K_XL (plain, NOT the QAT repo; loaded by mistake but kept for all 12B runs so they stay comparable). Only two models due to time: E4B (small) vs 12B (larger). 26B+ does not fit a T4.
- Findings so far: F1, F2 and F3 in results/findings.md.

## Restarting Colab (everything there is wiped between sessions)
1. Runtime → Change runtime type → T4 GPU.
2. Run the setup cell.
3. Upload sandbox-scout.zip and train-replay.zip to /content.
4. Run the skills cell: git clone this repo, symlink skills/* into ~/.agents/skills, then run the zip-install Python cell.
5. Run start(). Use the new Cloudflare link and login.
6. To update the skills while Studio is running, use Colab's Terminal: `cd /content/unsloth-skills && git pull`.

## Skill revisions
- `v1`: first versions, used for the first E4B runs.
- `csv-dashboard` `v2`: the profiling script prints a ready-to-paste multi-line `const DATA = ...;` (fix for F3).
- `regex-workbench` `v2`: html code block instead of render_html (F1). Was never run on v1.
- Record the revision in the `skill_rev` column of `results.csv`. Compare models only on the same revision.

## Conventions
- Skill bodies should be short numbered checklists that name exact tools; small models follow these best.
- Never invent results in the table. Every cell must have evidence.
