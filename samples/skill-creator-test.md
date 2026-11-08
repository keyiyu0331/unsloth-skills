# skill-creator before/after test (for PR B)

**Question:** when Studio writes a new skill with the bundled `skill-creator`, does that skill show its page, table or chart in the chat? We test this before and after adding one sentence about html/jsx blocks to skill-creator.

## Setup

- Notebook: https://colab.research.google.com/github/unslothai/unsloth/blob/main/studio/Unsloth_Studio_Colab.ipynb (Runtime → T4 GPU).
- Model: `unsloth/gemma-4-12B-it-qat-GGUF`, UD-Q4_K_XL. Thinking on, Search off, Tools on, Run automatically.
- Do **not** install the unsloth-skills repo this time. In the Skills menu, only `skill-creator` should be on.
- New chat for every prompt.

## Round 1: BEFORE (skill-creator as shipped)

For each prompt below, do steps 1–4:
1. Send the **create** prompt. The model should call `create_skill`.
2. In the Colab Terminal, print the new skill: `cat ~/.agents/skills/<name>/SKILL.md`. Copy the output, or screenshot it.
3. In a **new chat**, send the **use** prompt with the sample input.
4. Screenshot the tool steps, the result (did a chart/page/table appear in the chat?) and the stats panel.

### P1: chart
- Create: `@skill-creator Make a skill called csv-chart-before that turns a pasted CSV into a chart I can see in the chat.`
- Use: `@csv-chart-before` + the contents of `samples/sales.csv`.

### P2: page
- Create: `@skill-creator Make a skill called todo-page-before that shows my to-do list as a nicely formatted page.`
- Use: `@todo-page-before` + this list:
  ```
  - Finish skills report (high, due Mon)
  - Reply to maintainer on Discord (medium, due Tue)
  - Restart Colab and run tests (high, due today)
  - Clean up Desktop screenshots (low)
  ```

### P3: table
- Create: `@skill-creator Make a skill called json-diff-before that compares two JSON objects and shows the differences as a table.`
- Use: `@json-diff-before` + these two:
  ```
  A: {"model": "gemma-4-E4B", "quant": "Q4_K_XL", "context": 131072, "thinking": true, "tools": ["python", "terminal"]}
  B: {"model": "gemma-4-12B-qat", "quant": "Q4_K_XL", "context": 262144, "thinking": true, "tools": ["python"], "search": false}
  ```

## Apply the change (Colab Terminal, Studio keeps running)

```bash
python3 - <<'EOF'
p = "/content/unsloth/studio/backend/core/inference/bundled_skills/skill-creator/SKILL.md"
s = open(p).read()
old = "Do not include secrets, credentials, or machine-specific paths."
new = old + " If the skill should show a page, table or chart in the chat, tell the model to reply with one fenced `html` code block, or a `jsx` block that `export default`s a React component using react, recharts, lucide-react, motion or Tailwind, instead of saving an image or file. Unsloth renders those blocks in the chat."
assert s.count(old) == 1, "step 5 text not found"
open(p, "w").write(s.replace(old, new))
print("patched")
EOF
grep -c "instead of saving an image or file" /content/unsloth/studio/backend/core/inference/bundled_skills/skill-creator/SKILL.md
```

It should print `patched`, then `1`. Studio reads skill files on every request, so no restart is needed.

## Round 2: AFTER

Repeat P1–P3 with the names ending in `-after` (`csv-chart-after`, `todo-page-after`, `json-diff-after`), using the same use prompts and inputs.

## What to record (one row per created skill)

- **visual_method:** what the new SKILL.md tells the model to do for output:
  - `html-block`, `jsx-block`, `render_html`, `file` (e.g. a matplotlib PNG or an .html file), `markdown` (a markdown table/text), or `none`.
- **used_ok:** whether the use run worked (y / partial / n).
- **rendered:** whether the chart/page/table appeared in the chat as a preview card (y / partial / n).
- **notes.**
