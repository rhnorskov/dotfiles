---
name: feedback_use_question_mode
description: Use AskUserQuestion tool instead of plain text when asking the user questions during task execution.
type: feedback
---

Always use the AskUserQuestion tool when asking the user questions, rather than listing questions as plain text in the response.

**Why:** The user explicitly corrected this behavior — they expect the structured question UI for gathering input.

**How to apply:** Whenever you need user input (choices, confirmations, clarifications), use AskUserQuestion with appropriate options instead of writing questions as markdown text.
