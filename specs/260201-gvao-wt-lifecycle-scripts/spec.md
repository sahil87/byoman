# Feature Specification: Worktree Lifecycle Scripts

**Feature Branch**: `260201-gvao-wt-lifecycle-scripts`
**Created**: 2026-02-01
**Status**: Draft
**Input**: User description: "Scripts for worktree lifecycle management: wt-delete to remove worktrees, wt-pr to create PRs from current branch, and wt-merge to merge current branch. Should follow existing wt-create patterns including numbered menus, what/why/fix errors, and cross-platform support."
**Invocation**: `wt-delete`, `wt-pr`, `wt-merge` standalone shell scripts (independent of speckit, companion to `wt-create`)

## Research: Conductor.build Patterns

Based on [Conductor](https://conductor.build) workflow analysis, the following patterns inform this spec:

| Conductor Feature | Our Approach | Notes |
| ----------------- | ------------ | ----- |
| Workspace archiving | Delete with "keep branch" option | Git branches are cheap; archiving = keeping branch |
| PR creation (⌘⇧P) | `wt-pr` command | Same goal, CLI-based |
| Diff viewer (⌘D) | Show change summary before PR | Added as FR-035 |
| Create from PR/Linear | `wt-create` enhancement | Separate follow-up |
| Failed checks help | Warning + status display | Already in `wt-merge` |

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Delete Worktree (Priority: P1)

A developer has finished working on a feature in a worktree (e.g., "prague") and wants to clean it up. They run `wt-delete` from within the worktree, and after confirmation, the worktree directory is removed and optionally the associated branch is deleted.

**Why this priority**: Worktree cleanup is essential for disk space management and reducing clutter. Without easy deletion, worktrees accumulate and create confusion. This directly complements `wt-create`.

**Independent Test**: Can be fully tested by creating a worktree with `wt-create`, then running `wt-delete` from within it and verifying both the directory and branch are properly cleaned up.

**Acceptance Scenarios**:

1. **Given** a user is in a worktree directory, **When** they run `wt-delete`, **Then** a confirmation prompt shows the worktree name and branch to be deleted
2. **Given** the user confirms deletion, **When** the worktree has no uncommitted changes, **Then** the worktree is removed and user is returned to the main repository
3. **Given** a worktree has uncommitted changes, **When** user runs `wt-delete`, **Then** a warning is displayed with options: save changes (stash), discard changes, or abort
4. **Given** the branch has been pushed to remote, **When** user confirms deletion, **Then** user is asked whether to also delete the remote branch

---

### User Story 2 - Create Pull Request (Priority: P1)

A developer has completed work in their worktree and wants to create a PR. They run `wt-pr` and first see a summary of their changes (files changed, commits), then are presented with options: draft PR, regular PR, or just push (no PR). The script handles pushing the branch and opening the PR creation page or using `gh` CLI.

**Why this priority**: Creating PRs is the most common next step after development. Reducing friction here directly supports the parallel development workflow that worktrees enable.

**Independent Test**: Can be tested by creating changes in a worktree, running `wt-pr`, and verifying a PR is created with the correct branch and base.

**Acceptance Scenarios**:

1. **Given** a user is in a worktree with commits not on remote, **When** they run `wt-pr`, **Then** a change summary is displayed (files changed, commit count, insertions/deletions)
2. **Given** the change summary is displayed, **When** user proceeds, **Then** a numbered menu shows options: 1) Draft PR, 2) Ready PR, 3) Just Push, 0) Cancel
3. **Given** user selects Draft or Ready PR, **When** the branch is not pushed, **Then** the script pushes the branch first, then creates the PR
4. **Given** a PR already exists for this branch, **When** user runs `wt-pr`, **Then** the script shows the existing PR URL and offers to open it in browser
5. **Given** user selects an option, **When** PR is created successfully, **Then** the PR URL is displayed and optionally opened in browser

---

### User Story 3 - Merge Branch (Priority: P2)

A developer has an approved PR and wants to merge it quickly without navigating to the GitHub UI. They run `wt-merge` and the script completes the merge via the GitHub API (using `gh`).

**Why this priority**: Merging is less frequent than PR creation but still valuable for completing the workflow without context-switching to browser.

**Independent Test**: Can be tested by creating a PR, getting it approved, then running `wt-merge` and verifying the PR is merged and branch is optionally deleted.

**Acceptance Scenarios**:

