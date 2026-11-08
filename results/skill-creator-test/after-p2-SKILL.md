---
name: todo-page-after
description: Use this skill to transform a list of tasks into a visually appealing,
  organized to-do list page using a React component.
---

1. Analyze the user's provided list of tasks to extract task names, priorities (e.g., High, Medium, Low), deadlines, and categories.
2. If categories or priorities are not explicitly mentioned, group tasks logically (e.g., by context or project).
3. Generate a React component inside a fenced `jsx` code block.
4. Use the following libraries for the UI:
    - `lucide-react` for icons (e.g., `CheckCircle`, `Clock`, `AlertCircle`).
    - `framer-motion` for smooth entrance animations.
    - `Tailwind CSS` for layout, card styling, and typography.
5. The component should include:
    - A clear header displaying the project/list title and a progress summary (e.g., "3 of 10 tasks completed").
    - A grid or list layout of cards for each task.
    - Visual indicators for priority (colors) and deadlines.
    - A progress bar showing the percentage of completion.
6. Ensure the UI is responsive and uses a modern, clean aesthetic.
7. Completion Check: The final response must contain exactly one fenced `jsx` block that `export default`s a React component.
