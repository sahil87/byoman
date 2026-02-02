# Tasks: GitHub Actions CI/CD

**Input**: Design documents from `/specs/260202-gtx1-github-actions-cicd/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: No test tasks included - not requested in feature specification.

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the entry point that enables all CI/CD workflows to build the project

- [x] T001 Create Go entry point in main.go at repository root (calls app.Run(), handles errors per data-model.md)
- [x] T002 Verify local build works with `go build -v ./...` from repository root

**Checkpoint**: Project is buildable - CI/CD workflows can now be implemented

---

## Phase 2: Foundational (Directory Structure)

**Purpose**: Create the required directory structure for GitHub Actions workflows

**⚠️ CRITICAL**: Directory must exist before workflow files can be created

- [x] T003 Create `.github/workflows/` directory structure at repository root

**Checkpoint**: Directory structure ready - workflow files can now be created in parallel

---

## Phase 3: User Story 1 - Contributor Validates Code Changes (Priority: P1) 🎯 MVP

**Goal**: Developers can push code and get automated build/test feedback on PRs

**Independent Test**: Push a commit to a branch, observe CI workflow runs, builds successfully, and reports status back to the PR/commit

### Implementation for User Story 1

- [x] T004 [US1] Create CI workflow in `.github/workflows/ci.yml` per contracts/ci.yml:
  - Trigger on push to main and PRs targeting main
  - Setup Go using go-version-file
  - Run `go build -v ./...`
  - Run `go test -v ./...`
- [ ] T005 [US1] Verify CI workflow triggers on push by committing and pushing to current branch

**Checkpoint**: User Story 1 complete - CI validates code changes on every push/PR

---

## Phase 4: User Story 2 - Maintainer Releases New Version (Priority: P2)

**Goal**: Maintainers can create version tags to trigger automated release builds

**Independent Test**: Create a version tag (e.g., v0.0.1-test), verify release workflow triggers and builds complete

### Implementation for User Story 2

- [x] T006 [US2] Create Release workflow in `.github/workflows/release.yml` per contracts/release.yml:
  - Trigger on tags matching `v*.*.*`
  - Set permissions.contents: write
  - Build matrix for 5 platforms (darwin/amd64, darwin/arm64, linux/amd64, linux/arm64, windows/amd64)
  - Use CGO_ENABLED=0 and -ldflags="-s -w" for static binaries
  - Upload artifacts with actions/upload-artifact@v4
  - Download all artifacts in release job
  - Create release with softprops/action-gh-release@v2
  - Set fail_on_unmatched_files: true and generate_release_notes: true
- [x] T007 [US2] Verify release workflow is valid YAML and will trigger correctly (syntax check only)

**Checkpoint**: User Story 2 complete - Release workflow ready for tag-triggered builds

---

## Phase 5: User Story 3 - User Downloads Pre-built Binary (Priority: P3)

**Goal**: Users can download working binaries from GitHub Releases

**Independent Test**: After a release, visit Releases page, download a binary, run it successfully

### Implementation for User Story 3

> Note: User Story 3 requires no additional code - it is fulfilled by the release workflow from US2 successfully publishing binaries. The tasks here are validation only.

- [x] T008 [US3] Verify binary naming convention matches spec: byoman-{goos}-{goarch}[.exe] in release.yml
- [x] T009 [US3] Document download URLs in quickstart.md (already done - verify accuracy)

**Checkpoint**: User Story 3 complete - Users can download binaries when releases are created

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across all user stories

- [x] T010 Run quickstart.md validation steps locally (build, cross-compile test)
- [x] T011 Verify all acceptance scenarios from spec.md are addressed by implementations

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - creates buildable entry point
- **Foundational (Phase 2)**: Depends on Setup - creates directory structure
- **User Story 1 (Phase 3)**: Depends on Foundational - CI workflow
- **User Story 2 (Phase 4)**: Depends on Foundational - Release workflow (can parallel with US1)
- **User Story 3 (Phase 5)**: Depends on US2 - validation only
- **Polish (Phase 6)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - No dependencies on US1 (workflows are independent)
- **User Story 3 (P3)**: Depends on US2 (needs release workflow to produce binaries)

### Within Each User Story

- Workflow file before verification
- All tasks in a story should complete before moving to next priority

### Parallel Opportunities

- **Phase 3 & 4**: T004 (CI workflow) and T006 (Release workflow) can run in parallel - different files, no dependencies
- **Phase 5**: T008 and T009 can run in parallel - different validation tasks

---

## Parallel Example: CI & Release Workflows

```bash
# After Phase 2 (Foundational) completes, launch both workflows in parallel:
Task: "Create CI workflow in .github/workflows/ci.yml" (T004)
Task: "Create Release workflow in .github/workflows/release.yml" (T006)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (main.go entry point)
2. Complete Phase 2: Foundational (directory structure)
3. Complete Phase 3: User Story 1 (CI workflow)
4. **STOP and VALIDATE**: Push to branch, verify CI runs and reports status
5. Deploy/merge if ready - basic CI is now functional

### Incremental Delivery

1. Complete Setup + Foundational → Project is buildable
2. Add User Story 1 → Test by pushing → CI validates code (MVP!)
3. Add User Story 2 → Test by creating tag → Release builds binaries
4. Add User Story 3 → Verify binaries downloadable and executable
5. Each story adds value without breaking previous stories

### Single Developer Strategy

Recommended order for solo implementation:

1. T001, T002 (main.go - enables everything)
2. T003 (directory structure)
3. T004, T005 (CI workflow - immediate value)
4. T006, T007 (Release workflow)
5. T008, T009 (US3 validation)
6. T010, T011 (Polish)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- This feature has 3 new files: main.go, ci.yml, release.yml
- No tests included per spec - CI will run `go test` but no new test files are created
- Binary naming follows Go convention: byoman-{goos}-{goarch}
- Workflows use contracts/ as source of truth for YAML structure
