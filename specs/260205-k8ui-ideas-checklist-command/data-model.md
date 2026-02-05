# Data Model: Ideas Checklist

**Feature**: 260205-k8ui-ideas-checklist-command
**Date**: 2026-02-05

## Entities

### Idea Entry

A single captured idea with completion tracking.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| status | enum | `[ ]` or `[x]` | Completion status: unchecked (pending) or checked (done) |
| date | string | `YYYY-MM-DD` | Date the idea was captured |
| text | string | free text | Description of the idea |

### Serialized Format

```
- [status] date: text
```

**Examples**:

```markdown
- [ ] 2026-02-05: Add dark mode support
- [x] 2026-02-02: Convert ideas to checklist format
```

### Field Constraints

| Field | Constraint |
|-------|------------|
| status | MUST be exactly `[ ]` (space between brackets) or `[x]` (lowercase x) |
| date | MUST be valid ISO 8601 date format |
| text | MAY contain any characters except newlines |

### State Transitions

```
New idea: - [ ] YYYY-MM-DD: text
     │
     ▼
Mark done: - [x] YYYY-MM-DD: text
     │
     ▼
Reopen:   - [ ] YYYY-MM-DD: text
```

## Storage

### File Location

```
<repo-root>/.specify/ideas.md
```

### File Format

- Plain markdown text file
- One idea entry per line
- No header or footer required
- Entries appended chronologically (newest at bottom)

### Example File

```markdown
- [ ] 2026-02-02: In wt-create also give option to open the worktree as a byobu tab
- [x] 2026-02-02: Convert ideas to a check list format
- [ ] 2026-02-05: Add toggle option for mobile status bar mode
```

## Operations

### Create

**Command**: `.specify/bin/ideas <text>` or `/changes:idea <text>`

**Effect**: Appends `- [ ] YYYY-MM-DD: <text>` to end of file

### Toggle Status

**Method**: Manual edit in any text editor

**Steps**:
1. Open `.specify/ideas.md`
2. Change `[ ]` to `[x]` (or vice versa)
3. Save file

### Read

**Method**: View file directly or use markdown preview

**Rendering**: Markdown viewers display checkboxes; GitHub allows interactive toggling.
