# Findings

Observations from the model × skill runs that may lead to skill fixes, issues or PRs.
Each finding lists the runs that show it. Only promote a finding to an issue after it shows up on more than one model, or with a clear Studio-side cause.

## F1: Skills that call `render_html` can't work, because Studio no longer offers that tool

- **Seen in:** gemma-4-E4B-it, `sandbox-scout` prompts (a) and (b). In both runs step 4 (`render_html` card grid) never happened.
- **Root cause (verified in code, upstream main 41da0b13f2):**
  - The chat UI sends an explicit `enabled_tools` list. With Tools on, that list is `python, terminal, edit_file, view_image` plus skill and browser tools (`studio/frontend/src/features/chat/api/code-tool-placement.ts:35`, `chat-adapter.ts`).
  - The backend filters `ALL_TOOLS` by that list (`studio/backend/routes/inference.py`, `tools = [t for t in ALL_TOOLS if ... in payload.enabled_tools]`). So `render_html` is never in the model's tools.
  - Commit 6a1ca4315d, "Studio: open chat HTML in the Browser and remove Canvas" (#12804, 2026-10-06), removed Canvas mode and the render_html prompt. HTML now renders from an ```` ```html ```` code block in the reply.
- **What the model did:**
  - In (a) it rationalised the missing tool: it said render_html was "implicitly done by the skill implementation" and tried to call the skill as a function, which produced `Error: Skill resource 'sandbox-scout' was not found.`
  - In (b) it silently put the verdict in the text.
  - Both are reasonable reactions to an instruction that names a tool it doesn't have.
- **Impact:** the maintainer's example `sandbox-scout` (and possibly `train-replay`) still says "Call render_html". Any community skill written from those examples will hit this.
- **Fixes:**
  - (a) Skills: replace "call render_html" with "reply with one ```` ```html ```` code block". Done in regex-workbench v2. Suggest the same for sandbox-scout upstream.
  - (b) Studio, issue/PR candidate: `render_html` is still in `ALL_TOOLS` and the backend nudge text, but the UI can't enable it. Either drop it from the backend, or have `read_skill` / the skill tip tell the model that HTML renders from an ```` ```html ```` block.
  - (c) Studio: the `read_skill` "not found" error could list the skill's real files, so the model can recover. A minor, separate issue.

## F2: The small model skips the skill's reference file and writes its own code

- **Seen in:** gemma-4-E4B-it, `csv-dashboard` prompt (a), on both v1 and v2. With the `@` mention (prompt b) it read `reference.md` both times.
- **What happened:** step 2 of SKILL.md says to run the profiling script in `reference.md`. The model never called `read_skill(resource="reference.md")`. It wrote its own `csv` + pandas script instead, and the dashboard still came out correct.
- **Why it matters:**
  - Multi-file skills only help if the model opens the files they point to.
  - Here SKILL.md alone was enough, which suggests short skills with inlined essentials hold up better on small models.
  - It also means the template's styling and the column-guessing logic were ignored.
- **Next:** check whether bigger models read `reference.md`, and whether the `@csv-dashboard` prompt (b) changes this. If small models never open extra files, the skill-writing advice is: inline anything critical in SKILL.md.

## F3: Copying a long one-line JSON into the jsx block breaks the compile

- **Seen in:** gemma-4-E4B-it, `csv-dashboard` prompt (b).
- **What happened:** the model followed the template exactly, but the React preview reported `Compile error at line 4, column 722: Unexpected token`. Line 4 is `const DATA = {...}`, which the model retyped from the Python output as a single line of 700+ characters.
- **Cause (confirmed):** the data was copied correctly, but the line ends `}}};` where it should end `}};`: one extra closing brace, exactly at column 722 of the 723-character line. Removing it makes the line valid. This is a transcription slip on a very long line.
- **Skill fix applied in csv-dashboard v2:** the script now prints the finished `const DATA = {...};` block, pretty-printed over about 80 short lines and ending in `};`. SKILL.md says to copy it exactly, without adding or removing brackets.
- **Result:** E4B prompt (b) on v2 rendered correctly on the first try. Prompt (a) on v2 never reached the fix, because the model skipped `reference.md` again (F2). It still rendered, with its own hand-typed data.
- **Studio side:** the error card's "Fix with the model" button recovered it. After one click the dashboard rendered. So Studio's repair loop handles this class of slip well; the v2 skill fix aims to avoid the error in the first place.

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
