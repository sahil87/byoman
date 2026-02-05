---
allowed-tools: Bash(git:*)
description: Create a git commit with a meaningful message
---

## Your task

Create a git commit. Gather context first:

```bash
git status
git diff HEAD
git branch --show-current
git log --oneline -5
```

Then:

1. **Analyze changes**: Understand what was modified and why
2. **Match commit style**: Use the existing commit message style from `git log`
3. **Stage changes**: Add relevant files (prefer specific files over `git add -A`)
4. **Commit**: Write a concise commit message that explains the "why" not just the "what"

**Note**: Skip the "Co-Authored-By: Claude" line in commit messages.
