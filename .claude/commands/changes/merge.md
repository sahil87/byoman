---
allowed-tools: Bash(git:*), Bash(gh:*)
description: Merge PR and optionally cleanup worktree
---

## Your task

Merge the PR for the current branch and optionally clean up the worktree. First, gather context:

```bash
git status
git branch --show-current
```

Then:

1. **Check for uncommitted changes**: If there are uncommitted changes (staged or unstaged), automatically invoke `/changes.commit` first to commit them before proceeding

2. **Get PR status**:
   ```bash
   gh pr view --json number,title,state,mergeable,mergeStateStatus,statusCheckRollup,reviewDecision,url
   ```
   If no PR exists, suggest creating one with `/pr`

3. **Display PR status**:
   - PR number and title
   - Check status (passed/failed/pending counts)
   - Review status (approved/changes requested/pending)
   - Mergeable status (clean/blocked/has conflicts)

4. **Handle blockers**:
   - If checks failing: Ask if user wants to wait or merge anyway
   - If changes requested: Suggest opening PR in browser
   - If conflicts: Tell user to resolve conflicts first

5. **Ask user**: Merge, or Merge and delete worktree?

6. **Merge PR**:
   ```bash
   gh pr merge                  # basic merge
   gh pr merge --delete-branch  # merge + delete remote branch
   ```

7. **Cleanup worktree** (if requested and in a worktree):
   ```bash
   git worktree remove --force <worktree-path>
   git branch -D <branch>
   ```
   Tell user to `cd` back to main repo