1. **Given** a user is in a worktree with an open PR, **When** they run `wt-merge`, **Then** the PR status is displayed (checks passed/failed, approvals)
2. **Given** the PR has passed checks and is approved, **When** user confirms merge, **Then** the PR is merged using the repository's default merge method
3. **Given** the PR has failing checks or is not approved, **When** user runs `wt-merge`, **Then** a warning is shown with options: wait, merge anyway (if permitted), or abort
4. **Given** the merge completes successfully, **When** prompted, **Then** user can choose to delete the local worktree and remote branch

---

### User Story 4 - Delete Worktree by Name (Priority: P2)

A developer is in their main repository (not in a worktree) and wants to delete a specific worktree. They run `wt-delete <name>` (e.g., `wt-delete prague`) and the specified worktree is removed.

**Why this priority**: Useful for cleanup from the main repo without navigating into each worktree, but less common than deleting the current worktree.

**Independent Test**: Can be tested by running `wt-delete <name>` from the main repo and verifying the specified worktree is removed.

**Acceptance Scenarios**:

1. **Given** a user is in the main repository, **When** they run `wt-delete prague`, **Then** the worktree named "prague" is identified and confirmation is shown
2. **Given** the specified worktree doesn't exist, **When** user runs the command, **Then** an error message lists available worktrees

---

### User Story 5 - List Worktrees (Priority: P3)

A developer wants to see all their active worktrees. They run `wt-delete --list` or `wt-list` and see a list of worktrees with their branches and paths.

**Why this priority**: Discoverability and management, but lower priority since `git worktree list` already provides this.

**Independent Test**: Can be tested by creating multiple worktrees and verifying the list command shows all of them with correct information.

**Acceptance Scenarios**:

1. **Given** multiple worktrees exist, **When** user runs `wt-delete --list`, **Then** all worktrees are displayed with name, branch, and path
2. **Given** no worktrees exist, **When** user runs the list command, **Then** a message indicates no worktrees are found

---

### Edge Cases

- What happens when user runs `wt-delete` from the main repository without specifying a name? → Show list of worktrees and prompt for selection
- What happens when the worktree's branch has unpushed commits? → Warn user and require explicit confirmation to delete
- What happens when `gh` CLI is not installed and user tries `wt-pr`? → Fall back to opening GitHub URL in browser with pre-filled PR form
- What happens when user runs `wt-merge` but no PR exists for the branch? → Offer to create a PR first
- What happens when trying to delete the currently checked-out worktree? → Script changes directory to main repo before deletion
- What happens when the branch has been merged but worktree still exists? → Offer to clean up the stale worktree
- What happens when multiple PRs exist for the same branch? → Show list and prompt for selection (edge case, GitHub typically prevents this)

## Clarifications

### Session 2026-02-01

- Q: When a user runs `wt-pr --draft` (non-interactive), how should the PR title/body be determined? → A: Auto-generate from branch name (title) and commit messages (body)
- Q: When a user runs `wt-merge --delete-worktree`, should the remote branch also be deleted automatically? → A: Yes, delete both local worktree AND remote branch (full cleanup)

## Requirements *(mandatory)*

### Functional Requirements - wt-delete

- **FR-001**: Script MUST detect if running from within a worktree or main repository
- **FR-002**: Script MUST require confirmation before deleting a worktree
- **FR-003**: Script MUST warn if the worktree has uncommitted changes and offer: stash, discard, or abort
- **FR-004**: Script MUST warn if the branch has unpushed commits
- **FR-005**: Script MUST use `git worktree remove` for proper cleanup
- **FR-006**: Script MUST offer to delete the associated branch (local and remote) after worktree removal
- **FR-007**: Script MUST change directory to main repository if deleting the current worktree
- **FR-008**: Script MUST accept an optional worktree name argument to delete a specific worktree
- **FR-009**: Script MUST show a list of available worktrees when name is ambiguous or not found
- **FR-010**: Script MUST provide `--force` flag to skip confirmation (for scripting)
- **FR-011**: Script MUST provide `--list` flag to show all worktrees

### Functional Requirements - wt-pr

- **FR-012**: Script MUST detect the current branch and any existing PR for it
- **FR-013**: Script MUST display a numbered menu with options: Draft PR, Ready PR, Just Push, Cancel
- **FR-014**: Script MUST push the branch to remote if not already pushed
- **FR-015**: Script MUST use `gh` CLI to create PRs when available
- **FR-016**: Script MUST fall back to opening browser with pre-filled PR URL when `gh` is not available
- **FR-017**: Script MUST detect the repository's default branch for PR base
- **FR-018**: Script MUST show existing PR URL if one already exists for the branch
- **FR-019**: Script MUST offer to open the created/existing PR in browser
- **FR-020**: Script MUST accept `--draft` and `--ready` flags to skip the menu
- **FR-037**: When using `--draft` or `--ready` flags, Script MUST auto-generate PR title from branch name and PR body from commit messages (matching `gh pr create` default behavior)
- **FR-035**: Script MUST display a change summary before showing the menu: files changed, commit count, insertions/deletions (like `git diff --stat`)
- **FR-036**: Script MUST accept `--no-summary` flag to skip the change summary (for scripting)

