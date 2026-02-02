# Tasks: Byobu Sessions

**Input**: Design documents from `/specs/260202-2gdn-byobu-sessions/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

**Tests**: Not requested in specification - implementation tasks only.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: No setup required - this feature modifies existing code in a single file.

*No setup tasks - existing project structure is already in place.*

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Replace tmux version checking with byobu existence check - MUST complete before user story commands work.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T001 Replace CheckVersion() to verify byobu installation in internal/tmux/client.go:30-68
- [X] T002 Update CheckVersion() error message with install instructions (macOS/Ubuntu/Fedora) in internal/tmux/client.go

**Checkpoint**: Foundation ready - byobu detection works, user story implementation can begin

---

## Phase 3: User Story 1 - Start Byobu Sessions (Priority: P1) 🎯 MVP

**Goal**: Sessions created via byoman use byobu and include byobu's status bar and keybindings.

**Independent Test**: Create a new session through byoman, verify it has byobu's status bar and keybindings active.

### Implementation for User Story 1

- [X] T003 [US1] Replace exec.Command("tmux", ...) with exec.Command("byobu", ...) in CreateSession() at internal/tmux/client.go:176
- [X] T004 [US1] Update error message from "tmux new-session" to "byobu new-session" in internal/tmux/client.go:185

**Checkpoint**: New sessions are created via byobu with full feature set

---

## Phase 4: User Story 2 - Attach to Byobu Sessions (Priority: P1)

**Goal**: Attaching to sessions via byoman uses byobu for the full byobu experience.

**Independent Test**: Select a session in byoman, press enter, verify attachment uses byobu with full feature set.

### Implementation for User Story 2

- [X] T005 [US2] Replace exec.LookPath("tmux") with exec.LookPath("byobu") in AttachSessionArgs() at internal/tmux/client.go:229-238
- [X] T006 [US2] Update attach args from ["tmux", "attach-session", ...] to ["byobu", "attach-session", ...] in internal/tmux/client.go:235
- [X] T007 [US2] Update error message from "tmux not found" to "byobu not found" in internal/tmux/client.go:232

**Checkpoint**: Session attachment uses byobu with keybindings and status bar

---

## Phase 5: User Story 3 - Graceful Fallback When Byobu Unavailable (Priority: P2)

**Goal**: Clear error message when byobu is missing, with actionable install instructions.

**Independent Test**: Run byoman on system without byobu, verify helpful error message appears.

### Implementation for User Story 3

*Already covered by T002 (error message in CheckVersion). No additional tasks needed.*

**Checkpoint**: Error messages are clear and actionable

---

## Phase 6: Supporting Operations (Cross-cutting)

**Purpose**: Replace tmux with byobu in all remaining operations (list, rename, kill)

- [X] T008 [P] Replace exec.Command("tmux", "list-sessions", ...) with exec.Command("byobu", ...) in ListSessions() at internal/tmux/client.go:74
- [X] T009 [P] Replace exec.Command("tmux", "list-panes", ...) with exec.Command("byobu", ...) in GetPaneCommands() at internal/tmux/client.go:125
- [X] T010 [P] Replace exec.Command("tmux", "rename-session", ...) with exec.Command("byobu", ...) in RenameSession() at internal/tmux/client.go:196
- [X] T011 [P] Replace exec.Command("tmux", "kill-session", ...) with exec.Command("byobu", ...) in KillSession() at internal/tmux/client.go:215
- [X] T012 [P] Update error message in ListSessions() from "tmux list-sessions" to "byobu list-sessions" at internal/tmux/client.go:86
- [X] T013 [P] Update error message in GetPaneCommands() from "tmux list-panes" to "byobu list-panes" at internal/tmux/client.go:137
- [X] T014 [P] Update error message in RenameSession() from "tmux rename-session" to "byobu rename-session" at internal/tmux/client.go:208
- [X] T015 [P] Update error message in KillSession() from "tmux kill-session" to "byobu kill-session" at internal/tmux/client.go:224

**Checkpoint**: All tmux references replaced with byobu

---

## Phase 7: Polish & Validation

**Purpose**: Verify all success criteria are met

- [ ] T016 Build binary with `go build -o byoman ./cmd/byoman`
- [ ] T017 Manual test: Verify new sessions display byobu's status bar (SC-001)
- [ ] T018 Manual test: Verify byobu keybindings (F1-F12) work (SC-002)
- [ ] T019 Manual test: Verify user's byobu profile settings are applied (SC-003)
- [ ] T020 Manual test: Verify all operations (list, rename, kill, attach) work (SC-004)
- [ ] T021 Manual test: Verify error messages include install instructions (SC-005)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Skipped - no setup needed
- **Foundational (Phase 2)**: No dependencies - start immediately - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational completion
- **User Story 2 (Phase 4)**: Depends on Foundational completion - can run parallel with US1
- **User Story 3 (Phase 5)**: Covered by Foundational phase
- **Supporting Operations (Phase 6)**: Depends on Foundational completion - can run parallel with US1/US2
- **Polish (Phase 7)**: Depends on all implementation phases complete

### User Story Dependencies

- **User Story 1 (P1)**: Depends only on Phase 2 - CreateSession() replacement
- **User Story 2 (P1)**: Depends only on Phase 2 - AttachSessionArgs() replacement
- **User Story 3 (P2)**: Depends only on Phase 2 - Already covered by CheckVersion() error message

### Within Each Phase

- T001 must complete before T002 (CheckVersion structure before error message)
- All T008-T015 are parallelizable (different functions, no dependencies)
- T016 must complete before T017-T021 (build before manual testing)

### Parallel Opportunities

```bash
# After Phase 2 completes, launch US1, US2, and Phase 6 in parallel:
# Stream 1: User Story 1
T003, T004

# Stream 2: User Story 2
T005, T006, T007

# Stream 3: Supporting Operations (all parallelizable)
T008, T009, T010, T011, T012, T013, T014, T015
```

---

## Implementation Strategy

### MVP First (User Story 1 + User Story 2)

1. Complete Phase 2: Foundational (CheckVersion change)
2. Complete Phase 3: User Story 1 (CreateSession)
3. Complete Phase 4: User Story 2 (AttachSessionArgs)
4. **STOP and VALIDATE**: Test session create and attach
5. Sessions now use byobu with full features

### Full Implementation

1. Complete Foundational → Byobu detection works
2. Complete US1 + US2 in parallel → Core features work
3. Complete Phase 6 → All operations use byobu
4. Complete Phase 7 → Validate all success criteria

### Single Developer Strategy

Since all changes are in one file (`internal/tmux/client.go`), execute sequentially:
1. T001-T002 (Foundational)
2. T003-T004 (US1)
3. T005-T007 (US2)
4. T008-T015 (Supporting - can batch as single find/replace)
5. T016-T021 (Build and test)

---

## Notes

- All changes are in a single file: `internal/tmux/client.go`
- This is primarily a find/replace operation: "tmux" → "byobu"
- CheckVersion() simplification removes ~30 lines of version parsing code
- No data model changes - byobu uses identical session format
- No TUI changes - only the tmux client layer is affected
- Total estimated changes: ~20 line modifications, ~30 lines removed
