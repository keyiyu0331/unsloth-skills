---
name: todo-page-v2
description: Transforms a list of tasks into a visually appealing, organized, and
  interactive-looking to-do list page using a React component.
---

1. **Parse Input**: Analyze the user's provided list of tasks. Identify the task name, category (e.g., Work, Personal), priority (High, Medium, Low), and completion status (Done, Pending). If these aren't specified, use sensible defaults (Category: "General", Priority: "Medium", Status: "Pending").

2. **Data Structure**: Organize the parsed data into an array of objects:
   `{ id: number, task: string, category: string, priority: string, completed: boolean }`

3. **Generate UI**: Reply with a single `jsx` code block that exports a React component. The component must:
    - Use `lucide-react` for icons (e.g., CheckCircle, AlertCircle).
    - Use `motion` from `framer-motion` for entry animations (optional but nice).
    - Feature a **Progress Bar** at the top showing the percentage of completed tasks.
    - Group tasks by **Category** with clear headings.
    - Color-code **Priority**: 
        - High: Red/Orange
        - Medium: Yellow/Amber
        - Low: Blue/Green
    - Include a "Status" indicator (checked/unchecked).

4. **Styling**: Use Tailwind CSS for a modern, clean look (e.g., rounded corners, subtle shadows, white background).

5. **Completion Check**: The final output must be a visually polished, organized page that clearly distinguishes between different tasks and priorities.
