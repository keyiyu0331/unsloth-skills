---
name: csv-dashboard
description: Turn a CSV file or pasted table into an interactive React dashboard with KPI cards and charts. Use when the user asks to visualize, chart, plot, summarize or build a dashboard from CSV or tabular data.
compatibility: Needs the python tool. Renders through a jsx code block (React preview with recharts).
metadata:
  languages: python, jsx
  libraries: pandas (optional; falls back to csv), react, recharts
---

# CSV dashboard

Follow these steps in order. Do not skip step 2.

1. **Get the data.**
   - If the user attached a CSV, run `ls` with the terminal tool to find it in the working directory.
   - If the user pasted the data, save it as `data.csv` with the python tool.
2. **Profile it with the python tool.** Run the profiling script in `reference.md` (call `read_skill` with `resource="reference.md"`). It prints a JSON summary with:
   - the columns and their types
   - row count
   - 3 to 4 KPIs
   - at most 2 chart series, each with 50 points or fewer
3. **Check the JSON.** If a column the user cares about is missing or wrong, fix the script and run it again. Never make up numbers. Every number on the dashboard must come from the script output.
4. **Write the dashboard as ONE fenced code block with the language `jsx`.** Use the template in `reference.md`. Rules:
   - Only import from `react` and `recharts`. No other packages, no `fetch`, no file reads.
   - Paste the JSON from step 2 into a `const DATA = ...` at the top of the block.
   - The block must `export default function App()`.
   - Use plain inline styles, no CSS files.
5. **Finish** with 2 or 3 sentences on what the data shows, below the code block.

## Libraries
| Language | Libraries | Where |
|---|---|---|
| Python | pandas (falls back to stdlib `csv`), `json` | profiling in the sandbox |
| JSX | react, recharts | Studio React preview |
