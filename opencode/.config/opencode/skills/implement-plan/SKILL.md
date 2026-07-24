---
name: implement-plan
description: Implement a plan file by delegating tasks to build agents
---

## What I do

- Reads a plan file from `.specs/plans/` in the current working directory
- Parses unchecked tasks (`- [ ]`) from the plan
- Delegates each task to a build agent via the Task tool
- After each task, reads the plan file to verify progress and stay oriented
- Reports a summary when all tasks are done

> **Important:** The orchestrating agent runs in plan mode (read-only) — it never writes files. The subagent handles all file edits, including updating the plan file checkboxes.

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

### Step 3: Delegate tasks

For each unchecked task, use the Task tool to delegate implementation to a build agent. This is how work gets done — you orchestrate, the Task tool's subagent executes.

**Your role vs. the subagent's role:**

- **You (orchestrator):** Read the plan, delegate tasks, verify progress after each task, report summary. You do NOT write source code, run commands, or edit any files.
- **Subagent (build agent):** Implements the task, runs commands, creates/modifies files, AND marks the task complete in the plan file.

> **Note:** The `subagent_type` must be set to `"build"`. This agent type must be configured in your opencode setup with full tool access.

Include in the task prompt:

- The task description
- The file path to the plan file
- Any relevant context from the plan (objective, notes)
- Instructions to implement the task fully (code changes, file operations, etc.)
- Instructions to mark the task complete in the plan file after implementation succeeds (change `- [ ]` to `- [x]` for the corresponding task line)
- Instructions to run the project's test suite after implementation to verify no regressions:
  - If the plan specifies a test command, use that
  - Otherwise, check for common test runners (pytest, npm test, cargo test, etc.)
  - If tests fail, do not mark the task complete — report the failures as questions
- Exact file paths and line numbers referenced in the plan — include them verbatim so the subagent doesn't have to search
- Instructions on asking questions:
  - If you encounter ambiguity or need clarification, present your questions using this format:
    ```
    Questions
    - [question 1]
    - [question 2]
    ```
  - You may ask multiple questions — use a separate list item for each
  - Do not guess or assume — ask if anything is unclear
  - After asking questions, stop execution and wait for clarification

If the user specifies a model (via opencode's `:model` syntax or explicit mention), include it in the Task tool invocation.

Wait for each task to complete before proceeding to the next. Tasks are executed sequentially so that later tasks can depend on earlier ones (e.g., creating a file that a subsequent task modifies). If a subagent does not respond within a reasonable timeout (e.g., 5 minutes), report a timeout to the user and ask how to proceed.

### Step 4: Verify and orient

After each task completes, read the plan file to:

- Confirm the checkbox was updated (task marked `- [x]`)
- Check for any notes or "Questions" the subagent added
- Maintain awareness of overall progress

If the task was not marked complete, or the plan was modified beyond the checkbox (tasks added/removed/reordered), report it to the user and ask how to proceed.

If questions are found (subagent returned a "Questions" header):

1. Extract all list items as questions
2. Present them to the user as a numbered list:
   "The subagent working on [task] has [N] question(s):
    1. [question 1]
    2. [question 2]"
3. Get the user's answers (can be partial — "answer 1, skip 2, answer 3")
4. Resume the task with the same `task_id`:
   ```
   Answers
   - [answer to question 1]
   - [answer to question 2]
   - [answer to question 3]

   Please continue with the task.
   ```
5. Wait for the continuation result
6. Check again for more questions and repeat if needed
7. Once no questions remain, proceed to Step 5 (next task)

If no questions are found, proceed to Step 5 (next task).

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
- If a Task tool invocation fails, report the error and continue with the next task
- If the subagent returns an empty result, re-read the plan file to check if the checkbox was updated. If not, report to the user that the task outcome is unclear.
- If the subagent reports it cannot edit files (e.g., permission errors), report the permission issue to the user and stop execution
- If the subagent modifies the plan beyond the task checkbox (adds/removes/reorders tasks), report the unexpected changes and ask the user how to proceed
- If a subagent asks questions and the user cannot provide an answer, report the unanswered questions to the user and ask how to proceed
- If a subagent times out or hangs, report the timeout and ask the user how to proceed
- Always surface errors to the user — never retry silently

## Notes

- Each Task subagent starts with fresh context (minimal context) — only the task prompt is passed
- The orchestrating agent's context grows as it tracks progress (unavoidable for orchestration)
- Tasks are executed sequentially to maintain order and allow dependency tracking
- The user can interrupt at any point; partial progress is saved via checkbox updates
