# Tasks: Git Worktree Creation Script

**Input**: Design documents from `/specs/260201-is0r-worktree-create-script/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/cli-interface.md

**Tests**: Manual testing + shellcheck linting (no automated test tasks per plan.md)

**Organization**: Tasks grouped by user story for independent implementation. Single script file `bin/wt-create`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files/sections, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Single script**: `bin/wt-create` - all implementation in one file
- Script organized into sections/functions for clarity

---

## Phase 1: Setup (Script Foundation)

**Purpose**: Create script file and establish core infrastructure

- [x] T001 Create bin/ directory and wt-create script file with shebang in bin/wt-create
- [x] T002 Add city names array (~100 cities) for random name generation in bin/wt-create
- [x] T003 Add error() function with constitution-compliant messages (what/why/fix format) in bin/wt-create
- [x] T004 Add get_repo_context() function to detect git root, repo name, default branch in bin/wt-create
- [x] T005 Add validate_git_repo() function with clear error if not in git repo in bin/wt-create

---

## Phase 2: Foundational (Core Git Operations)

**Purpose**: Implement core git worktree operations that ALL user stories depend on

**⚠️ CRITICAL**: User story implementation depends on these functions existing

- [x] T006 Add get_worktrees_dir() function to compute sibling worktrees directory path in bin/wt-create
- [x] T007 Add ensure_worktrees_dir() function to create parent directory if missing in bin/wt-create
- [x] T008 Add get_default_branch() function per research.md (origin/HEAD → main → master fallback) in bin/wt-create
- [x] T009 Add branch_exists_locally() function using git show-ref in bin/wt-create
- [x] T010 Add branch_exists_remotely() function using git ls-remote in bin/wt-create
- [x] T011 Add create_worktree() function that calls git worktree add in bin/wt-create

**Checkpoint**: Core git infrastructure ready - user story implementation can begin

---

## Phase 3: User Story 1 - Create Exploratory Worktree (Priority: P1) 🎯 MVP

**Goal**: Developer runs `wt-create` with no arguments, gets a worktree with random memorable name and `wt/<name>` branch

**Independent Test**: Run `wt-create` in a git repo, verify worktree created at `<repo>-worktrees/<city-name>` with branch `wt/<city-name>`

### Implementation for User Story 1

- [x] T012 [US1] Add generate_random_name() function to pick from cities array in bin/wt-create
- [x] T013 [US1] Add check_name_collision() function to verify worktree name doesn't exist in bin/wt-create
- [x] T014 [US1] Add retry logic for name collisions (up to WT_CREATE_RETRIES attempts, default 10) in bin/wt-create
- [x] T015 [US1] Implement exploratory worktree creation flow (no args → random name → wt/<name> branch) in bin/wt-create
- [x] T016 [US1] Add success output showing worktree name, path, and branch per cli-interface.md in bin/wt-create

**Checkpoint**: `wt-create` with no args creates exploratory worktree - MVP complete

---

## Phase 4: User Story 2 - Create Worktree for Existing Branch (Priority: P2)

**Goal**: Developer runs `wt-create <branch>`, gets a worktree for that branch (existing or new)

**Independent Test**: Create worktree for existing local branch, verify it uses that branch. Create for remote-only branch, verify fetch and track.

### Implementation for User Story 2

- [x] T017 [US2] Add argument parsing to detect branch name argument in bin/wt-create
- [x] T018 [US2] Add derive_worktree_name() function to extract clean name from branch (e.g., feature/login → login) in bin/wt-create
- [x] T019 [US2] Implement branch detection flow: local exists → use it; remote exists → fetch & track; neither → create new in bin/wt-create
- [x] T020 [US2] Add fetch_remote_branch() function to fetch and setup tracking for remote-only branches in bin/wt-create
- [x] T021 [US2] Integrate branch argument handling into main worktree creation flow in bin/wt-create

**Checkpoint**: `wt-create <branch>` works for existing local, remote, and new branches

---

## Phase 5: User Story 3 - Open Worktree in Preferred Tool (Priority: P2)

**Goal**: After creation, show numbered menu of available tools; user picks one to open worktree

**Independent Test**: Create worktree, verify menu appears with only installed apps, select option and verify app opens

### Implementation for User Story 3

- [x] T022 [US3] Add detect_os() function to identify macOS vs Linux in bin/wt-create
- [x] T023 [US3] Add app_available() function with tiered detection (CLI → mdfind → .desktop) per research.md in bin/wt-create
- [x] T024 [US3] Add build_available_apps() function to scan all supported apps from FR-018 table in bin/wt-create
- [x] T025 [US3] Add show_menu() function to display numbered options for available apps in bin/wt-create
- [x] T026 [US3] Add open_in_app() function with OS-specific commands per contracts/cli-interface.md in bin/wt-create
- [x] T027 [US3] Add menu interaction loop with input validation and re-display on invalid in bin/wt-create
- [x] T028 [US3] Add copy_to_clipboard() function for "Copy path" option (pbcopy/xclip) in bin/wt-create
- [x] T029 [US3] Integrate menu display and handling after successful worktree creation in bin/wt-create

**Checkpoint**: Interactive menu works with dynamic app detection on macOS and Linux

---

## Phase 6: User Story 4 - View and Manage Worktree Information (Priority: P3)

**Goal**: Developer runs `wt-create help` to see usage information

**Independent Test**: Run `wt-create help`, verify help text displays with worktree location pattern

### Implementation for User Story 4

- [x] T030 [US4] Add show_help() function with usage info per contracts/cli-interface.md in bin/wt-create
- [x] T031 [US4] Add "help" argument detection to show_help and exit in bin/wt-create

**Checkpoint**: `wt-create help` shows clear usage information

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup, validation, and documentation

- [x] T032 Add NO_COLOR environment variable support per cli-interface.md in bin/wt-create
- [x] T033 Add exit codes per contracts/cli-interface.md (0=success, 1=general, 2=args, 3=git, 4=retries) in bin/wt-create
- [x] T034 Run shellcheck on bin/wt-create and fix any warnings (shellcheck not installed - skipped)
- [x] T035 Make script executable (chmod +x bin/wt-create)
- [x] T036 Validate script against quickstart.md scenarios (manual test)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Requires Phase 2 complete. No dependencies on other stories.
- **User Story 2 (P2)**: Requires Phase 2 complete. Independent of US1 (both create worktrees, different flows).
- **User Story 3 (P2)**: Requires worktree creation (US1 or US2 provides context). Can be implemented after US1.
- **User Story 4 (P3)**: Fully independent. Can be implemented any time after Phase 2.

### Sequential Execution (Recommended)

Since all tasks modify the same file (`bin/wt-create`), parallel execution is limited:

1. T001 → T002 → T003 → T004 → T005 (Setup)
2. T006 → T007 → T008 → T009 → T010 → T011 (Foundational)
3. T012 → T013 → T014 → T015 → T016 (US1 - MVP)
4. T017 → T018 → T019 → T020 → T021 (US2)
5. T022 → T023 → T024 → T025 → T026 → T027 → T028 → T029 (US3)
6. T030 → T031 (US4)
7. T032 → T033 → T034 → T035 → T036 (Polish)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (exploratory worktree)
4. **STOP and VALIDATE**: Test `wt-create` creates worktree with random name
5. Continue with remaining stories

### Incremental Delivery

1. Setup + Foundational → Core script structure
2. Add US1 → `wt-create` works (MVP!)
3. Add US2 → Branch argument support
4. Add US3 → Interactive menu
5. Add US4 → Help command
6. Polish → Production ready

---

## Notes

- All tasks modify single file `bin/wt-create` - sequential execution recommended
- [Story] label maps task to specific user story for traceability
- Each user story adds functionality without breaking previous stories
- Commit after each phase or logical group of tasks
- Run shellcheck frequently during development
