# Tasks: Speckit Branch Naming Integration

**Input**: Design documents from `/specs/260201-krgf-speckit-branch-naming/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: Not requested - implementation tasks only.

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Scripts**: `.specify/scripts/bash/` at repository root
- **Commands**: `.claude/commands/` at repository root

---

## Phase 1: Setup

**Purpose**: Create new script file with boilerplate

- [X] T001 Create rename-branch.sh script skeleton with shebang, set -e, source common.sh, and function stubs in .specify/scripts/bash/rename-branch.sh

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Helper functions required by ALL user stories - must complete before any story implementation

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T002 [P] Add is_temporary_branch() function to check if branch matches wt/* pattern in .specify/scripts/bash/rename-branch.sh
- [X] T003 [P] Add is_protected_branch() function to check if branch is main or master in .specify/scripts/bash/rename-branch.sh
- [X] T004 [P] Add branch_exists_locally() function using git show-ref to check local refs in .specify/scripts/bash/rename-branch.sh
- [X] T005 [P] Add branch_exists_remotely() function using git ls-remote to check origin in .specify/scripts/bash/rename-branch.sh
- [X] T006 [P] Add sanitize_branch_name() function extending clean_spec_name pattern (lowercase, spaces to hyphens, remove ~^:?*[\) in .specify/scripts/bash/rename-branch.sh
- [X] T007 Add find_available_branch_name() function with numeric suffix collision resolution (up to 10 attempts per R4) in .specify/scripts/bash/rename-branch.sh

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Auto-rename Branch from Feature Description (Priority: P1) 🎯 MVP

**Goal**: When on a `wt/*` temporary branch, automatically rename to the spec name after spec creation

**Independent Test**: Create worktree with `wt-create`, run `speckit specify "test feature"`, verify branch renamed to spec name format

### Implementation for User Story 1

- [X] T008 [US1] Implement main rename_branch() function that computes target from spec name, sanitizes, resolves collisions, and executes git branch -m in .specify/scripts/bash/rename-branch.sh
- [X] T009 [US1] Add remote collision warning logic - check remote before rename for auto-generated names, warn but proceed (per R5) in .specify/scripts/bash/rename-branch.sh
- [X] T010 [US1] Add output messages for rename success format: "✓ Renamed branch: {old} → {new}" in .specify/scripts/bash/rename-branch.sh
- [X] T011 [US1] Integrate rename-branch.sh call into create-new-feature.sh after set_current_spec (around line 204) in .specify/scripts/bash/create-new-feature.sh
- [X] T012 [US1] Add RENAME_BRANCH variable to create-new-feature.sh with default true, pass spec name to rename-branch.sh in .specify/scripts/bash/create-new-feature.sh

**Checkpoint**: User Story 1 complete - temporary branches auto-rename to spec name

---

## Phase 4: User Story 2 - Use Linear Branch Name Directly (Priority: P2)

**Goal**: Support `--branch` flag to use a custom branch name instead of auto-generating from spec

**Independent Test**: Run `speckit specify --branch "feature/custom-name" "test feature"`, verify branch renamed to `feature/custom-name`

### Implementation for User Story 2

- [X] T013 [US2] Add --branch argument parsing to create-new-feature.sh argument loop (store in CUSTOM_BRANCH variable) in .specify/scripts/bash/create-new-feature.sh
- [X] T014 [US2] Add --target and --custom-branch arguments to rename-branch.sh script interface in .specify/scripts/bash/rename-branch.sh
- [X] T015 [US2] Modify rename_branch() to use custom branch name when provided, skip remote check for user-provided names (per R5) in .specify/scripts/bash/rename-branch.sh
- [X] T016 [US2] Pass CUSTOM_BRANCH to rename-branch.sh when provided in create-new-feature.sh integration in .specify/scripts/bash/create-new-feature.sh

**Checkpoint**: User Story 2 complete - custom branch names via --branch flag work

---

## Phase 5: User Story 3 - Keep Existing Canonical Branch (Priority: P3)

**Goal**: When already on a canonical branch (not `wt/*`), preserve it unless `--branch` flag explicitly provided

**Independent Test**: Create branch `feature/existing`, run `speckit specify "test"` without --branch, verify branch unchanged

### Implementation for User Story 3

- [X] T017 [US3] Add canonical branch detection at start of rename_branch() - skip if not temporary and no custom branch provided in .specify/scripts/bash/rename-branch.sh
- [X] T018 [US3] Add warning output for main/master: "⚠ Warning: Working on '{branch}' branch" with suggestion in .specify/scripts/bash/rename-branch.sh
- [X] T019 [US3] Add preserved message output: "ℹ Branch preserved: {name} (already canonical)" in .specify/scripts/bash/rename-branch.sh
- [X] T020 [US3] Ensure --branch flag overrides preserve behavior (explicit user intent wins per FR-005) in .specify/scripts/bash/rename-branch.sh

**Checkpoint**: User Story 3 complete - canonical branches preserved correctly

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final features, documentation, and error handling

- [X] T021 [P] Implement push prompt after successful rename - detect remote with git remote, prompt "Push to origin and set up tracking? [y/N]" in .specify/scripts/bash/rename-branch.sh
- [X] T022 [P] Skip push prompt when --json flag is set (non-interactive mode) or no remote configured in .specify/scripts/bash/rename-branch.sh
- [X] T023 [P] Add JSON output enhancement to include branch info object {original, current, renamed, pushed} in .specify/scripts/bash/create-new-feature.sh
- [X] T024 [P] Add error recovery - if rename fails, log warning but return success so spec creation completes (FR-009) in .specify/scripts/bash/rename-branch.sh
- [X] T025 [P] Add --no-rename flag to create-new-feature.sh to skip branch rename entirely in .specify/scripts/bash/create-new-feature.sh
- [X] T026 Update speckit.specify.md documentation with --branch and --no-rename flags, usage examples in .claude/commands/speckit.specify.md
- [X] T027 Run quickstart.md scenarios manually to validate all workflows

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - start immediately
- **Foundational (Phase 2)**: Depends on Setup (T001) - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational completion
- **User Story 2 (Phase 4)**: Depends on Foundational completion, can parallelize with US1 if both devs available
- **User Story 3 (Phase 5)**: Depends on Foundational completion, can parallelize with US1/US2
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies on other stories - implements core rename
- **User Story 2 (P2)**: Builds on US1's rename infrastructure but is independently testable
- **User Story 3 (P3)**: Uses detection functions from Foundational, independent of US1/US2

### Within Each User Story

- Functions must exist before callers
- Integration (create-new-feature.sh changes) after rename-branch.sh implementation
- Output formatting after core logic

### Parallel Opportunities

- All Foundational tasks T002-T006 can run in parallel (different functions, no dependencies)
- T007 depends on T004 (uses branch_exists_locally)
- Polish tasks T021-T025 can mostly run in parallel

---

## Parallel Example: Foundational Phase

```bash
# Launch all helper functions together:
Task: "Add is_temporary_branch() in .specify/scripts/bash/rename-branch.sh"
Task: "Add is_protected_branch() in .specify/scripts/bash/rename-branch.sh"
Task: "Add branch_exists_locally() in .specify/scripts/bash/rename-branch.sh"
Task: "Add branch_exists_remotely() in .specify/scripts/bash/rename-branch.sh"
Task: "Add sanitize_branch_name() in .specify/scripts/bash/rename-branch.sh"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002-T007)
3. Complete Phase 3: User Story 1 (T008-T012)
4. **STOP and VALIDATE**: Test with `wt-create` then `speckit specify "test"`
5. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundational → Infrastructure ready
2. Add User Story 1 → Test auto-rename → Can ship MVP
3. Add User Story 2 → Test --branch flag → Extended functionality
4. Add User Story 3 → Test canonical preservation → Full feature
5. Polish → Documentation and edge cases → Production ready

---

## Summary

| Phase | Tasks | Files Modified |
|-------|-------|----------------|
| Setup | 1 | rename-branch.sh (new) |
| Foundational | 6 | rename-branch.sh |
| US1 (P1) | 5 | rename-branch.sh, create-new-feature.sh |
| US2 (P2) | 4 | rename-branch.sh, create-new-feature.sh |
| US3 (P3) | 4 | rename-branch.sh |
| Polish | 7 | rename-branch.sh, create-new-feature.sh, speckit.specify.md |

**Total**: 27 tasks

---

## Notes

- [P] tasks = different files or independent functions, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Existing patterns: Use log_success, log_warning, log_error from common.sh
- Exit codes from data-model.md: 0=success, 1=general error, 3=git error, 4=retry exhausted
