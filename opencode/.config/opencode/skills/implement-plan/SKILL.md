---
name: implement-plan
description: Implement a plan file by delegating tasks to build agents
---

## What I do

- Reads a plan file from `.specs/plans/` in the current working directory
- Parses unchecked tasks (`- [ ]`) from the plan
- Delegates each task to a build agent via the Task tool
- Updates the plan file to mark completed tasks (`- [x]`)
- Reports a summary when all tasks are done

## When to use me

Use this when the user asks to:

- Implement a plan file
- Execute tasks from a plan
- "Build this plan"
- Work through a plan file's tasks

Look for patterns like:

- "implement-plan user-auth"
- "implement .specs/plans/20260723-user-auth.md"
- "execute the plan"
- "build out the plan"

## How to use me

### Step 1: Resolve the plan file

The user provides a scope name (e.g., `user-auth`) or a full path (e.g., `.specs/plans/20260723-user-auth.md`).

- If scope name: search `.specs/plans/` for a file matching `*-{scope}.md`
- If full path: use that path directly
- If no scope given: list available plan files and ask the user to choose

Use `glob` to find matching files, then `read` to load the plan content.

### Step 2: Parse tasks

Extract all task lines from the plan. Tasks are markdown checkboxes:

- Unchecked: `- [ ] Task description`
- Checked: `- [x] Task description`

Collect only unchecked tasks. If no unchecked tasks exist, report that all tasks are complete and stop.

### Step 3: Delegate tasks

For each unchecked task, use the Task tool to delegate implementation to a build agent. This is how work gets done — you orchestrate, the Task tool's subagent executes. Do not edit files or run commands directly.

> **Note:** The `subagent_type` must be set to `"build"`. This agent type must be configured in your opencode setup with full tool access.

Include in the task prompt:

- The task description
- The file path to the plan file
- Any relevant context from the plan (objective, notes)
- Instructions to implement the task fully (code changes, file operations, etc.)
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

If the user specifies a model (via `:model` syntax or explicit mention), include it in the Task tool invocation.

Wait for each task to complete before proceeding to the next. Tasks are executed sequentially so that later tasks can depend on earlier ones (e.g., creating a file that a subsequent task modifies).

### Step 4: Handle subagent questions

After each task completes, check if the result contains a "Questions" header.

If questions are found:

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
7. Once no questions remain, proceed to Step 5 (update plan)

If no questions are found, proceed normally to Step 5.

### Step 5: Update the plan

After each task completes successfully (no outstanding questions):

1. Read the current plan file
2. Find the task line that was just completed
3. Change `- [ ]` to `- [x]` for that task
4. Write the updated plan file

If a task fails, do NOT check it off. Report the error and ask the user how to proceed.

### Step 6: Report summary

After all tasks are processed, report:

- Total tasks attempted
- Tasks completed successfully
- Tasks that failed (with error summary)
- Remaining unchecked tasks (if any)

## Error handling

- If the plan file does not exist, inform the user and suggest using `add-plan` first
- If no unchecked tasks remain, report all tasks are complete
- If a Task tool invocation fails, report the error and continue with the next task
- If updating the plan file fails, report the error but note the task was completed
- If a subagent asks questions and the user cannot provide an answer, add an "## Open Questions" section to the plan file with the questions, then skip the task
- Always surface errors to the user — never retry silently

## Notes

- Each Task subagent starts with fresh context (0 tokens) — only the task description is passed
- The orchestrating agent's context grows as it tracks progress (unavoidable for orchestration)
- Tasks are executed sequentially to maintain order and allow dependency tracking
- The user can interrupt at any point; partial progress is saved via checkbox updates
