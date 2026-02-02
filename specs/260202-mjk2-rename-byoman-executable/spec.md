# Feature Specification: Rename Executable from byosm to byoman

**Feature Branch**: `260202-mjk2-rename-byoman-executable`
**Created**: 2026-02-02
**Status**: Draft
**Input**: User description: "The final executable is called byosm. Instead, it should be called byoman."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Build and Run Renamed Executable (Priority: P1)

A developer builds the project and runs the executable using the new name `byoman` instead of `byosm`. All functionality remains identical; only the name changes.

**Why this priority**: The executable name is the primary user-facing identifier. Users must be able to invoke the tool with the correct, intended name.

**Independent Test**: Run `go build -o byoman ./cmd/byoman && ./byoman` and verify the TUI launches successfully.

**Acceptance Scenarios**:

1. **Given** a developer has the project source code, **When** they run `go build -o byoman ./cmd/byoman`, **Then** a working `byoman` executable is produced
2. **Given** a built `byoman` executable exists, **When** the user runs `./byoman`, **Then** the byobu session manager TUI launches
3. **Given** the project uses Go modules, **When** the user runs `go run ./cmd/byoman`, **Then** the application runs correctly

---

### User Story 2 - Internal Module References Work (Priority: P1)

All internal Go package imports reference the renamed module `byoman` and compile without errors.

**Why this priority**: Broken imports would prevent the project from building at all.

**Independent Test**: Run `go build ./...` and verify no import errors occur.

**Acceptance Scenarios**:

1. **Given** all internal packages use the new module name, **When** `go build ./...` is executed, **Then** compilation succeeds without import errors
2. **Given** the `go.mod` file declares module `byoman`, **When** any internal package imports `byoman/internal/...`, **Then** the import resolves correctly

---

### Edge Cases

- What happens if old `byosm` binary exists in the directory? User should manually delete it; `.gitignore` will ignore `byoman` instead.
- Documentation in `specs/` directory references old name? All documentation must be updated to reference `byoman`.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Go module MUST be named `byoman` (in `go.mod`)
- **FR-002**: The command directory MUST be located at `cmd/byoman/` instead of `cmd/byosm/`
- **FR-003**: All internal package imports MUST reference `byoman/internal/...` instead of `byosm/internal/...`
- **FR-004**: The `.gitignore` MUST ignore the `byoman` binary instead of `byosm`
- **FR-005**: The built executable MUST be named `byoman`
- **FR-006**: All documentation referencing `byosm` MUST be updated to reference `byoman`

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Project builds successfully when developer invokes the build command targeting the new executable name
- **SC-002**: Running the built executable launches the session manager TUI correctly
- **SC-003**: Full project build completes with zero errors
- **SC-004**: No references to `byosm` remain in source code files
- **SC-005**: Documentation accurately reflects the `byoman` executable name

## Assumptions

- The rename is purely cosmetic - no functional changes to the application behavior
- Existing tmux integration and TUI functionality remain unchanged
- Users familiar with the old name will use the new name going forward
