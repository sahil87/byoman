---
allowed-tools: Bash(git:*), Bash(gh:*)
description: Create a GitHub pull request from the current branch
---

## Your task

Create a GitHub PR from the current branch. First, gather context:

```bash
git status
git branch --show-current
git log --oneline -5
```

Then:

1. **Check for uncommitted changes**: If there are uncommitted changes (staged or unstaged), automatically invoke `/changes.commit` first to commit them before proceeding

2. **Check for existing PR**:
   ```bash
   gh pr view --json url,state,title,number,isDraft 2>/dev/null
   ```
   If a PR exists, show its details and offer to open it in browser

3. **Check for commits**: Ensure the branch has commits ahead of main/master

4. **Show change summary**:
   - Branch name and target (main)
   - Commit count and list
   - Files changed summary

5. **Ask user**: Draft PR, Ready PR, or Just push?

6. **Push if needed**:
   ```bash
   git push -u origin <branch>
   ```

7. **Create PR**:
   ```bash
   gh pr create --draft --fill  # for draft
   gh pr create --fill          # for ready
   ```

8. **Offer to open in browser**
