# Feature Specification: Speckit Branch Naming Integration

**Feature Branch**: `260201-krgf-speckit-branch-naming`
**Created**: 2026-02-01
**Status**: Draft
**Input**: User description: "Standardize branch naming by having speckit.specify rename temporary worktree branches to canonical feature branch names"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Auto-rename Branch from Feature Description (Priority: P1)

A developer creates a new worktree using `wt create`, which assigns a temporary branch name like `wt/amsterdam`. They then run `speckit specify "Add user authentication"` to define their feature. The system automatically renames the branch from the temporary name to a canonical name derived from the spec (e.g., `260201-krgf-user-auth`).

**Why this priority**: This is the core workflow - most users will start with a temporary worktree and need their branch name to reflect their actual work. Without this, branch names remain meaningless random strings.

**Independent Test**: Can be fully tested by creating a worktree, running speckit.specify with a feature description, and verifying the branch name changed to match the feature.

**Acceptance Scenarios**:

1. **Given** a worktree with branch `wt/amsterdam`, **When** user runs `speckit specify "Add user authentication"`, **Then** the branch is renamed to the spec name (e.g., `260201-krgf-user-auth`)
2. **Given** a worktree with branch `wt/random123`, **When** user runs `speckit specify "Fix payment timeout"`, **Then** the branch is renamed to reflect the feature
3. **Given** a worktree with branch `wt/temp`, **When** speckit.specify completes successfully, **Then** the user sees a message indicating the branch was renamed and the new branch name

---

### User Story 2 - Use Linear Branch Name Directly (Priority: P2)

A developer has a Linear issue with a suggested branch name like `feature/dev-907-byoman`. When running `speckit specify`, they can provide this Linear branch name, and the system uses it directly instead of generating one.

**Why this priority**: Many teams use Linear's branch naming convention for traceability. Supporting this avoids forcing users to abandon their existing workflow.

**Independent Test**: Can be tested by running speckit.specify with a Linear branch name parameter and verifying the branch is renamed to that exact name.

**Acceptance Scenarios**:

1. **Given** a worktree with temporary branch, **When** user runs `speckit specify --branch "feature/dev-907-byoman" "Implement user dashboard"`, **Then** the branch is renamed to `feature/dev-907-byoman`
2. **Given** a user provides a custom branch name via `--branch`, **When** speckit.specify runs, **Then** it uses that name after applying standard sanitization (spaces → hyphens, invalid chars removed)
3. **Given** a user provides a custom branch name, **When** the branch name conflicts with existing remote branches, **Then** the user is warned but can proceed

---

### User Story 3 - Keep Existing Canonical Branch (Priority: P3)

A developer is already on a canonical branch (not `wt/*` pattern) and runs `speckit specify`. The system recognizes the branch is already canonical and keeps it unchanged.

**Why this priority**: Prevents unnecessary branch renames when the user has already set up their branch correctly, and supports the workflow where multiple features may use the same branch.

**Independent Test**: Can be tested by running speckit.specify on a non-temporary branch and verifying it remains unchanged.

**Acceptance Scenarios**:

1. **Given** a worktree with branch `feature/existing-feature`, **When** user runs `speckit specify "New feature work"`, **Then** the branch name remains `feature/existing-feature`
2. **Given** a worktree with branch `main`, **When** user runs `speckit specify`, **Then** the system warns that working on main is not recommended but does not force a rename
3. **Given** a worktree with canonical branch, **When** speckit.specify completes, **Then** the user sees a message that the existing branch was preserved

---

### Edge Cases

