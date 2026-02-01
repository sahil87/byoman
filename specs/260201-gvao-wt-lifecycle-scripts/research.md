# Research: Worktree Lifecycle Scripts

**Date**: 2026-02-01 | **Plan**: [plan.md](plan.md)

## 1. Git Worktree Removal Best Practices

**Decision**: Use `git worktree remove <path>` with `--force` flag for uncommitted changes after user confirmation.

**Rationale**:
- `git worktree remove` is the recommended way to remove worktrees (vs manual `rm -rf`)
- Properly updates `.git/worktrees/` metadata and releases the branch lock
- `--force` flag handles uncommitted changes but requires explicit user consent

**Alternatives considered**:
- `rm -rf` + `git worktree prune`: Works but leaves metadata inconsistent until prune runs
- `git worktree remove --force` always: Dangerous, could lose work without warning

**Key findings**:
```bash
# Standard removal (fails if uncommitted changes)
git worktree remove /path/to/worktree

# Force removal (destroys uncommitted changes)
git worktree remove --force /path/to/worktree

# List worktrees (for validation)
git worktree list --porcelain  # Machine-readable format
```

## 2. Directory Change When Deleting Current Worktree

**Decision**: Detect if inside worktree being deleted, use `cd` to main repo via OLDPWD or explicit path before removal.

**Rationale**:
- Shell cannot remain in a deleted directory
- User expects to land in a sensible location (main repo, not random)
- Parent shell's directory must be updated (requires exec or subshell handling)

**Alternatives considered**:
- Exit with message asking user to cd manually: Poor UX, extra step
- cd to home directory: Unexpected, loses git context

**Key findings**:
```bash
# Detect if in worktree
git rev-parse --git-common-dir  # Returns main repo .git path from any worktree

# Get main repo root from worktree
main_repo=$(git rev-parse --git-common-dir | sed 's|/\.git$||' | sed 's|/\.git/worktrees/.*$||')

# Script cannot change parent shell's directory directly
# Options:
# 1. Print cd command for user to eval: `eval "$(wt-delete)"`
# 2. Use exec to replace shell: Complex, breaks script flow
# 3. Print instruction: "Run: cd <path>" - cleanest approach for this use case
```

**Recommendation**: Print the cd command after deletion. The script will output:
```
Worktree 'london' deleted.
You are no longer in a valid directory.
Run: cd /path/to/main-repo
```

## 3. GitHub CLI (gh) PR Operations

**Decision**: Use `gh pr create` for PR creation, `gh pr merge` for merging. Fall back to browser URL for creation only.

**Rationale**:
- `gh` is the official GitHub CLI with robust PR support
- API-based operations are more reliable than screen-scraping
- Fallback URL ensures `wt-pr` works even without `gh` installed

**Alternatives considered**:
- curl to GitHub API directly: Complex auth handling, reinvents wheel
- Open browser always: No automation benefit

**Key findings**:
```bash
# Check if gh is installed and authenticated
gh auth status &>/dev/null

# Create draft PR
gh pr create --draft --title "Title" --body "Description"

# Create ready PR
gh pr create --title "Title" --body "Description"

# Check for existing PR
gh pr view --json url,state --jq '.url' 2>/dev/null

# Get PR status (checks, approvals)
gh pr status --json state,statusCheckRollup,reviewDecision

# Merge PR with repo default method
gh pr merge --auto  # Uses repo's configured merge method

# Merge methods (if explicit needed)
gh pr merge --merge    # Merge commit
gh pr merge --squash   # Squash and merge
gh pr merge --rebase   # Rebase and merge

# Delete remote branch after merge
gh pr merge --delete-branch
```

## 4. Browser Fallback URL Format for PR Creation

**Decision**: Use GitHub's pre-filled PR URL format with query parameters.

**Rationale**:
- Works without `gh` CLI
- Opens in user's default browser
- Preserves draft/ready intent via URL

**Key findings**:
```bash
# GitHub PR creation URL format
# https://github.com/{owner}/{repo}/compare/{base}...{head}?expand=1

# With pre-filled title and body
# https://github.com/{owner}/{repo}/compare/{base}...{head}?expand=1&title=URL_ENCODED_TITLE&body=URL_ENCODED_BODY

# Get remote URL
remote_url=$(git remote get-url origin)

# Convert SSH to HTTPS for browser
# git@github.com:owner/repo.git → https://github.com/owner/repo
repo_url=$(echo "$remote_url" | sed -e 's|git@github.com:|https://github.com/|' -e 's|\.git$||')

# Get default branch
default_branch=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')

# Build PR URL
pr_url="${repo_url}/compare/${default_branch}...${current_branch}?expand=1"

# Open in browser (cross-platform)
# macOS
open "$pr_url"
# Linux
xdg-open "$pr_url"
```

## 5. Change Summary Display (git diff --stat)

**Decision**: Use `git diff` and `git log` for change summary before PR creation.

**Rationale**:
- Mirrors what user would see in PR
- Helps user verify they're PRing the right changes
- Follows Conductor pattern (⌘D diff viewer)

