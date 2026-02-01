# Tasks: Worktree Lifecycle Scripts

**Input**: Design documents from `/specs/260201-gvao-wt-lifecycle-scripts/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/cli-interface.md ✓

**Tests**: Manual testing via quickstart.md scenarios + shellcheck validation (no automated tests specified).

**Organization**: Tasks grouped by user story. Each script (`wt-delete`, `wt-pr`, `wt-merge`) delivers independent functionality.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US5)
- Include exact file paths in descriptions

## Path Conventions

Per plan.md:
- Scripts: `bin/wt-delete`, `bin/wt-pr`, `bin/wt-merge`
- Reference: `bin/wt-create` (existing script for patterns)

---

## Phase 1: Setup

**Purpose**: Project initialization and pattern extraction

- [X] T001 Review bin/wt-create for reusable patterns (error format, menus, git detection, exit codes)
- [X] T002 [P] Create bin/wt-delete script stub with shebang, set -euo pipefail, basic structure
- [X] T003 [P] Create bin/wt-pr script stub with shebang, set -euo pipefail, basic structure
- [X] T004 [P] Create bin/wt-merge script stub with shebang, set -euo pipefail, basic structure

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that ALL scripts need - implement in wt-delete first, then replicate patterns to other scripts

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Implement what/why/fix error message helper function in bin/wt-delete (per FR-029)
- [X] T006 Implement numbered menu helper function in bin/wt-delete (per FR-030, Conductor-style)
- [X] T007 Implement git repository detection function in bin/wt-delete (per FR-034)
- [X] T008 Implement worktree vs main repo detection function in bin/wt-delete (is_worktree check per research.md)
- [X] T009 Implement exit code constants in bin/wt-delete (0=success, 1=error, 2=invalid args, 3=git error per FR-033)
- [X] T010 Implement color handling with NO_COLOR support in bin/wt-delete
- [X] T011 [P] Copy foundational functions from bin/wt-delete to bin/wt-pr
- [X] T012 [P] Copy foundational functions from bin/wt-delete to bin/wt-merge

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Delete Worktree (Priority: P1) 🎯 MVP

**Goal**: User can delete the current worktree with confirmation and proper cleanup

**Independent Test**: Create a worktree with `wt-create`, run `wt-delete` from within it, verify directory removed and branch optionally deleted

### Implementation for User Story 1

- [X] T013 [US1] Implement current worktree detection (get name, branch, path) in bin/wt-delete
- [X] T014 [US1] Implement confirmation prompt with deletion options menu in bin/wt-delete (delete+branch, delete+keep branch, cancel)
- [X] T015 [US1] Implement uncommitted changes detection (git diff --quiet) in bin/wt-delete (per FR-003)
- [X] T016 [US1] Implement uncommitted changes menu (stash/discard/abort) in bin/wt-delete
- [X] T017 [US1] Implement stash with descriptive name in bin/wt-delete (per research.md)
- [X] T018 [US1] Implement unpushed commits detection and warning in bin/wt-delete (per FR-004)
- [X] T019 [US1] Implement git worktree remove command with --force handling in bin/wt-delete (per FR-005)
- [X] T020 [US1] Implement local branch deletion (git branch -d/-D) in bin/wt-delete
- [X] T021 [US1] Implement remote branch deletion prompt and execution in bin/wt-delete (per FR-006)
- [X] T022 [US1] Implement cd instruction output after deletion (per FR-007, research.md)
- [X] T023 [US1] Implement --force flag to skip confirmation in bin/wt-delete (per FR-010)

**Checkpoint**: User Story 1 complete - `wt-delete` works for current worktree

---

## Phase 4: User Story 2 - Create Pull Request (Priority: P1) 🎯 MVP

**Goal**: User can create a PR from current worktree with change summary and options

**Independent Test**: Create changes in worktree, run `wt-pr`, verify PR created with correct branch/base

### Implementation for User Story 2

- [X] T024 [US2] Implement current branch detection and existing PR check (gh pr view) in bin/wt-pr (per FR-012, FR-018)
- [X] T025 [US2] Implement change summary display (diff --stat, commit count, log) in bin/wt-pr (per FR-035, contracts)
- [X] T026 [US2] Implement --no-summary flag in bin/wt-pr (per FR-036)
- [X] T027 [US2] Implement main PR menu (Draft/Ready/Push/Cancel) in bin/wt-pr (per FR-013)
- [X] T028 [US2] Implement "no changes" error when branch has no commits ahead of base in bin/wt-pr
- [X] T029 [US2] Implement default branch detection for PR base in bin/wt-pr (per FR-017)
- [X] T030 [US2] Implement branch push logic (if not already pushed) in bin/wt-pr (per FR-014)
- [X] T031 [US2] Implement gh CLI detection in bin/wt-pr (per FR-015)
- [X] T032 [US2] Implement gh pr create for draft and ready PRs in bin/wt-pr
- [X] T033 [US2] Implement auto-generated title/body for non-interactive mode in bin/wt-pr (per FR-037)
- [X] T034 [US2] Implement browser fallback URL construction when gh not available in bin/wt-pr (per FR-016, research.md)
- [X] T035 [US2] Implement cross-platform browser open (macOS: open, Linux: xdg-open) in bin/wt-pr
- [X] T036 [US2] Implement existing PR handling menu (open in browser, exit) in bin/wt-pr
- [X] T037 [US2] Implement --draft and --ready flags for non-interactive mode in bin/wt-pr (per FR-020)
- [X] T038 [US2] Implement --push flag (push only, no PR) in bin/wt-pr
- [X] T039 [US2] Implement "open in browser?" prompt after PR creation in bin/wt-pr (per FR-019)

**Checkpoint**: User Story 2 complete - `wt-pr` creates PRs from worktrees

---

## Phase 5: User Story 3 - Merge Branch (Priority: P2)

**Goal**: User can merge an approved PR and clean up worktree/branch

**Independent Test**: Create a PR (approved), run `wt-merge`, verify PR merged and cleanup offered

### Implementation for User Story 3

- [X] T040 [US3] Implement gh CLI requirement check (no fallback for merge) in bin/wt-merge (per spec assumptions)
- [X] T041 [US3] Implement current branch to PR lookup in bin/wt-merge (per FR-021)
- [X] T042 [US3] Implement "no PR found" error with offer to create one in bin/wt-merge (per FR-027, contracts)
- [X] T043 [US3] Implement PR status display (checks, approvals, mergeable) in bin/wt-merge (per FR-022, contracts)
- [X] T044 [US3] Implement checks failing warning menu (wait/merge anyway/cancel) in bin/wt-merge (per FR-025)
- [X] T045 [US3] Implement not approved warning menu (open browser/cancel) in bin/wt-merge (per contracts)
- [X] T046 [US3] Implement gh pr merge with repo default method in bin/wt-merge (per FR-024)
- [X] T047 [US3] Implement --force flag to merge despite failing checks in bin/wt-merge
- [X] T048 [US3] Implement post-merge cleanup prompt (delete worktree + remote branch) in bin/wt-merge (per FR-026)
- [X] T049 [US3] Implement worktree deletion reusing wt-delete logic in bin/wt-merge
- [X] T050 [US3] Implement remote branch deletion via gh pr merge --delete-branch in bin/wt-merge
- [X] T051 [US3] Implement --delete-worktree flag for auto-cleanup in bin/wt-merge (per FR-028)

**Checkpoint**: User Story 3 complete - `wt-merge` merges PRs from worktrees

---

## Phase 6: User Story 4 - Delete Worktree by Name (Priority: P2)

**Goal**: User can delete a specific worktree from the main repository

**Independent Test**: Run `wt-delete london` from main repo, verify the specified worktree is removed

### Implementation for User Story 4

- [X] T052 [US4] Implement NAME argument parsing in bin/wt-delete (per FR-008)
- [X] T053 [US4] Implement worktree list retrieval (git worktree list --porcelain) in bin/wt-delete
- [X] T054 [US4] Implement worktree name lookup/validation in bin/wt-delete
- [X] T055 [US4] Implement "worktree not found" error with available worktrees list in bin/wt-delete (per FR-009)
- [X] T056 [US4] Implement worktree selection menu when NAME not provided and in main repo in bin/wt-delete

**Checkpoint**: User Story 4 complete - `wt-delete <name>` works from main repo

---

## Phase 7: User Story 5 - List Worktrees (Priority: P3)

**Goal**: User can list all worktrees with name, branch, and path

**Independent Test**: Create multiple worktrees, run `wt-delete --list`, verify all shown with correct info

### Implementation for User Story 5

- [X] T057 [US5] Implement --list flag parsing in bin/wt-delete (per FR-011)
- [X] T058 [US5] Implement formatted worktree list output (name, branch, path) in bin/wt-delete (per contracts)
- [X] T059 [US5] Implement "no worktrees found" message in bin/wt-delete

**Checkpoint**: User Story 5 complete - `wt-delete --list` shows all worktrees

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Help commands, validation, consistency

- [X] T060 [P] Implement help subcommand output in bin/wt-delete (per FR-031)
- [X] T061 [P] Implement help subcommand output in bin/wt-pr (per FR-031)
- [X] T062 [P] Implement help subcommand output in bin/wt-merge (per FR-031)
- [X] T063 [P] Implement --keep-branch flag in bin/wt-delete (per contracts)
- [X] T064 Run shellcheck on bin/wt-delete and fix any issues
- [X] T065 Run shellcheck on bin/wt-pr and fix any issues
- [X] T066 Run shellcheck on bin/wt-merge and fix any issues
- [X] T067 Validate wt-delete against quickstart.md scenarios
- [X] T068 Validate wt-pr against quickstart.md scenarios
- [X] T069 Validate wt-merge against quickstart.md scenarios
- [X] T070 Mark all scripts as executable (chmod +x bin/wt-*)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on T001 (pattern review) - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - US1 (wt-delete core) and US2 (wt-pr) can proceed in parallel
  - US3 (wt-merge) can proceed in parallel with US1/US2
  - US4 and US5 extend wt-delete so depend on US1
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational - No dependencies on other stories
- **User Story 3 (P2)**: Can start after Foundational - No dependencies (wt-merge is separate script)
- **User Story 4 (P2)**: Depends on US1 core implementation (T013-T023)
- **User Story 5 (P3)**: Depends on US4 (T053 worktree list retrieval)

### Within Each User Story

- Error handling implemented before success paths
- Core functionality before flags/options
- Interactive mode before non-interactive mode

### Parallel Opportunities

- T002, T003, T004 - Script stubs can be created in parallel
- T011, T012 - Copying foundations to other scripts (parallel)
- US1 and US2 - Different scripts, can implement in parallel
- US3 - Different script, can implement in parallel with US1/US2
- T060, T061, T062 - Help commands for each script (parallel)
- T064, T065, T066 - Shellcheck validation per script (parallel)

---

## Parallel Example: Foundational Phase

```bash
# After T005-T010 complete (wt-delete foundations):
Task: "Copy foundational functions from bin/wt-delete to bin/wt-pr"
Task: "Copy foundational functions from bin/wt-delete to bin/wt-merge"
```

## Parallel Example: MVP (US1 + US2)

```bash
# After Foundational phase complete, two developers can work in parallel:
# Developer A: User Story 1 (wt-delete)
Task: T013-T023 (wt-delete core functionality)

