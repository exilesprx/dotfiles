---
name: implement-plan
description: Implement a plan file by executing tasks directly
---

## What I do

- Reads a plan file from `.specs/plans/` in the current working directory
- Parses unchecked tasks (`- [ ]`) from the plan
- Implements each task directly (edits files, runs commands, creates/modifies code)
- Marks each task complete in the plan file after successful implementation
- Reports a summary when all tasks are done

## When to use me

Invoke this skill when the user asks to:

- Implement a plan file
- Execute tasks from a plan
- "Build this plan"
- Work through a plan file's tasks

Typical user phrasing:
- "implement-plan user-auth"
- "implement .specs/plans/20260723-user-auth.md"
- "execute the plan"
- "build out the plan"

## How to use me

### Step 1: Resolve the plan file

The user provides a scope name (e.g., `user-auth`) or a full path (e.g., `.specs/plans/20260723-user-auth.md`).

- If scope name: search `.specs/plans/` for a file matching `*{scope}.md` (matches both `user-auth.md` and `20260723-user-auth.md`)
- If full path: use that path directly
- If no scope given: list available plan files as a numbered list and ask the user to choose by number

Use `glob` to find matching files, then `read` to load the plan content.

### Step 2: Validate and parse tasks

Before processing, verify the plan file has valid structure:
- Contains at least one markdown checkbox task (`- [ ]` or `- [x]`)
- Tasks are well-formed (no duplicate lines, no malformed checkboxes)

Extract all task lines from the plan. Tasks are markdown checkboxes:

- Unchecked: `- [ ] Task description`
- Checked: `- [x] Task description`

Collect only unchecked tasks. If no unchecked tasks exist, report that all tasks are complete and stop.

### Step 3: Implement tasks

For each unchecked task, implement it directly — edit files, run commands, create or modify code as needed.

For each task:

1. Read the task description and any relevant context from the plan (objective, notes)
2. Locate the exact files and line numbers referenced in the plan
3. Implement the task fully (code changes, file operations, etc.)
4. Run the project's test suite to verify no regressions:
   - If the plan specifies a test command, use that
   - Otherwise, check for common test runners (pytest, npm test, cargo test, etc.)
   - If tests fail, do not mark the task complete — report the failures to the user and ask how to proceed
5. Mark the task complete in the plan file (change `- [ ]` to `- [x]` for the corresponding task line)

If you encounter ambiguity or need clarification, present your questions to the user as a numbered list:

```
Questions
- [question 1]
- [question 2]
```

Do not guess or assume — ask if anything is unclear. After asking questions, stop execution and wait for clarification before proceeding.

Tasks are implemented sequentially so that later tasks can depend on earlier ones (e.g., creating a file that a subsequent task modifies).

### Step 4: Verify and orient

After implementing each task, re-read the plan file to:

- Confirm the checkbox was updated (task marked `- [x]`)
- Maintain awareness of overall progress

If the task was not marked complete, or the plan was modified beyond the checkbox (tasks added/removed/reordered), report it to the user and ask how to proceed.

If you asked questions and the user answered them, resume the task with their answers. Once no questions remain, proceed to Step 5 (next task).

### Step 5: Report summary

After all tasks are processed, report:

- Total tasks attempted
- Tasks completed successfully
- Tasks that failed (with error summary)
- Remaining unchecked tasks (if any)

## Error handling

- If the plan file does not exist, inform the user and suggest using `add-plan` first
- If the plan file is malformed (no valid tasks, duplicate checkboxes, unparseable structure), report the issue and stop
- If no unchecked tasks remain, report all tasks are complete
- If a task fails (file edit fails, command errors, permission issues), report the error to the user and ask how to proceed
- If the plan is modified beyond the task checkbox (tasks added/removed/reordered), report the unexpected changes and ask the user how to proceed
- If the user cannot provide an answer to a question, report the unanswered questions and ask how to proceed
- Always surface errors to the user — never retry silently

## Notes

- Tasks are executed sequentially to maintain order and allow dependency tracking
- The user can interrupt at any point; partial progress is saved via checkbox updates
