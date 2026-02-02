# Feature Specification: GitHub Actions CI/CD

**Feature Branch**: `260202-gtx1-github-actions-cicd`
**Created**: 2026-02-02
**Status**: Draft
**Input**: User description: "Add CI/CD github actions so this gets built on github. Need to decide frequency of build (every commit?) and where the artifacts are posted (the release page?)"

## Clarifications

### Session 2026-02-02

- Q: Should creating main.go be part of this feature or a prerequisite? → A: Include as part of this feature

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Contributor Validates Code Changes (Priority: P1)

A developer pushes code changes to a branch or opens a pull request. The CI system automatically builds the project and runs tests to validate the changes work correctly before merging.

**Why this priority**: This is the core value of CI - catching broken builds and regressions before they reach the main branch. Without this, all other CI/CD features provide less value.

**Independent Test**: Can be fully tested by pushing a commit to a branch and observing the workflow runs, builds successfully, and reports status back to the PR/commit.

**Acceptance Scenarios**:

1. **Given** a developer pushes a commit to any branch, **When** the push is received by GitHub, **Then** the CI workflow starts automatically and builds the project.
2. **Given** a developer opens a pull request, **When** the PR is created or updated, **Then** the CI workflow runs and reports pass/fail status on the PR.
3. **Given** the build fails, **When** viewing the PR or commit, **Then** the failure is clearly indicated with a link to the build logs.
4. **Given** the build succeeds, **When** viewing the PR, **Then** a green checkmark indicates the code is safe to merge.

---

### User Story 2 - Maintainer Releases New Version (Priority: P2)

A maintainer creates a version tag (e.g., v1.0.0) to release a new version. The CD system automatically builds release binaries for all supported platforms and publishes them to GitHub Releases.

**Why this priority**: This is the distribution mechanism - users need downloadable binaries. It depends on P1 (build must work) but enables actual software distribution.

**Independent Test**: Can be tested by creating a version tag and verifying binaries appear on the GitHub Releases page.

**Acceptance Scenarios**:

1. **Given** a maintainer creates a tag matching the pattern `v*.*.*`, **When** the tag is pushed, **Then** the release workflow triggers automatically.
2. **Given** the release workflow runs, **When** builds complete for all platforms, **Then** binaries are uploaded to a new GitHub Release.
3. **Given** a release is published, **When** a user visits the Releases page, **Then** they can download pre-built binaries for macOS, Linux, and Windows.
4. **Given** a release build fails, **When** viewing the Actions tab, **Then** the failure is logged and no partial release is published.

---

### User Story 3 - User Downloads Pre-built Binary (Priority: P3)

A user wants to install byoman without building from source. They visit the GitHub Releases page and download the appropriate binary for their operating system and architecture.

**Why this priority**: This is the end-user experience that P2 enables. It's the outcome we're building toward but depends on P2 working correctly.

**Independent Test**: Can be tested by visiting the Releases page, downloading a binary, and running it successfully.

**Acceptance Scenarios**:

1. **Given** a user visits the GitHub Releases page, **When** they view the latest release, **Then** they see binaries available for macOS (arm64, amd64), Linux (arm64, amd64), and Windows (amd64).
2. **Given** a user downloads a macOS binary, **When** they run it, **Then** the byoman TUI launches correctly.
3. **Given** a user downloads a Linux binary, **When** they run it on a compatible system with tmux installed, **Then** the byoman TUI launches correctly.

---

### Edge Cases

- What happens when a tag is pushed that doesn't match the version pattern (e.g., `test-tag`)? → Release workflow should not trigger.
- How does the system handle builds on forks? → CI should run on fork PRs but not have access to release secrets.
- What happens if the repository has no main.go entry point? → Build should fail with a clear error message.
- How are concurrent pushes handled? → Each push triggers its own workflow run; GitHub manages queuing.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST trigger a CI build on every push to any branch.
- **FR-002**: System MUST trigger a CI build on every pull request (open, synchronize, reopen).
- **FR-003**: System MUST report build status (pass/fail) back to GitHub commits and pull requests.
- **FR-004**: System MUST trigger a release workflow only when a tag matching `v*.*.*` pattern is pushed.
- **FR-005**: System MUST build binaries for these platforms:
  - macOS arm64 (Apple Silicon)
  - macOS amd64 (Intel)
  - Linux arm64
  - Linux amd64
  - Windows amd64
- **FR-006**: System MUST upload release binaries to GitHub Releases with the tagged version.
- **FR-007**: System MUST include the binary name in a consistent format: `byoman-{os}-{arch}` (e.g., `byoman-darwin-arm64`, `byoman-linux-amd64`, `byoman-windows-amd64.exe`).
- **FR-008**: System MUST run `go build` to compile the binary.
- **FR-009**: System MUST run `go test ./...` as part of CI to validate code correctness.
- **FR-010**: Release workflow MUST NOT publish partial releases if any platform build fails.
- **FR-011**: This feature MUST include creating a `main.go` entry point that invokes the existing `app.Run()` function to enable Go builds.

### Key Entities

- **Workflow**: A GitHub Actions configuration that defines when and how to run CI/CD jobs.
- **Build Artifact**: A compiled binary produced by the build process for a specific OS/architecture combination.
- **Release**: A GitHub Release containing downloadable binaries for all supported platforms, associated with a version tag.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All pushes to the repository trigger a CI workflow within 30 seconds of the push event.
- **SC-002**: Build status is visible on pull requests within 5 minutes of workflow start.
- **SC-003**: Tagged releases produce downloadable binaries for all 5 supported platforms within 15 minutes.
- **SC-004**: Users can download and execute released binaries without additional build steps.
- **SC-005**: 100% of release builds produce working binaries (verified by basic execution test).

## Assumptions

- A `main.go` entry point will be created as part of this feature (FR-011).
- The Go version specified in `go.mod` (1.25.6) is available in GitHub Actions runners.
- No code signing is required for initial releases (can be added later).
- The project uses standard Go module structure with `go.mod` and `go.sum`.
- tmux dependency is a runtime requirement only - binaries can be built without tmux installed.

## Out of Scope

- Code signing for macOS/Windows binaries
- Homebrew formula or package manager distribution
- Automated changelog generation
- Version bumping automation
- Docker image builds
- Deployment to external platforms
