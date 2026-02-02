# Tasks: Rename Executable from byosm to byoman

**Input**: Design documents from `/specs/260202-mjk2-rename-byoman-executable/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md

**Tests**: Not requested for this feature - verification via build commands.

**Organization**: Tasks grouped by user story. Both stories are P1 priority and can proceed in parallel after setup.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- All paths are relative to repository root

---

## Phase 1: Setup (Go Module)

**Purpose**: Update the Go module declaration - prerequisite for all other changes

- [x] T001 Update module name from `byosm` to `byoman` in go.mod

---

## Phase 2: User Story 1 - Build and Run Renamed Executable (Priority: P1)

**Goal**: Developer can build and run the executable using the new name `byoman`

**Independent Test**: `go build -o byoman ./cmd/byoman && ./byoman` launches the TUI successfully

### Implementation for User Story 1

- [x] T002 [US1] Create cmd/byoman/ directory with main.go (cmd/byosm did not exist)

**Checkpoint**: After T001 + T002, the build command `go build -o byoman ./cmd/byoman` should work (assuming imports are fixed in US2)

---

## Phase 3: User Story 2 - Internal Module References Work (Priority: P1)

**Goal**: All internal Go package imports compile without errors

**Independent Test**: `go build ./...` completes with exit code 0

### Implementation for User Story 2

- [x] T003 [P] [US2] Update import paths from `byosm/internal/` to `byoman/internal/` in internal/app/app.go
- [x] T004 [P] [US2] Update import path from `byosm/internal/tmux` to `byoman/internal/tmux` in internal/tui/model.go
- [x] T005 [P] [US2] Update import path from `byosm/internal/tmux` to `byoman/internal/tmux` in internal/tui/update.go

**Checkpoint**: `go build ./...` should succeed with zero import errors

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Configuration cleanup and documentation updates

### Configuration

- [x] T006 Remove duplicate `byosm` entry from .gitignore (keep `byoman` entry only)

### Verification

- [x] T007 Run `go build -o byoman ./cmd/byoman` and verify successful build
- [x] T008 Run `./byoman` and verify TUI launches correctly
- [x] T009 Run `grep -r "byosm" --include="*.go" .` to confirm no old references remain

### Documentation Updates

- [x] T010 [P] Update binary name references in specs/260201-2o4w-byoby-session-manager/plan.md
- [x] T011 [P] Update CLI documentation in specs/260201-2o4w-byoby-session-manager/contracts/cli-interface.md
- [x] T012 [P] Update build instructions in specs/260201-2o4w-byoby-session-manager/quickstart.md
- [x] T013 [P] Update task descriptions in specs/260201-2o4w-byoby-session-manager/tasks.md

### Cleanup

- [x] T014 Remove old `byosm` binary if present (rm -f byosm) - not present, no action needed

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - T001 must complete first
- **User Story 1 (Phase 2)**: Depends on T001
- **User Story 2 (Phase 3)**: Depends on T001, can run in parallel with T002
- **Polish (Phase 4)**: Depends on T001-T005 completion

### Task Dependencies

```
T001 (go.mod)
  ├── T002 (rename directory)
  ├── T003, T004, T005 (imports - all parallel)
  │
  └── [After T001-T005 complete]
        ├── T006 (.gitignore)
        ├── T007, T008, T009 (verification - sequential)
        └── T010, T011, T012, T013 (docs - all parallel)
              └── T014 (cleanup - last)
```

### User Story Dependencies

- **User Story 1**: Can start after T001 completes
- **User Story 2**: Can start after T001 completes, parallel with US1

### Parallel Opportunities

- T003, T004, T005 can all run in parallel (different files)
- T010, T011, T012, T013 can all run in parallel (different files)

---

## Parallel Example: Import Updates (T003-T005)

```bash
# All import updates can run simultaneously:
Task: "Update imports in internal/app/app.go"
Task: "Update imports in internal/tui/model.go"
Task: "Update imports in internal/tui/update.go"
```

---

## Implementation Strategy

### MVP First (Stories 1 + 2)

1. Complete T001: Update go.mod
2. Complete T002: Rename cmd directory
3. Complete T003-T005: Update all imports (parallel)
4. Run verification: `go build ./...` and `./byoman`
5. **STOP and VALIDATE**: Both user stories should pass at this point

### Full Completion

1. After MVP validation
2. Complete T006: Clean up .gitignore
3. Complete T007-T009: Formal verification
4. Complete T010-T013: Documentation updates (parallel)
5. Complete T014: Cleanup old binary

---

## Notes

- This is a cosmetic refactor with no functional changes
- Both user stories are P1 because the rename is atomic (partial rename = broken build)
- Verification after Phase 3 is critical before proceeding to documentation
- Total files requiring changes: 8 (go.mod, cmd dir rename, 3 Go files, .gitignore, 4 doc files)