**Key findings**:
```bash
# Files changed, insertions, deletions (summary)
git diff --stat origin/main...HEAD

# Commit count
git rev-list --count origin/main..HEAD

# Short log of commits
git log --oneline origin/main..HEAD

# Combined summary format
echo "Changes to be included in PR:"
echo "  Commits: $(git rev-list --count origin/main..HEAD)"
git diff --shortstat origin/main...HEAD | sed 's/^ /  /'
```

## 6. Detecting Worktree Context

**Decision**: Use `git rev-parse` commands to detect worktree vs main repo context.

**Rationale**:
- Reliable git-native approach
- Works with nested worktrees
- No assumptions about directory structure

**Key findings**:
```bash
# Check if in a worktree (vs main repo)
is_worktree() {
    local git_dir common_dir
    git_dir=$(git rev-parse --git-dir 2>/dev/null)
    common_dir=$(git rev-parse --git-common-dir 2>/dev/null)

    # In worktree: .git is a file (not dir) pointing to main repo
    # OR git-dir != git-common-dir
    [[ "$git_dir" != "$common_dir" ]]
}

# Get worktree name from path
# /path/to/repo-worktrees/london → london
worktree_name() {
    basename "$(pwd)"
}

# List all worktrees
git worktree list --porcelain | grep '^worktree ' | cut -d' ' -f2-
```

## 7. Stash Handling for Uncommitted Changes

**Decision**: Offer stash option before deletion, with clear naming for recovery.

**Rationale**:
- Preserves user's work if they want to move it
- Named stash makes recovery discoverable
- Matches user expectation of "save my work"

**Key findings**:
```bash
# Check for uncommitted changes
has_uncommitted_changes() {
    ! git diff --quiet || ! git diff --cached --quiet
}

# Check for untracked files
has_untracked_files() {
    [[ -n $(git ls-files --others --exclude-standard) ]]
}

# Stash with descriptive name
git stash push -m "wt-delete: saved from worktree 'london' on $(date +%Y-%m-%d)"

# Stash including untracked
git stash push -u -m "wt-delete: saved from worktree 'london' on $(date +%Y-%m-%d)"

# List stashes (for recovery help)
git stash list
```

## 8. Branch Deletion Safety

**Decision**: Warn about unpushed commits before branch deletion; require explicit confirmation for remote branch deletion.

**Rationale**:
- Unpushed commits would be lost forever
- Remote branch deletion affects team visibility
- Separate confirmation for local vs remote deletion

**Key findings**:
```bash
# Check if branch has unpushed commits
has_unpushed_commits() {
    local branch="$1"
    local upstream
    upstream=$(git rev-parse --abbrev-ref "${branch}@{upstream}" 2>/dev/null) || return 1
    [[ -n $(git log "${upstream}..${branch}" --oneline 2>/dev/null) ]]
}

# Check if branch is pushed to remote
branch_on_remote() {
    local branch="$1"
    git ls-remote --heads origin "$branch" 2>/dev/null | grep -q "$branch"
}

# Delete local branch (safe - fails if not merged)
git branch -d "$branch"

# Delete local branch (force)
git branch -D "$branch"

# Delete remote branch
git push origin --delete "$branch"
```

## 9. PR Status and Merge Readiness

**Decision**: Use `gh pr view` JSON output for structured status checking.

**Rationale**:
- Single API call gets all needed info
- JSON output is easily parsed
- Avoids screen-scraping or multiple calls

**Key findings**:
```bash
# Get comprehensive PR status
gh pr view --json number,title,state,mergeable,mergeStateStatus,statusCheckRollup,reviewDecision

# Key fields:
# - state: OPEN, CLOSED, MERGED
# - mergeable: MERGEABLE, CONFLICTING, UNKNOWN
# - mergeStateStatus: CLEAN, DIRTY, UNSTABLE, BLOCKED
# - statusCheckRollup: Array of check statuses
# - reviewDecision: APPROVED, CHANGES_REQUESTED, REVIEW_REQUIRED

# Check if PR can be merged
can_merge() {
    local status
    status=$(gh pr view --json mergeable,mergeStateStatus --jq '.mergeable + ":" + .mergeStateStatus')
    [[ "$status" == "MERGEABLE:CLEAN" ]]
}

# Get check status summary
gh pr view --json statusCheckRollup --jq '.statusCheckRollup | group_by(.conclusion) | map({(.[0].conclusion): length}) | add'
```

## Summary of Decisions

| Topic | Decision | Key Rationale |
|-------|----------|---------------|
| Worktree removal | `git worktree remove` with `--force` after confirmation | Proper cleanup, user safety |
| Directory change | Print `cd` instruction | Cannot change parent shell; clean UX |
| PR operations | `gh` CLI with browser fallback | Official tool, graceful degradation |
| Change summary | `git diff --stat` + commit count | User verification before PR |
| Worktree detection | `git rev-parse` commands | Reliable, git-native |
| Uncommitted changes | Offer stash with descriptive name | Preserve work, easy recovery |
| Branch deletion | Warn unpushed, separate remote confirm | Safety, team awareness |
| PR status | `gh pr view` JSON | Single call, structured data |
