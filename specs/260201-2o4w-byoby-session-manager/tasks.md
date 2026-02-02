# Tasks: tmux Session Manager

**Input**: Design documents from `/specs/260201-2o4w-byoby-session-manager/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, quickstart.md ✓

**Tests**: Not explicitly requested in spec - test tasks omitted.

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US5)
- Exact file paths included

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and Go module setup

- [x] T001 Create project directory structure per plan.md (cmd/byoman/, internal/tmux/, internal/tui/, internal/app/, tests/)
- [x] T002 Initialize Go module and install dependencies (bubbletea, bubbles/list, bubbles/textinput, lipgloss)
- [x] T003 [P] Create .gitignore for Go binaries and build artifacts

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core types and infrastructure that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 [P] Create Session, Window, Pane types in internal/tmux/types.go (from data-model.md)
- [x] T005 [P] Create lipgloss styles (list item, selection, prompt, error) in internal/tui/styles.go
- [x] T006 Create tmux Client interface and basic exec wrapper in internal/tmux/client.go
- [x] T007 Create TUI Model base struct with ViewState enum in internal/tui/model.go
- [x] T008 Create empty update.go and view.go stubs in internal/tui/

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - View All Sessions (Priority: P1) 🎯 MVP

**Goal**: Display list of all tmux sessions with metrics (name, created time, last attached, status, window count, running commands)

**Independent Test**: Run `./byoman` and verify all existing tmux sessions are displayed with their metrics. Verify "no sessions" message when none exist.

### Implementation for User Story 1

- [x] T009 [US1] Implement ListSessions() with tmux list-sessions parsing in internal/tmux/client.go
- [x] T010 [US1] Implement GetWindowsAndPanes() for session metrics in internal/tmux/client.go
- [x] T011 [P] [US1] Implement session list item rendering (name, status, window count, commands) in internal/tui/view.go
- [x] T012 [US1] Implement Init() with loadSessions command in internal/tui/model.go
- [x] T013 [US1] Implement keyboard navigation (↑/↓ arrows) in internal/tui/update.go
- [x] T014 [US1] Add tickCmd for 3-second auto-refresh with selection preservation in internal/tui/model.go
- [x] T015 [US1] Handle "no sessions" empty state in internal/tui/view.go
- [x] T016 [US1] Handle "no tmux server running" gracefully in internal/tmux/client.go
- [x] T017 [US1] Create main.go entry point with tea.NewProgram in cmd/byoman/main.go
- [x] T018 [US1] Wire app together in internal/app/app.go

**Checkpoint**: User Story 1 complete - can view all sessions with metrics and navigate with arrow keys

---

## Phase 4: User Story 2 - Attach to Existing Session (Priority: P1)

**Goal**: Select a session from the list and attach to it, replacing the TUI process with tmux

**Independent Test**: Select a session, press Enter, verify terminal is now attached to that tmux session.

### Implementation for User Story 2

- [x] T019 [US2] Add AttachSession(name) returning exec args in internal/tmux/client.go
- [x] T020 [US2] Implement Enter key handler to set selectedSession and tea.Quit in internal/tui/update.go
- [x] T021 [US2] Add quitting state to View() to prevent terminal artifacts in internal/tui/view.go
- [x] T022 [US2] Implement syscall.Exec handoff after p.Run() returns in cmd/byoman/main.go

**Checkpoint**: User Stories 1 & 2 complete - can view sessions AND attach to any selected session (MVP complete)

---

## Phase 5: User Story 3 - Start New Session (Priority: P2)

**Goal**: Create new tmux session from within the TUI with optional name input

**Independent Test**: Press 'n', enter a name, verify new session appears in the list. Test duplicate name error handling.

### Implementation for User Story 3

- [x] T023 [US3] Add NewSession(name) with tmux new-session -d in internal/tmux/client.go
- [x] T024 [US3] Add textinput.Model and StateNewSession to TUI Model in internal/tui/model.go
- [x] T025 [US3] Implement StateNewSession view (input prompt) in internal/tui/view.go
- [x] T026 [US3] Implement 'n' key handler to enter StateNewSession in internal/tui/update.go
- [x] T027 [US3] Implement Enter/Esc handlers for name submission/cancel in internal/tui/update.go
- [x] T028 [US3] Add error display for duplicate session name in internal/tui/view.go

**Checkpoint**: User Story 3 complete - can create new sessions with name validation

---

## Phase 6: User Story 4 - Rename Session (Priority: P3)

**Goal**: Rename a selected session to a new name

**Independent Test**: Select a session, press 'r', enter new name, verify name updates in the list. Test duplicate name error.

### Implementation for User Story 4

- [x] T029 [US4] Add RenameSession(old, new) with tmux rename-session in internal/tmux/client.go
- [x] T030 [US4] Add StateRenameSession with pre-filled textinput in internal/tui/model.go
- [x] T031 [US4] Implement StateRenameSession view (input prompt with old name) in internal/tui/view.go
- [x] T032 [US4] Implement 'r' key handler to enter StateRenameSession in internal/tui/update.go
- [x] T033 [US4] Implement Enter/Esc handlers for rename submission/cancel in internal/tui/update.go

**Checkpoint**: User Story 4 complete - can rename sessions with validation

---

## Phase 7: User Story 5 - Kill Session (Priority: P3)

**Goal**: Kill a selected session with inline y/N confirmation

**Independent Test**: Select a session, press 'k', verify confirmation prompt, press 'y' to kill, verify session removed. Press any other key to cancel.

### Implementation for User Story 5

- [x] T034 [US5] Add KillSession(name) with tmux kill-session in internal/tmux/client.go
- [x] T035 [US5] Add StateConfirmKill with confirmTarget in internal/tui/model.go
- [x] T036 [US5] Implement StateConfirmKill view ("Kill session 'X'? [y/N]") in internal/tui/view.go
- [x] T037 [US5] Implement 'k' key handler to enter StateConfirmKill in internal/tui/update.go
- [x] T038 [US5] Implement y/Y to confirm kill, any other key to cancel in internal/tui/update.go
- [x] T039 [US5] Handle stale session error (already killed externally) gracefully

**Checkpoint**: User Story 5 complete - can kill sessions with confirmation

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Edge cases and error handling that span multiple user stories

- [x] T040 [P] Add tmux version check (>=3.0) on startup in cmd/byoman/main.go
- [x] T041 [P] Add tmux not installed error with clear message in cmd/byoman/main.go
- [x] T042 Handle special characters in session names display in internal/tui/view.go
- [x] T043 Add 'q' key handler for clean quit in internal/tui/update.go
- [x] T044 Add help footer showing keybindings ([n]ew [r]ename [k]ill [q]uit) in internal/tui/view.go
- [x] T045 Run quickstart.md validation (build, run, test commands)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - start immediately
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational completion
  - US1 (P1) and US2 (P1) form the MVP
  - US3-US5 build on US1/US2 but are independently testable
- **Polish (Phase 8)**: Can start after US1 complete, ideally after all stories

### User Story Dependencies

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational) ← GATE: blocks all below
    ↓
┌───────────────────────────────────────────┐
│  Phase 3: US1 (View Sessions) - MVP START │
│      ↓                                    │
│  Phase 4: US2 (Attach) - MVP COMPLETE     │
└───────────────────────────────────────────┘
    ↓
┌───────────────────────────────────────────┐
│  Phase 5: US3 (New Session)     ← can    │
│  Phase 6: US4 (Rename Session)  ← start  │
│  Phase 7: US5 (Kill Session)    ← parallel│
└───────────────────────────────────────────┘
    ↓
Phase 8 (Polish)
```