- What happens when the generated branch name already exists locally? System appends a numeric suffix (e.g., `-2`) and informs the user.
- What happens when the branch name already exists on remote? System warns but allows the user to proceed (they may want to continue work on that branch).
- What happens when user has uncommitted changes during branch rename? Git's `branch -m` handles this safely; system proceeds with rename.
- What happens when user runs speckit.specify multiple times on the same worktree? Only the first run (when on temporary branch) renames; subsequent runs preserve the branch.
- What happens when branch name contains invalid git characters? System sanitizes the name (replace spaces with hyphens, remove special characters like `~`, `^`, `:`, `?`, `*`, `[`).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST detect if current branch follows the temporary pattern (`wt/*`)
- **FR-002**: System MUST generate a canonical branch name from the spec name (e.g., `260201-krgf-speckit-branch-naming`)
- **FR-003**: System MUST rename the branch using `git branch -m` when on a temporary branch
- **FR-004**: System MUST preserve the existing branch name when already on a canonical branch (not matching `wt/*` pattern), unless the user explicitly provides a `--branch` flag
- **FR-005**: System MUST support an optional `--branch` flag to specify a custom branch name; when provided, this flag overrides both auto-generation and the preserve-canonical rule
- **FR-006**: System MUST sanitize all branch names (including user-provided `--branch` values) to comply with git naming rules: replace spaces with hyphens, remove invalid characters (`~`, `^`, `:`, `?`, `*`, `[`)
- **FR-007**: System MUST display the old and new branch name to the user after rename
- **FR-008**: When target branch name already exists locally, system MUST auto-append a numeric suffix (e.g., `-2`) and inform the user of the adjusted name; when target exists only on remote, system MUST warn but proceed with the local rename. For auto-generated branch names, system MUST proactively check remote existence (via `git ls-remote`) before rename; for user-provided `--branch` values, skip remote check (assume user coordination)
- **FR-009**: System MUST handle the rename atomically - if rename fails, the spec creation should still succeed with the original branch name
- **FR-010**: System MUST warn when user is on `main` or `master` branch
- **FR-011**: After successful rename, system MUST prompt user whether to push new branch to remote and set up tracking. If no git remote is configured, skip the push prompt entirely

### Key Entities

- **Temporary Branch**: A branch matching the pattern `wt/*`, created by `wt-create` as a placeholder
- **Canonical Branch**: A descriptive branch name that reflects the feature work, either auto-generated from the spec or provided by the user
- **Spec Name**: The unique identifier for a spec (e.g., `260201-krgf-speckit-branch-naming`) used as the auto-generated branch name

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After running speckit.specify on a temporary branch, 100% of resulting branch names are human-readable and reflect the feature being worked on
- **SC-002**: Users can identify what feature a branch contains by looking at its name without needing to inspect the code or spec
- **SC-003**: Developers who use Linear can continue using Linear's branch naming convention without friction via the `--branch` flag
- **SC-004**: Zero data loss or uncommitted change loss during branch rename operations
- **SC-005**: Branch naming operation adds minimal overhead to the speckit.specify workflow

## Assumptions

- Git worktree and branch operations are available in the environment
- The `wt/*` pattern is reserved exclusively for temporary worktree branches created by `wt-create`
- Users accept that running speckit.specify will modify their branch name if it matches the temporary pattern
- The spec name format (`YYMMDD-XXXX-short-name`) is stable and suitable for use as branch names
- Branch names generated from spec names will be valid git branch names (the spec naming scheme already produces compatible names)

## Clarifications

### Session 2026-02-01

- Q: When generated branch name already exists locally, what should happen? → A: Auto-append numeric suffix (e.g., `-2`) without prompting
- Q: If user is on canonical branch and explicitly passes `--branch`, should system rename? → A: Yes, explicit `--branch` flag overrides preserve rule (user intent wins)
- Q: Should branch rename also push to remote and set up tracking? → A: Prompt user after rename whether to push
- Q: If user provides `--branch` with invalid chars (e.g., spaces), what happens? → A: Sanitize silently (spaces → hyphens, remove invalid chars)
- Q: When should system check if branch exists on remote (FR-008)? → A: Proactive check for auto-generated names; skip for user-provided `--branch` (assumes user coordination)
- Q: What if no git remote is configured when prompting to push (FR-011)? → A: Detect absence and skip push prompt entirely
