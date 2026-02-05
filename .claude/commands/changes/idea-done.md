---
allowed-tools: Read, Edit
description: Mark an idea as done in the ideas backlog
---

## Your task

Mark an idea as completed in `.specify/ideas.md`.

### Step 1: Identify the idea

**If an ID is provided** (e.g., `$ARGUMENTS` = "b7t1"): Use it directly to find the idea.

**If text hint provided**: Search for ideas containing that text.

**If no arguments**: Review the current conversation to identify which idea was just completed.

### Step 2: Find the idea

Read the ideas file at `$(git rev-parse --show-toplevel)/.specify/ideas.md`

Each idea has format: `- [ ] [id] YYYY-MM-DD: description`

- If ID provided: Find the line with `[id]`
- If text hint: Find lines containing the hint text
- If multiple matches (or no ID given): Show them and ask user to confirm:

```
Found matching ideas:
- [ ] [b7t1] 2026-02-02: First matching idea...
- [ ] [k3ui] 2026-02-02: Second matching idea...

Which ID should I mark as done?
```

### Step 3: Mark as done

Use the Edit tool to change `- [ ]` to `- [x]` for the identified idea.

**Important**: Match on the ID (e.g., `[b7t1]`) to ensure you edit the correct line.

### Step 4: Confirm

```
Marked as done: [x] [b7t1] 2026-02-02: The idea text...
```
