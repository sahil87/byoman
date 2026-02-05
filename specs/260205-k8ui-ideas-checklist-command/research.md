# Research Notes: Ideas Checklist Format and Command

**Feature**: 260205-k8ui-ideas-checklist-command
**Date**: 2026-02-05

## Current Implementation Analysis

### ideas.md Format (Current)

Location: `.specify/ideas.md`

Current format:
```markdown
- 2026-02-02: In wt-create also give option to open the worktree as a byobu tab...
- 2026-02-02: Make the tui more slick...
```

Pattern: `- YYYY-MM-DD: <idea text>`

### ideas Script (Current)

Location: `.specify/bin/ideas`

```bash
#!/bin/bash
set -e

if [ $# -eq 0 ]; then
  echo "Usage: ideas <your idea>" >&2
  exit 1
fi

echo "- $(date +%Y-%m-%d): $*" >> "$(git rev-parse --show-toplevel)/.specify/ideas.md"
```

**Observations**:
- Uses git to find repo root (portable across worktrees)
- Appends to file (no sorting/ordering logic)
- Simple error handling with usage message
- Date format already matches spec requirement

## Markdown Checkbox Syntax

### Standard Syntax

```markdown
- [ ] Unchecked item
- [x] Checked item
- [X] Also valid (capital X)
```

### GitHub Flavored Markdown (GFM) Compatibility

- Works in GitHub, VS Code, most markdown renderers
- Interactive in GitHub (can click to toggle)
- Rendered as actual checkboxes in preview mode

### Target Format

```markdown
- [ ] 2026-02-02: In wt-create also give option to open the worktree...
- [x] 2026-02-05: Convert ideas to a check list...
```

Pattern: `- [ ] YYYY-MM-DD: <idea text>`

## Claude Code Skill File Structure

### File Location

Skills are located at: `.claude/commands/<category>/<name>.md`

Example: `.claude/commands/changes/commit.md` -> invoked as `/changes:commit`

### File Format

```markdown
---
allowed-tools: <tool permissions>
description: <one-line description>
---

## Your task

<instructions for Claude>
```

### Relevant Examples

From `commit.md`:
- Uses `allowed-tools: Bash(git:*)` for git commands
- Instructions tell Claude what to gather and how to proceed

### Required Skill Structure for idea.md

```markdown
---
allowed-tools: Bash(.specify/bin/ideas)
description: Capture a new idea in the ideas file
---

## Your task

Add a new idea to the ideas tracker.

[Instructions to run the script with user's argument]
```

## Migration Strategy

### Existing Entries

9 entries currently in `.specify/ideas.md`, all from 2026-02-02 or 2026-02-05.

**Migration approach**: Manual one-time edit to add `[ ] ` after each hyphen.

Before: `- 2026-02-02: idea text`
After:  `- [ ] 2026-02-02: idea text`

### Script Update

Single line change in `.specify/bin/ideas`:

Before: `echo "- $(date +%Y-%m-%d): $*"`
After:  `echo "- [ ] $(date +%Y-%m-%d): $*"`

## Decision Summary

1. **Format**: `- [ ] YYYY-MM-DD: idea text` (checkbox before date)
2. **Migration**: Manual edit of existing entries (9 items, simple find-replace)
3. **Script**: Add `[ ] ` to echo output
4. **Skill**: Create `.claude/commands/changes/idea.md` with bash permission for the script