# Developer B: User Story 2 (wt-pr)
Task: T024-T039 (wt-pr full implementation)
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 Only)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T012) - CRITICAL
3. Complete Phase 3: User Story 1 - Delete current worktree (T013-T023)
4. Complete Phase 4: User Story 2 - Create PR (T024-T039)
5. **STOP and VALIDATE**: Test both scripts independently
6. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 (wt-delete core) → Test → **MVP-1: Can delete worktrees**
3. Add US2 (wt-pr) → Test → **MVP-2: Can create PRs**
4. Add US3 (wt-merge) → Test → **MVP-3: Full workflow (create→PR→merge)**
5. Add US4 (wt-delete by name) → Test → Enhancement
6. Add US5 (wt-delete --list) → Test → Enhancement
7. Polish → Production ready

### Single Developer Strategy

Follow priority order:
1. Complete Setup + Foundational
2. Complete US1 (T013-T023) → test wt-delete
3. Complete US2 (T024-T039) → test wt-pr
4. Complete US3 (T040-T051) → test wt-merge
5. Complete US4 (T052-T056) → test wt-delete <name>
6. Complete US5 (T057-T059) → test wt-delete --list
7. Complete Polish (T060-T070) → final validation

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story delivers working functionality independently
- Scripts follow wt-create patterns for consistency
- Exit codes per data-model.md: 0=success, 1=error, 2=invalid args, 3=git error
- Manual testing via quickstart.md scenarios
- Shellcheck validation required before completion
