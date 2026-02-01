# CLI Interface Contract: wt-create

**Feature**: 260201-is0r-worktree-create-script
**Date**: 2026-02-01

## Command Synopsis

```
wt-create [BRANCH] [OPTIONS]
wt-create help
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| BRANCH | No | Branch name to checkout. If omitted, creates new branch with `wt/<random-name>` pattern |

## Options

| Option | Description |
|--------|-------------|
| help | Display usage information and configured worktree location |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success - worktree created |
| 1 | General error (not in git repo, permission denied, etc.) |
| 2 | Invalid arguments |
| 3 | Worktree creation failed (git error) |
| 4 | All retry attempts exhausted (name collision) |

## Output Format

### Success Output

```
Created worktree: prague
Path: /Users/name/code/myproject-worktrees/prague
Branch: wt/prague

Open in:
  1) VSCode
  2) Cursor
  3) Ghostty
  4) Finder
  5) Copy path
  0) Exit

Choice:
```

### Error Output (stderr)

```
Error: <what failed>
  Why: <explanation>
  Fix: <suggested remediation>
```

## Interactive Menu Contract

### Menu Display

- Shows numbered list of available applications (1-N)
- Option 0 always means "Exit without opening"
- Empty input (Enter) treated as 0
- Only shows applications detected on the system

### Menu Actions

| Selection | Action |
|-----------|--------|
| 1-N | Execute corresponding application's open command |
| 0 | Exit script (worktree already created) |
| Enter | Same as 0 |
| Invalid | Display error, re-show menu |

### Application Open Commands

| App | macOS Command | Linux Command |
|-----|---------------|---------------|
| VSCode | `code <path>` | `code <path>` |
| Cursor | `cursor <path>` | `cursor <path>` |
| Ghostty | `open -a Ghostty <path>` | `ghostty -e "cd <path> && $SHELL"` |
| iTerm2 | `open -a iTerm <path>` | N/A |
| Terminal.app | `open -a Terminal <path>` | N/A |
| GNOME Terminal | N/A | `gnome-terminal --working-directory=<path>` |
| Konsole | N/A | `konsole --workdir <path>` |
| Finder | `open <path>` | N/A |
| Nautilus | N/A | `nautilus <path>` |
| Dolphin | N/A | `dolphin <path>` |
| Copy path | `echo <path> \| pbcopy` | `echo <path> \| xclip -selection clipboard` |

## Environment Variables

| Variable | Effect |
|----------|--------|
| NO_COLOR | If set, suppress colored output |
| WT_CREATE_RETRIES | Max name collision retries (default: 10) |

## Examples

### Create exploratory worktree

```bash
$ wt-create
Created worktree: prague
Path: /Users/name/code/myproject-worktrees/prague
Branch: wt/prague
...
```

### Create worktree for existing branch

```bash
$ wt-create feature/login
Created worktree: login
Path: /Users/name/code/myproject-worktrees/login
Branch: feature/login
...
```

### Show help

```bash
$ wt-create help
Usage: wt-create [BRANCH]

Creates a git worktree for parallel development.

Arguments:
  BRANCH    Branch to checkout (optional)
            If omitted, creates wt/<random-name> branch

Worktrees created at: /path/to/repo-worktrees/

Options:
  help      Show this help message

Examples:
  wt-create                    # New worktree with random name
  wt-create feature/auth       # Worktree for existing branch
  wt-create my-experiment      # Worktree with new named branch
```
