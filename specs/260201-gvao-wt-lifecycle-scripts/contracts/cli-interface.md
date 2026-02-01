# CLI Interface Contract: Worktree Lifecycle Scripts

**Feature**: 260201-gvao-wt-lifecycle-scripts
**Date**: 2026-02-01

---

## wt-delete

### Command Synopsis

```
wt-delete [NAME] [OPTIONS]
wt-delete help
```

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| NAME | No | Worktree name to delete. If omitted from within a worktree, deletes current. If omitted from main repo, shows selection menu. |

### Options

| Option | Short | Description |
|--------|-------|-------------|
| `--force` | `-f` | Skip confirmation prompt (for scripting) |
| `--list` | `-l` | List all worktrees and exit |
| `--keep-branch` | `-k` | Delete worktree but keep the branch |
| `help` | | Display usage information |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success - worktree deleted |
| 1 | General error (not in git repo, worktree not found, etc.) |
| 2 | Invalid arguments |
| 3 | Git operation failed |

### Output Format

#### Success Output

```
Worktree: london
Branch: wt/london
Path: /Users/name/code/myproject-worktrees/london

Delete this worktree?
  1) Delete worktree and branch
  2) Delete worktree, keep branch
  0) Cancel

Choice: 1

Deleted worktree: london
Deleted branch: wt/london (local)
Deleted branch: wt/london (remote)

You are no longer in a valid directory.
Run: cd /Users/name/code/myproject
```

#### Uncommitted Changes Warning

```
Warning: Worktree has uncommitted changes

  1) Stash changes and delete
  2) Discard changes and delete
  0) Cancel

Choice:
```

#### Unpushed Commits Warning

```
Warning: Branch has 3 unpushed commits

Commits that will be lost:
  abc1234 Add new feature
  def5678 Fix bug
  ghi9012 Update docs

Continue anyway?
  1) Yes, delete (commits will be lost)
  0) Cancel

Choice:
```

#### List Output (`--list`)

```
Worktrees:
  london     wt/london    /Users/name/code/myproject-worktrees/london
  paris      feature/auth /Users/name/code/myproject-worktrees/paris
  * (main)   main         /Users/name/code/myproject
```

#### Error Output (stderr)

```
Error: <what failed>
  Why: <explanation>
  Fix: <suggested remediation>
```

### Interactive Menu Contract

#### Worktree Selection (from main repo, no NAME argument)

```
Select worktree to delete:
  1) london (wt/london)
  2) paris (feature/auth)
  0) Cancel

Choice:
```

#### Deletion Options

| Selection | Action |
|-----------|--------|
| 1 | Delete worktree and branch (both local and remote if exists) |
| 2 | Delete worktree only, keep branch |
| 0 | Cancel operation |

### Environment Variables

| Variable | Effect |
|----------|--------|
| NO_COLOR | If set, suppress colored output |

---

## wt-pr

### Command Synopsis

```
wt-pr [OPTIONS]
wt-pr help
```

### Arguments

None - operates on current branch.

### Options

| Option | Short | Description |
|--------|-------|-------------|
| `--draft` | `-d` | Create draft PR without menu (non-interactive) |
| `--ready` | `-r` | Create ready PR without menu (non-interactive) |
| `--push` | `-p` | Just push branch without creating PR |
| `--no-summary` | | Skip change summary display |
| `help` | | Display usage information |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success - PR created or branch pushed |
| 1 | General error (no commits, gh not available for merge, etc.) |
| 2 | Invalid arguments |
| 3 | Git/GitHub operation failed |

### Output Format

#### Change Summary (before menu)

```
Changes to be included in PR:

Branch: wt/london → main
Commits: 3
  abc1234 Add authentication endpoint
  def5678 Add login tests
  ghi9012 Update README

Files: 5 changed, 147 insertions(+), 23 deletions(-)
  src/auth.py          | 87 +++++++++++++
  src/routes.py        | 15 ++-
  tests/test_auth.py   | 45 +++++++
  README.md            | 12 +-
  requirements.txt     |  2 +
```

#### Success Output (interactive)

```
[Change summary as above]

Create PR:
  1) Draft PR
  2) Ready PR
  3) Just push (no PR)
  0) Cancel

Choice: 1

Pushing branch wt/london to origin...
Creating draft PR...

PR created: https://github.com/owner/repo/pull/123

Open in browser?
  1) Yes
  0) No

Choice:
```

#### PR Already Exists