### Functional Requirements - wt-merge

- **FR-021**: Script MUST detect if a PR exists for the current branch
- **FR-022**: Script MUST display PR status: checks, approvals, merge conflicts
- **FR-023**: Script MUST use `gh pr merge` to perform the merge
- **FR-024**: Script MUST use the repository's configured default merge method (merge, squash, rebase)
- **FR-025**: Script MUST warn if checks are failing or PR is not approved
- **FR-026**: Script MUST offer to delete local worktree and remote branch after successful merge
- **FR-027**: Script MUST handle the case where no PR exists by offering to create one
- **FR-028**: Script MUST provide `--delete-worktree` flag to auto-cleanup after merge (deletes local worktree AND remote branch)

### Shared Requirements

- **FR-029**: All scripts MUST follow the `what/why/fix` error message format (Constitution III)
- **FR-030**: All scripts MUST use numbered menus (Conductor-style) for options
- **FR-031**: All scripts MUST provide `help` subcommand for usage information
- **FR-032**: All scripts MUST be standalone POSIX-compliant shell scripts
- **FR-033**: All scripts MUST use consistent exit codes matching `wt-create`: 0=success, 1=general error, 2=invalid args, 3=git error
- **FR-034**: All scripts MUST detect they are in a git repository and report clearly if not

### Key Entities

- **Worktree**: An additional working tree linked to the repository, identified by name (e.g., "prague") and path
- **Branch**: The git branch associated with a worktree; may have local/remote state and unpushed commits
- **Pull Request**: A GitHub PR associated with a branch; has status (draft/ready), checks, and approvals
- **Main Repository**: The primary git repository from which worktrees are created

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can delete a worktree in under 30 seconds including confirmation
- **SC-002**: Users can create a PR from a worktree in under 20 seconds with a single command
- **SC-003**: 100% of deletion operations properly clean up both worktree directory and associated git references
- **SC-004**: Users receive clear warnings before any destructive action (uncommitted changes, unpushed commits)
- **SC-005**: Scripts provide actionable error messages following the `what/why/fix` format
- **SC-006**: Users can complete the full worktree lifecycle (create → develop → PR → merge → delete) using only the `wt-*` scripts

## Assumptions

The following assumptions are made based on the existing `wt-create` patterns:

1. **Script Location**: Scripts will be installed alongside `wt-create` in the user's PATH

2. **gh CLI**: The `gh` CLI is the preferred method for GitHub operations (PR creation, merge). Scripts gracefully degrade when `gh` is not available by:
   - `wt-pr`: Falls back to opening browser with pre-filled PR URL
   - `wt-merge`: Requires `gh` CLI (no fallback - merging via API is the whole point)

3. **Error Handling**: All scripts use the `what/why/fix` error format from the project Constitution

4. **Menu Style**: All scripts use numbered menus (Conductor-style) for consistency with `wt-create`

5. **Confirmation Default**: All destructive operations require explicit confirmation; `--force` overrides for scripting

6. **Branch Cleanup**: After worktree deletion, users are offered (not forced) to delete the branch locally and remotely

7. **PR Base Branch**: PRs are created against the repository's default branch (main/master), detected automatically

## Dependencies

- **gh CLI**: Required for `wt-merge`, optional (with fallback) for `wt-pr`. Installation: `brew install gh` (macOS), `apt install gh` (Linux)
- **wt-create**: Companion script; these scripts assume worktrees created by `wt-create` but work with any git worktree

## Follow-ups

- **wt-create enhancement**: Add support for creating worktrees from existing PRs (`wt-create --pr 123`) and Linear issues (`wt-create --linear ABC-123`). This enables Conductor-style "create workspace from PR" workflow for code review scenarios.

## Out of Scope

- Automated branch naming based on PR title (users name branches via `wt-create` or git)
- PR templates or commit message generation
- CI/CD integration or status monitoring beyond what `gh` provides
- Multi-repo worktree management
- Conflict resolution (deferred to user's git workflow)
- Squash/rebase preferences per-PR (uses repo default)
