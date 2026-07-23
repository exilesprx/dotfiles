---
name: add-plan
description: Create plan files for future implementation
license: MIT
compatibility: opencode
---

## What I do

- Creates the `.specs/plans/` directory in the current working directory if it does not exist
- Generates a plan file at `.specs/plans/` with the naming format `YYYYMMDD-{scope}.md`
- Populates the plan file with a structured template for documenting the task(s)
- Does **not** implement the plan — file creation only
- If write permissions are denied, prompts the user to switch to build mode or otherwise gain the necessary permissions

## When to use me

Use this when the user asks to:

- Create a plan file for a task or list of tasks
- "Plan this out" for future implementation
- Generate a spec or plan document before coding

## Plan file format

The file is created at `.specs/plans/YYYYMMDD-{scope}.md` where:

- `YYYYMMDD` is the current date
- `scope` is a short, kebab-case description of the task (e.g., `user-auth`, `api-refactor`)

If the user provides a scope, use that. If not, ask for one.

### Template

```markdown
# {Title}

## Objective

{What this plan aims to accomplish}

## Tasks

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Notes

{Any additional context, constraints, or considerations}
```

## Error handling

If writing to `.specs/plans/` fails due to permissions:

1. Inform the user that write access was denied
2. Prompt them to switch to build mode or adjust permissions
3. Do not retry silently — always surface the error

