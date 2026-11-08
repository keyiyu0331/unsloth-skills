---
name: todo-page-before
description: Use this skill when the user provides a raw list of tasks and wants them
  formatted into a clean, organized, and readable page within the chat.
---

1. Receive a raw list of to-do items from the user (pasted text, bullets, or loose lines).
2. Parse the input to identify distinct tasks.
3. Format the output as a "To-Do Page" using the following Markdown structure:
    - **Header**: `## 📋  My To-Do List`
    - **Separator**: A horizontal rule `---`
    - **Task List**: Use a checkbox format for each item: `- [ ] <Task Name>`
    - **Summary**: A brief footer stating the total number of tasks.
4. Ensure the formatting is clean, minimalist, and easy to read.
5. If the user provides status (like "done" or "done:"), format the checkbox as `- [x]`.
6. Provide only the formatted page as the output.
