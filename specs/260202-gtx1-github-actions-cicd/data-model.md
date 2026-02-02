# Data Model: GitHub Actions CI/CD

**Feature**: 260202-gtx1-github-actions-cicd
**Date**: 2026-02-02

## Overview

This feature does not introduce persistent data models in the traditional sense. Instead, it defines:
1. GitHub Actions workflow configurations (YAML schemas)
2. A new Go entry point file (main.go)
3. Build artifacts (binary files)

---

## Entity: CI Workflow

**File**: `.github/workflows/ci.yml`
**Purpose**: Build and test on every push/PR

### Schema (GitHub Actions YAML)

| Field | Type | Value | Description |
|-------|------|-------|-------------|
| name | string | "CI" | Workflow display name |
| on.push.branches | string[] | ["main"] | Trigger on push to main |
| on.pull_request.branches | string[] | ["main"] | Trigger on PR to main |
| jobs.build.runs-on | string | "ubuntu-latest" | Runner environment |
| jobs.build.steps | step[] | see below | Build steps |

### Steps

1. **Checkout**: `actions/checkout@v4`
2. **Setup Go**: `actions/setup-go@v5` with `go-version-file: 'go.mod'`
3. **Build**: `go build -v ./...`
4. **Test**: `go test -v ./...`

---

## Entity: Release Workflow

**File**: `.github/workflows/release.yml`
**Purpose**: Build cross-platform binaries and publish to GitHub Releases

### Schema (GitHub Actions YAML)

| Field | Type | Value | Description |
|-------|------|-------|-------------|
| name | string | "Release" | Workflow display name |
| on.push.tags | string[] | ["v*.*.*"] | Trigger on semver tags |
| permissions.contents | string | "write" | Allow release creation |
| jobs.build.strategy.matrix | object | 5 platforms | Build matrix |
| jobs.release.needs | string[] | ["build"] | Depends on build job |

### Build Matrix

```yaml
matrix:
  include:
    - goos: darwin
      goarch: amd64
    - goos: darwin
      goarch: arm64
    - goos: linux
      goarch: amd64
    - goos: linux
      goarch: arm64
    - goos: windows
      goarch: amd64
```

---

## Entity: Build Artifact

**Purpose**: Compiled binary for a specific platform

### Schema

| Field | Type | Format | Example |
|-------|------|--------|---------|
| name | string | `byoman-{goos}-{goarch}[.exe]` | byoman-darwin-arm64 |
| goos | enum | darwin, linux, windows | darwin |
| goarch | enum | amd64, arm64 | arm64 |
| extension | string | "" or ".exe" | "" |

### Naming Convention

- macOS arm64: `byoman-darwin-arm64`
- macOS amd64: `byoman-darwin-amd64`
- Linux arm64: `byoman-linux-arm64`
- Linux amd64: `byoman-linux-amd64`
- Windows amd64: `byoman-windows-amd64.exe`

---

## Entity: main.go Entry Point

**File**: `main.go` (repository root)
**Purpose**: Application entry point that invokes `app.Run()`

### Schema

| Field | Type | Description |
|-------|------|-------------|
| package | string | "main" |
| import | string[] | ["byoman/internal/app", "fmt", "os"] |
| func main() | function | Calls app.Run(), handles errors |

### Behavior

1. Call `app.Run()`
2. If error returned, print to stderr and exit with code 1
3. If success, exit with code 0

---

## State Transitions

### CI Workflow States

```
[Push/PR Event] → [Checkout] → [Setup Go] → [Build] → [Test] → [Report Status]
                                                                      ↓
                                                            [Pass] or [Fail]
```

### Release Workflow States

```
[Tag Push v*.*.*] → [Build Job (5 parallel)] → [Upload Artifacts]
                                                        ↓
                                               [Release Job]
                                                        ↓
                                               [Download Artifacts]
                                                        ↓
                                               [Create GitHub Release]
                                                        ↓
                                               [Upload Binaries]
```

---

## Validation Rules

### Version Tag
- Must match pattern `v*.*.*` (e.g., v1.0.0, v2.3.4)
- Invalid: v1, v1.0, v1-beta, test-tag

### Build Artifact
- Must exist for all 5 platforms before release is created
- Windows binary must have `.exe` extension
- Unix binaries must not have extension

### main.go
- Must be valid Go code
- Must import `byoman/internal/app`
- Must call `app.Run()` and handle returned error
