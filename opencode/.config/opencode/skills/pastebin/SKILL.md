---
name: pastebin
description: Create a PrivateBin paste from a file
---

## What I do

Reads a file and creates a PrivateBin paste from its contents using the `privatebin` CLI.

## When to use me

Use this when the user wants to share a file as a PrivateBin paste.
Look for patterns like:
- "paste @file to privatebin"
- "create a privatebin from file.go"
- "share README.md as a paste"
- "paste this file to privatebin"

## How to use me

1. Identify the file path from the user's message (strip any `@` prefix)
2. Read the file content using the `read` tool
3. Pipe the content to `privatebin create` via stdin
4. Return the URL to the user

## Command template

```bash
cat "<file_path>" | privatebin create
```

## Options

Forward any flags the user provides to `privatebin create`:
- `--expire` — paste TTL (e.g., `1h`, `1d`, `1w`)
- `--burn-after-reading` — delete after first view
- `--formatter` — `plaintext`, `markdown`, or `syntaxhighlighting`
- `--password` — encrypt the paste
- `--attachment` — create as attachment with filename

## Error handling

- If the file does not exist, inform the user
- If `privatebin` fails, show the error and suggest checking network/config