```
PR already exists for branch wt/london:

  #123: Add authentication feature
  Status: Open (Draft)
  URL: https://github.com/owner/repo/pull/123

  1) Open in browser
  2) Mark as ready (if draft)
  0) Exit

Choice:
```

#### Non-Interactive Output (`--draft` or `--ready`)

```
Pushing branch wt/london to origin...
Creating draft PR...
PR created: https://github.com/owner/repo/pull/123
```

#### No Changes Error

```
Error: No changes to create PR
  Why: Branch wt/london has no commits ahead of main
  Fix: Make some commits first, then run wt-pr
```

#### gh Not Available (browser fallback)

```
Note: gh CLI not found, opening browser for PR creation

Opening: https://github.com/owner/repo/compare/main...wt/london?expand=1
```

### Environment Variables

| Variable | Effect |
|----------|--------|
| NO_COLOR | If set, suppress colored output |
| BROWSER | Override browser for URL opening |

---

## wt-merge

### Command Synopsis

```
wt-merge [OPTIONS]
wt-merge help
```

### Arguments

None - operates on PR for current branch.

### Options

| Option | Short | Description |
|--------|-------|-------------|
| `--delete-worktree` | `-d` | Auto-delete worktree and remote branch after merge |
| `--force` | `-f` | Merge even if checks are failing (if repo allows) |
| `help` | | Display usage information |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success - PR merged |
| 1 | General error (no PR, gh not available, etc.) |
| 2 | Invalid arguments |
| 3 | Merge failed (conflicts, blocked, etc.) |

### Output Format

#### PR Status Display

```
PR #123: Add authentication feature

Status: Open
Checks: ✓ 5 passed
Review: Approved by @reviewer
Mergeable: Yes

Merge this PR?
  1) Merge (using repo default: squash)
  2) Merge and delete worktree
  0) Cancel

Choice:
```

#### Checks Failing Warning

```
PR #123: Add authentication feature

Status: Open
Checks: ✗ 2 failed, ✓ 3 passed
  ✗ ci/build - Build failed
  ✗ ci/lint - Linting errors
Review: Approved by @reviewer
Mergeable: Blocked (checks failing)

Warning: PR has failing checks

  1) Wait for checks (show status)
  2) Merge anyway (if permitted)
  0) Cancel

Choice:
```

#### Not Approved Warning

```
PR #123: Add authentication feature

Status: Open
Checks: ✓ 5 passed
Review: Changes requested by @reviewer
Mergeable: Blocked (not approved)

Warning: PR is not approved

  1) Open PR in browser (to address feedback)
  0) Cancel

Choice:
```

#### Success Output

```
Merging PR #123...

PR merged successfully!

Delete worktree and branch?
  1) Yes (delete local worktree and remote branch)
  2) Keep worktree and branch
  0) Exit

Choice: 1

Deleted worktree: london
Deleted branch: wt/london (local)
Deleted branch: wt/london (remote)

Run: cd /Users/name/code/myproject
```

#### No PR Exists

```
Error: No PR found for branch wt/london
  Why: A pull request must exist before merging
  Fix: Run 'wt-pr' first to create a PR

Create PR now?
  1) Create draft PR
  2) Create ready PR
  0) Cancel

Choice:
```

#### gh Not Available Error

```
Error: gh CLI required for merging
  Why: wt-merge uses the GitHub API via gh to merge PRs
  Fix: Install gh CLI: brew install gh (macOS) or apt install gh (Linux)
```

### Environment Variables

| Variable | Effect |
|----------|--------|
| NO_COLOR | If set, suppress colored output |

---

## Shared Contracts

### Error Message Format

All scripts use the Constitution III compliant `what/why/fix` format:

```
Error: <what failed>
  Why: <explanation of why it failed>
  Fix: <actionable suggestion to resolve>
```

### Menu Conventions

- Numbered options start at 1
- Option 0 always means "Cancel" or "Exit"
- Empty input (Enter) treated as 0
- Invalid input shows error and re-prompts

### Git Repository Validation

All scripts verify git repository context before proceeding:

```
Error: Not a git repository
  Why: wt-<command> requires a git repository
  Fix: Navigate to a git repository and try again
```

### Cross-Platform Support

| Feature | macOS | Linux |
|---------|-------|-------|
| Browser open | `open <url>` | `xdg-open <url>` |
| Clipboard | `pbcopy` | `xclip -selection clipboard` |
| Path handling | BSD tools | GNU tools |
