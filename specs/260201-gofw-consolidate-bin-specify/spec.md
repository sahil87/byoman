# Feature Specification: Consolidate bin/ into .specify/

**Feature Branch**: `260201-gofw-consolidate-bin-specify`
**Created**: 2026-02-01
**Status**: Draft
**Input**: User description: "Consolidate the bin folder into the .specify folder to keep the root folder clean"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Clean Root Directory (Priority: P1)

As a developer working on this project, I want project scripts to be organized within the .specify folder so that the root directory remains clean and uncluttered with only essential project files.

**Why this priority**: A clean root directory improves project navigation and maintains consistency with the existing organization pattern where .specify contains project tooling.

**Independent Test**: Can be fully tested by verifying that the root directory no longer contains a bin/ folder and that all scripts are accessible from their new location within .specify/.

**Acceptance Scenarios**:

1. **Given** a project with a bin/ folder containing scripts, **When** I look at the root directory after consolidation, **Then** there is no bin/ folder present
2. **Given** scripts have been moved to .specify/, **When** I list the root directory contents, **Then** only essential project files (CLAUDE.md, specs/, .specify/, etc.) are visible

---

### User Story 2 - Scripts Remain Functional (Priority: P1)

As a developer, I want all relocated scripts to remain fully functional from their new location so that existing workflows continue to work without modification.

**Why this priority**: Maintaining script functionality is equally critical as cleaning the root - moving scripts without preserving functionality would break existing workflows.

**Independent Test**: Can be tested by executing each script from its new location and verifying expected behavior matches pre-move behavior.

**Acceptance Scenarios**:

1. **Given** wt-* scripts have been relocated, **When** I run any wt-* script, **Then** it executes successfully with the same behavior as before
2. **Given** speckit-build has been relocated, **When** I run speckit-build, **Then** it executes successfully with the same behavior as before

---

### User Story 3 - Discoverable Script Location (Priority: P2)

As a developer new to the project, I want to easily find and understand where project scripts are located so that I can use them effectively.

**Why this priority**: Once scripts are functional in their new location, discoverability ensures other developers can find and use them.

**Independent Test**: Can be tested by asking a new user to find and execute a project script using only project documentation or standard conventions.

**Acceptance Scenarios**:

1. **Given** I am looking for project scripts, **When** I navigate to .specify/, **Then** I can locate the bin/ scripts in an intuitive location
2. **Given** project documentation exists, **When** scripts are relocated, **Then** any references to scripts are updated to reflect the new location

---

### Edge Cases

- What happens if a script references the old bin/ path internally? Scripts must be checked for hardcoded paths.
- What happens if external tooling or documentation references bin/ paths? Documentation must be updated.
- How should the bin folder's purpose be documented for future contributors? The new location should be self-documenting or documented in CLAUDE.md.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST relocate all scripts from bin/ to a designated location within .specify/
- **FR-002**: System MUST remove the bin/ folder from the project root after relocation
- **FR-003**: All relocated scripts MUST remain executable with identical behavior to their original versions
- **FR-004**: System MUST preserve script permissions (executable bits) during relocation
- **FR-005**: Any internal script references to sibling scripts MUST be updated to reflect new paths if necessary

### Scripts to Relocate

| Current Location  | Script Purpose                 |
|-------------------|--------------------------------|
| bin/speckit-build | Speckit build orchestration    |
| bin/wt-create     | Worktree creation              |
| bin/wt-delete     | Worktree deletion              |
| bin/wt-merge      | Worktree merge workflow        |
| bin/wt-pr         | Worktree pull request creation |
| bin/wt-setup      | Worktree setup/initialization  |

### Key Entities

- **bin/ scripts**: 6 shell scripts providing worktree and speckit tooling
- **Target location**: A directory within .specify/ that maintains logical grouping (suggested: .specify/bin/)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Root directory contains zero script-specific folders (bin/ is removed)
- **SC-002**: 100% of scripts (6/6) execute successfully from their new location with identical output
- **SC-003**: All script internal references resolve correctly (no broken paths)
- **SC-004**: Project documentation accurately reflects script locations

## Assumptions

- Scripts in bin/ are standalone or reference each other via relative paths that can be maintained
- No external CI/CD or automation depends on the bin/ path (or such dependencies are acceptable to update)
- The .specify/ folder is an appropriate home for user-facing scripts, not just internal speckit tooling
- The target location will be .specify/bin/ to maintain naming convention clarity
