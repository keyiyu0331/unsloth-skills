---
name: csv-chart-after
description: Use this skill when the user provides a CSV string and wants to visualize
  it as a chart in the chat.
---

1. Parse the provided CSV string into a structured JSON format (an array of objects where keys are the header row).
2. Analyze the data to determine the appropriate chart type:
   - **Line Chart**: Use if there is a clear time-based or continuous numerical sequence.
   - **Bar Chart**: Use for categorical data or discrete comparisons.
   - **Scatter Plot**: Use if there are two numerical variables to correlate.
3. If the data is ambiguous, ask the user to specify the preferred chart type (Line, Bar, or Scatter).
4. Generate a `jsx` code block that exports a React component.
5. Use `recharts` for the visualization and `Tailwind CSS` for styling.
6. Ensure the component includes:
   - A title derived from the data context.
   - Properly labeled X and Y axes.
   - A responsive container.
7. The final output must be a single fenced `jsx` block.
8. Completion check: The user sees a rendered, interactive chart in the chat.