### Within Each User Story

- tmux client methods first
- TUI model/state updates second
- View rendering third
- Update handlers last

### Parallel Opportunities

**Phase 2 (Foundational):**
```
T004 (types.go) ──┬── can run in parallel
T005 (styles.go) ─┘
```

**Phase 3 (US1):**
```
After T009, T010 complete:
T011 (view.go) ── can run parallel with T014 (auto-refresh)
```

**Post-MVP Stories (US3, US4, US5):**
```
All three can be implemented in parallel by different developers
since they operate on different state transitions and keys
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: User Story 1 - View Sessions
4. Complete Phase 4: User Story 2 - Attach to Session
5. **STOP and VALIDATE**: Test viewing and attaching independently
6. Deploy binary if ready

### Incremental Delivery

1. Setup + Foundational → Framework ready
2. Add US1 (View) → Test → First value delivery
3. Add US2 (Attach) → Test → **MVP complete!**
4. Add US3 (New) → Test → Can create sessions
5. Add US4 (Rename) → Test → Can organize sessions
6. Add US5 (Kill) → Test → Full feature parity
7. Polish phase → Production ready

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to user story (US1-US5)
- tmux client methods are generally blocking - implement in series within a story
- View/Update tasks can often parallelize within a story
- MVP = US1 + US2 only (view + attach)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
