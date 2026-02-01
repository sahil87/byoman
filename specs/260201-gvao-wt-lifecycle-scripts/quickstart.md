# Quickstart: Worktree Lifecycle Scripts

**Feature**: 260201-gvao-wt-lifecycle-scripts
**Date**: 2026-02-01

## Prerequisites

- Git repository
- `gh` CLI (required for `wt-merge`, optional for `wt-pr`)
- Scripts in PATH (alongside `wt-create`)

## Installation

Copy scripts to a directory in your PATH:

```bash
# From the repository root
cp bin/wt-delete bin/wt-pr bin/wt-merge ~/bin/

# Or create symlinks
ln -s "$(pwd)/bin/wt-delete" ~/bin/wt-delete
ln -s "$(pwd)/bin/wt-pr" ~/bin/wt-pr
ln -s "$(pwd)/bin/wt-merge" ~/bin/wt-merge
```

## Complete Workflow Example

### 1. Create a worktree

```bash
$ wt-create
Created worktree: london
Path: /Users/name/code/myproject-worktrees/london
Branch: wt/london
```

### 2. Do your work

```bash
$ cd /Users/name/code/myproject-worktrees/london
# ... make changes, commit ...
$ git add .
$ git commit -m "Add new feature"
```

### 3. Create a PR

```bash
$ wt-pr
Changes to be included in PR:

Branch: wt/london → main
Commits: 1
  abc1234 Add new feature

Create PR:
  1) Draft PR
  2) Ready PR
  3) Just push (no PR)
  0) Cancel

Choice: 2

PR created: https://github.com/owner/repo/pull/123
```

### 4. After PR is approved, merge

```bash
$ wt-merge
PR #123: Add new feature

Status: Open
Checks: ✓ 5 passed
Review: Approved
Mergeable: Yes

Merge this PR?
  1) Merge
  2) Merge and delete worktree
  0) Cancel

Choice: 2

PR merged successfully!
Deleted worktree: london
Deleted branch: wt/london (local and remote)

Run: cd /Users/name/code/myproject
```

## Quick Commands

### Non-interactive workflows (for scripting)

```bash
# Create draft PR immediately
wt-pr --draft

# Create ready PR immediately
wt-pr --ready

# Just push without creating PR
wt-pr --push

# Delete worktree without prompts
wt-delete --force

# Merge and cleanup in one command
wt-merge --delete-worktree
```

### Information commands

```bash
# List all worktrees
wt-delete --list

# Show help
wt-delete help
wt-pr help
wt-merge help
```

## Common Scenarios

### Delete a specific worktree (from main repo)

```bash
$ wt-delete london
Worktree: london
Branch: wt/london
Delete? [y/N]
```

### PR already exists

```bash
$ wt-pr
PR already exists for branch wt/london:
  #123: Add new feature
  URL: https://github.com/owner/repo/pull/123

  1) Open in browser
  0) Exit
```

### Merge blocked by failing checks

```bash
$ wt-merge
PR #123: Add new feature
Checks: ✗ 2 failed
Mergeable: Blocked

  1) Wait for checks
  2) Merge anyway (if permitted)
  0) Cancel
```

## Troubleshooting

### "gh CLI required for merging"

Install the GitHub CLI:
```bash
# macOS
brew install gh

# Linux
apt install gh  # or snap install gh
```

Then authenticate:
```bash
gh auth login
```

### "Not a git repository"

Run from within a git repository or worktree.

### "Worktree has uncommitted changes"

Either:
1. Commit your changes first
2. Choose "Stash changes" when prompted
3. Choose "Discard changes" to lose them
