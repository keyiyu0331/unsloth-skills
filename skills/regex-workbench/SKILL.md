---
name: regex-workbench
description: Write, test and explain a regular expression against sample text, then show a match table. Use when the user asks for a regex, pattern matching, extracting fields from log lines or text, or why a regex does not match.
compatibility: Needs the python and render_html tools.
metadata:
  languages: python, html
  libraries: python stdlib (re, json, html)
---

# Regex workbench

Follow these steps in order. Never claim a regex works without running it.

1. **Collect the inputs:**
   - what to match or extract
   - the sample lines (pasted, or a file in the working directory)
   - optional lines that must NOT match

   If no samples are given, write 4 realistic ones and say that you did.
2. **Write a first pattern.** Use named groups `(?P<name>...)` for every field to extract.
3. **Test it with the python tool.** Run this script, filling in `PATTERN`, `FLAGS`, `SHOULD_MATCH` and `SHOULD_NOT`:

```python
import re, json
PATTERN = r""
FLAGS = 0  # e.g. re.IGNORECASE
SHOULD_MATCH = []
SHOULD_NOT = []
rx = re.compile(PATTERN, FLAGS)
rows = []
for line in SHOULD_MATCH + SHOULD_NOT:
    m = rx.search(line)
    rows.append({"line": line, "expected": line in SHOULD_MATCH, "matched": bool(m),
                 "groups": m.groupdict() if m else {}})
print(json.dumps({"pattern": PATTERN, "ok": all(r["expected"] == r["matched"] for r in rows), "rows": rows}))
```

4. **Fix and rerun until `"ok": true`, at most 4 tries.** If it still fails after 4 tries, say which lines fail and why.
5. **Call `render_html` once** with the HTML template below. Fill one table row per line in `rows`: green for a correct result, red for a wrong one. The table columns are line, expected, matched, plus one column per named group. Escape `<`, `>` and `&` in the text.
6. **Reply with:**
   - the final pattern in a code block
   - one bullet per part of the pattern, explaining it
   - Python and JavaScript usage one-liners

## HTML template

```html
<!doctype html><html><head><meta charset="utf-8"><style>
body{font-family:system-ui,sans-serif;background:#111827;color:#f9fafb;padding:16px}
code{background:#1f2937;padding:2px 6px;border-radius:4px}
table{border-collapse:collapse;width:100%;margin-top:12px;font-size:14px}
th,td{border:1px solid #374151;padding:6px 8px;text-align:left;font-family:ui-monospace,monospace}
tr.ok td:first-child{border-left:4px solid #34d399} tr.bad td:first-child{border-left:4px solid #f87171}
</style></head><body>
<h3>Pattern: <code>PATTERN_HERE</code></h3>
<table><thead><tr><th>Line</th><th>Expected</th><th>Matched</th><!-- one <th> per group --></tr></thead>
<tbody><!-- <tr class="ok"><td>line</td><td>yes</td><td>yes</td><td>group value</td></tr> --></tbody></table>
</body></html>
```

## Libraries
| Language | Libraries | Where |
|---|---|---|
| Python | stdlib `re`, `json` | testing in the sandbox |
| HTML/CSS | none | `render_html` canvas |
