# Tasks: Consolidate bin/ into .specify/

**Input**: Design documents from `/specs/260201-gofw-consolidate-bin-specify/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

**Tests**: Not requested in specification - manual verification via quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Create target directory structure

- [X] T001 Create target directory `.specify/bin/` if it doesn't exist

---

## Phase 2: User Story 1 - Clean Root Directory (Priority: P1) 🎯 MVP

**Goal**: Relocate all scripts from bin/ to .specify/bin/ so root directory is clean

**Independent Test**: Verify `ls` at root shows no `bin/` directory; verify `ls .specify/bin/` shows all 6 scripts plus worktree-setup/

### Implementation for User Story 1

- [X] T002 [P] [US1] Move speckit-build using `git mv bin/speckit-build .specify/bin/speckit-build`
- [X] T003 [P] [US1] Move wt-create using `git mv bin/wt-create .specify/bin/wt-create`
- [X] T004 [P] [US1] Move wt-delete using `git mv bin/wt-delete .specify/bin/wt-delete`
- [X] T005 [P] [US1] Move wt-merge using `git mv bin/wt-merge .specify/bin/wt-merge`
- [X] T006 [P] [US1] Move wt-pr using `git mv bin/wt-pr .specify/bin/wt-pr`
- [X] T007 [P] [US1] Move wt-setup using `git mv bin/wt-setup .specify/bin/wt-setup`
- [X] T008 [US1] Move worktree-setup directory using `git mv bin/worktree-setup .specify/bin/worktree-setup`
- [X] T009 [US1] Verify bin/ directory is now empty and remove if needed

**Checkpoint**: Root directory should no longer contain bin/

---

## Phase 3: User Story 2 - Scripts Remain Functional (Priority: P1)

**Goal**: Update internal script references so all scripts work from new location

**Independent Test**: Execute `.specify/bin/wt-create help` and `.specify/bin/speckit-build help` - both should work

### Implementation for User Story 2

- [X] T010 [US2] Update wt-create line 621: change `$wt_path/bin/wt-setup` to `$wt_path/.specify/bin/wt-setup` in `.specify/bin/wt-create`
- [X] T011 [US2] Run shellcheck on all scripts in `.specify/bin/` to verify no syntax errors
- [X] T012 [US2] Test `.specify/bin/speckit-build help` executes successfully
- [X] T013 [US2] Test `.specify/bin/wt-create help` executes successfully
- [X] T014 [US2] Test `.specify/bin/wt-delete help` executes successfully
- [X] T015 [US2] Test `.specify/bin/wt-merge help` executes successfully
- [X] T016 [US2] Test `.specify/bin/wt-pr help` executes successfully
- [X] T017 [US2] Test `.specify/bin/wt-setup` executes without arguments (displays usage)

**Checkpoint**: All scripts should execute and show help/usage from new location

---

## Phase 4: User Story 3 - Discoverable Script Location (Priority: P2)

**Goal**: Update documentation so users can find scripts in new location

**Independent Test**: A user following documentation can locate and run scripts

### Implementation for User Story 3

- [X] T018 [US3] Update `.claude/commands/speckit.build.md`: change `bin/speckit-build` to `.specify/bin/speckit-build`
- [X] T019 [US3] Grep repository for any other active references to `bin/wt-` or `bin/speckit-build` that need updating

**Checkpoint**: All active documentation points to new script locations

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and cleanup

- [X] T020 Verify all scripts have executable permissions (`chmod +x` if needed)
- [X] T021 Run quickstart.md validation steps to confirm migration is complete
- [X] T022 Commit all changes with descriptive message

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - creates target directory
- **User Story 1 (Phase 2)**: Depends on Setup - moves all files
- **User Story 2 (Phase 3)**: Depends on US1 - updates internal references
- **User Story 3 (Phase 4)**: Depends on US1 - updates documentation
- **Polish (Phase 5)**: Depends on all user stories

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies - can start after Setup
- **User Story 2 (P1)**: Depends on US1 (scripts must be moved before updating references)
- **User Story 3 (P2)**: Can start after US1 (documentation can be updated once files are moved)

### Within Each User Story

- T002-T008 can all run in parallel (different files)
- T010 must complete before T012-T017 tests
- T018-T019 can run in parallel

### Parallel Opportunities

**User Story 1**:
```bash
# All git mv commands can run in parallel:
git mv bin/speckit-build .specify/bin/speckit-build
git mv bin/wt-create .specify/bin/wt-create
git mv bin/wt-delete .specify/bin/wt-delete
git mv bin/wt-merge .specify/bin/wt-merge
git mv bin/wt-pr .specify/bin/wt-pr
git mv bin/wt-setup .specify/bin/wt-setup
```

**User Story 2 - Tests**:
```bash
# All help/usage tests can run in parallel after T010:
.specify/bin/speckit-build help
.specify/bin/wt-create help
.specify/bin/wt-delete help
.specify/bin/wt-merge help
.specify/bin/wt-pr help
.specify/bin/wt-setup
```

---

## Implementation Strategy

### MVP First (User Story 1 + 2)

1. Complete Phase 1: Setup (create directory)
2. Complete Phase 2: User Story 1 (move all scripts)
3. Complete Phase 3: User Story 2 (update wt-create reference, verify all scripts work)
4. **STOP and VALIDATE**: All scripts execute from new location
5. Continue to documentation updates

### Suggested Execution

Since this is a simple file reorganization:
1. Run all `git mv` commands in sequence (T002-T008)
2. Update wt-create internal reference (T010)
3. Update speckit.build.md reference (T018)
4. Test all scripts work (T011-T017)
5. Final verification and commit (T020-T022)

---

## Notes

- All moves use `git mv` to preserve history and permissions
- Historical documentation in `specs/260201-gvao-wt-lifecycle-scripts/` and `specs/260201-is0r-worktree-create-script/` are NOT updated (per research.md decision)
- wt-setup uses `$SCRIPT_DIR` pattern which auto-resolves to new location - no changes needed
- Only wt-create has a hardcoded path that needs updating (line 621)
