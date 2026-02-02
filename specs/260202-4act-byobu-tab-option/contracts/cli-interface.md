# CLI Interface Contract: wt-create (Byobu Tab Option)

**Feature**: 260202-4act-byobu-tab-option
**Date**: 2026-02-02

## Command Synopsis

```
wt-create [BRANCH] [OPTIONS]
wt-create help
```

## Byobu-Specific Behavior

When `wt-create` is executed inside an active byobu session, the post-create menu includes a byobu tab option. Outside of byobu, this option is not shown.

## Interactive Menu Contract (Addition)

### Menu Display (byobu session only)

```
Open in:
  1) VSCode
  2) Cursor
  3) Ghostty
  4) Byobu tab
  0) Exit

Choice:
```

### Menu Action (byobu tab)

| Selection | Action |
|-----------|--------|
| Byobu tab | Create a new byobu tab, focus it immediately, and set its working directory to the new worktree. Tab name is `repo-name + worktree-name`. |

## Error Output (byobu tab failure)

```
Error: Failed to open byobu tab
  Why: <explanation>
  Fix: Verify byobu session is active and retry
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success - worktree created (and tab opened if selected) |
| 1 | General error (not in git repo, permission denied, etc.) |
| 2 | Invalid arguments |
| 3 | Worktree creation failed (git error) |
| 5 | Byobu tab open failed (worktree created successfully) |

## Notes

- This contract extends the existing `wt-create` interface without changing arguments or options.
- Byobu tab option is only available when a byobu session is detected.
