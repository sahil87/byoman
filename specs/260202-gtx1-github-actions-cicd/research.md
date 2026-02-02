# Research: GitHub Actions CI/CD for byoman

**Feature**: 260202-gtx1-github-actions-cicd
**Date**: 2026-02-02

## Research Questions Addressed

1. GitHub Actions best practices for Go projects
2. Go cross-compilation for multiple platforms
3. GitHub Releases asset upload patterns

---

## Decision 1: GitHub Actions Workflow Structure

**Decision**: Use two separate workflows - CI (build/test on push/PR) and Release (on version tags)

**Rationale**:
- Separation of concerns - CI runs on every change, releases only on tags
- CI can fail fast; releases need all platforms to complete
- Different trigger conditions require different workflow files

**Alternatives Considered**:
- Single workflow with conditional jobs - Rejected: more complex, harder to maintain
- GoReleaser - Rejected: adds external dependency for simple use case

### CI Workflow Pattern

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: 'go.mod'
      - run: go build -v ./...
      - run: go test -v ./...
```

---

## Decision 2: Go Cross-Compilation Approach

**Decision**: Use CGO_ENABLED=0 with GOOS/GOARCH environment variables, build all platforms from ubuntu-latest

**Rationale**:
- byoman uses pure Go dependencies (bubbletea, lipgloss, bubbles) - no CGO needed
- CGO_ENABLED=0 produces truly static binaries
- Building from single runner simplifies workflow (no matrix OS needed)
- Darwin/Windows cross-compilation works perfectly without native runners

**Alternatives Considered**:
- Native runners per OS (macos-latest, windows-latest) - Rejected: slower, more expensive, unnecessary for pure Go
- CGO_ENABLED=1 - Rejected: not needed, would complicate cross-compilation

### Platform Matrix

| Target | GOOS | GOARCH | Output Name |
|--------|------|--------|-------------|
| macOS Intel | darwin | amd64 | byoman-darwin-amd64 |
| macOS Apple Silicon | darwin | arm64 | byoman-darwin-arm64 |
| Linux x64 | linux | amd64 | byoman-linux-amd64 |
| Linux ARM64 | linux | arm64 | byoman-linux-arm64 |
| Windows x64 | windows | amd64 | byoman-windows-amd64.exe |

### Build Flags

```bash
CGO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH go build -ldflags="-s -w" -o byoman-${GOOS}-${GOARCH} .
```

- `-ldflags="-s -w"`: Strips debug info, reduces binary size ~30%
- CGO_ENABLED=0: Ensures pure Go, static binary

---

## Decision 3: Binary Naming Convention

**Decision**: Use `byoman-{goos}-{goarch}[.exe]` format

**Rationale**:
- Matches Go's native GOOS/GOARCH identifiers
- No version in filename (version is in release tag/title)
- `.exe` extension only for Windows (required by OS)

**Alternatives Considered**:
- `byoman-{version}-{os}-{arch}` - Rejected: version already in release
- `byoman_{os}_{arch}` - Rejected: hyphens are more common in CLI tools

---

## Decision 4: Release Creation Strategy

**Decision**: Two-job pattern with `softprops/action-gh-release@v2`

**Rationale**:
- v2.5.0+ maintains draft state until all uploads complete (atomic)
- Widely used (30k+ stars), actively maintained
- Simple declarative YAML configuration
- `fail_on_unmatched_files: true` ensures build failures prevent release

**Alternatives Considered**:
- `gh` CLI directly - Viable alternative, requires more shell scripting
- `ncipollo/release-action` - Also good, slightly less popular
- GoReleaser - Overkill for simple use case

### Release Workflow Pattern

```yaml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'

permissions:
  contents: write

jobs:
  build:
    # ... matrix build jobs uploading artifacts ...

  release:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          merge-multiple: true

      - uses: softprops/action-gh-release@v2
        with:
          files: byoman-*
          generate_release_notes: true
          fail_on_unmatched_files: true
```

---

## Decision 5: Tag Pattern for Releases

**Decision**: Trigger releases on `v*.*.*` pattern (semantic versioning)

**Rationale**:
- Standard convention for Go projects
- Clear distinction between releases and other tags
- `generate_release_notes: true` creates changelog from PR titles

**Alternatives Considered**:
- `v*` (more permissive) - Rejected: could match unwanted tags like v1-beta
- Manual release creation - Rejected: more error-prone, less automated

---

## Decision 6: main.go Location

**Decision**: Create `main.go` at repository root (not in cmd/ subdirectory)

**Rationale**:
- Simplest structure for single-binary project
- Module is already named `byoman`, root main.go means `go install byoman@latest` works
- Consistent with existing project structure (internal/ packages at root)

**Alternatives Considered**:
- `cmd/byoman/main.go` - Standard for multi-binary projects, unnecessary here
- `cmd/main.go` - Non-standard, would complicate go install path

---

## Technical Constraints Confirmed

1. **Go Version**: 1.25.6 (from go.mod) - available in GitHub Actions runners
2. **No CGO Required**: All dependencies are pure Go
3. **No Tests Exist**: CI will initially only build; tests can be added later
4. **No Code Signing**: Out of scope per spec

---

## Sources

- [actions/setup-go](https://github.com/actions/setup-go)
- [Building and testing Go - GitHub Docs](https://docs.github.com/en/actions/use-cases-and-examples/building-and-testing/building-and-testing-go)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [Go Cross-compilation](https://opensource.com/article/21/1/go-cross-compiling)
- [Binary Naming Conventions](https://blog.urth.org/2023/04/16/naming-your-binary-executable-releases/)
