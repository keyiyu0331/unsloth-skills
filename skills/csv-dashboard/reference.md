# csv-dashboard reference

## Profiling script (run with the python tool)

Set `PATH` to the CSV file. If the user asked about a specific column (e.g. revenue), set `VALUE_COL` to it; otherwise the script guesses. Check `"used"` in the output and rerun with fixed columns if a guess is wrong.

```python
import csv, json
from collections import defaultdict

PATH = "data.csv"
DATE_COL = None   # guessed below if None
VALUE_COL = None  # first numeric column if None
GROUP_COL = None  # first low-cardinality text column if None

with open(PATH, newline="", encoding="utf-8-sig") as f:
    rows = list(csv.DictReader(f))
cols = list(rows[0].keys()) if rows else []

def num(v):
    try:
        return float(str(v).replace(",", ""))
    except ValueError:
        return None

numeric = [c for c in cols if sum(num(r[c]) is not None for r in rows) >= 0.9 * len(rows)]
text = [c for c in cols if c not in numeric]
DATE_COL = DATE_COL or next((c for c in text if "date" in c.lower() or "time" in c.lower() or "month" in c.lower()), None)
MONEY = ("revenue", "sales", "amount", "total", "price", "value", "count")
VALUE_COL = VALUE_COL or next((c for c in numeric if any(w in c.lower() for w in MONEY)), numeric[0] if numeric else None)
GROUP_COL = GROUP_COL or next((c for c in text if c != DATE_COL and len({r[c] for r in rows}) <= 12), None)

out = {"rows": len(rows), "columns": {c: ("number" if c in numeric else "text") for c in cols}, "kpis": [], "series": {}}

if VALUE_COL:
    vals = [num(r[VALUE_COL]) for r in rows if num(r[VALUE_COL]) is not None]
    out["kpis"] = [
        {"label": f"Total {VALUE_COL}", "value": round(sum(vals), 2)},
        {"label": f"Average {VALUE_COL}", "value": round(sum(vals) / len(vals), 2)},
        {"label": f"Max {VALUE_COL}", "value": round(max(vals), 2)},
        {"label": "Rows", "value": len(rows)},
    ]
    if DATE_COL:
        by = defaultdict(float)
        for r in rows:
            if num(r[VALUE_COL]) is not None:
                by[r[DATE_COL]] += num(r[VALUE_COL])
        pts = sorted(by.items())[-50:]
        out["series"]["over_time"] = [{"x": k, "y": round(v, 2)} for k, v in pts]
    if GROUP_COL:
        by = defaultdict(float)
        for r in rows:
            if num(r[VALUE_COL]) is not None:
                by[r[GROUP_COL]] += num(r[VALUE_COL])
        pts = sorted(by.items(), key=lambda kv: -kv[1])[:12]
        out["series"]["by_group"] = [{"x": k, "y": round(v, 2)} for k, v in pts]

out["used"] = {"date": DATE_COL, "value": VALUE_COL, "group": GROUP_COL}
# Print the finished line for the dashboard. Copy it exactly; do not retype or add braces.
print("const DATA = " + json.dumps(out, indent=1) + ";")
```

## Dashboard template (reply with this as a ```jsx block)

Replace the `const DATA = ...;` line with the one the script printed, copied exactly as printed. Do not add or remove any `{`, `}`, `[` or `]`. Remove a chart if its series is missing.

```jsx
import React from "react";
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid, ResponsiveContainer } from "recharts";

const DATA = {"rows": 0, "kpis": [], "series": {}, "used": {}};

const card = { background: "#1f2937", color: "#f9fafb", borderRadius: 12, padding: 16, flex: "1 1 160px" };

export default function App() {
  const s = DATA.series;
  return (
    <div style={{ fontFamily: "system-ui, sans-serif", padding: 16, background: "#111827", minHeight: "100vh", color: "#f9fafb" }}>
      <h2 style={{ marginTop: 0 }}>Dashboard</h2>
      <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
        {DATA.kpis.map((k) => (
          <div key={k.label} style={card}>
            <div style={{ fontSize: 12, opacity: 0.7 }}>{k.label}</div>
            <div style={{ fontSize: 24, fontWeight: 700 }}>{k.value.toLocaleString()}</div>
          </div>
        ))}
      </div>
      {s.over_time && (
        <div style={{ ...card, marginTop: 16, height: 300 }}>
          <div>{DATA.used.value} over {DATA.used.date}</div>
          <ResponsiveContainer width="100%" height="90%">
            <LineChart data={s.over_time}>
              <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
              <XAxis dataKey="x" stroke="#9ca3af" />
              <YAxis stroke="#9ca3af" />
              <Tooltip />
              <Line type="monotone" dataKey="y" stroke="#34d399" dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      )}
      {s.by_group && (
        <div style={{ ...card, marginTop: 16, height: 300 }}>
          <div>{DATA.used.value} by {DATA.used.group}</div>
          <ResponsiveContainer width="100%" height="90%">
            <BarChart data={s.by_group}>
              <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
              <XAxis dataKey="x" stroke="#9ca3af" />
              <YAxis stroke="#9ca3af" />
              <Tooltip />
              <Bar dataKey="y" fill="#60a5fa" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}
    </div>
  );
}
```
