---
name: csv-chart-before
description: Use this skill to convert a pasted CSV string into a visual chart (e.g.,
  line, bar, or scatter plot) and display it.
---

1. Ask the user to provide the CSV data.
2. Once the CSV data is provided:
    - Use a Python script to parse the CSV into a pandas DataFrame.
    - Analyze the columns to identify numerical and categorical data.
    - Automatically select a suitable chart type (e.g., Line chart for time series/continuous data, Bar chart for categorical data, or Scatter plot for two numerical variables).
    - Generate the chart using `matplotlib` or `seaborn`.
    - Save the chart as `chart.png`.
    - Call `view_image` on `chart.png` to ensure the chart is generated and provide the filename to the user.
3. If the data is ambiguous, ask the user which columns they would like on the X and Y axes and which chart type they prefer.
