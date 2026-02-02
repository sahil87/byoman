# Quickstart: GitHub Actions CI/CD

**Feature**: 260202-gtx1-github-actions-cicd

## Overview

This feature adds:
1. CI workflow - builds and tests on every push/PR
2. Release workflow - creates cross-platform binaries on version tags
3. main.go entry point - enables Go builds

## Prerequisites

- Git repository already hosted on GitHub
- Go 1.25.6+ installed locally (for testing)

## Files to Create

```
.github/
└── workflows/
    ├── ci.yml        # Build/test on push/PR
    └── release.yml   # Release binaries on tags

main.go               # Entry point calling app.Run()
```

## Implementation Steps

### Step 1: Create main.go

Create `main.go` at repository root:

```go
package main

import (
    "byoman/internal/app"
    "fmt"
    "os"
)

func main() {
    if err := app.Run(); err != nil {
        fmt.Fprintln(os.Stderr, err)
        os.Exit(1)
    }
}
```

### Step 2: Create CI Workflow

Create `.github/workflows/ci.yml`:

See [contracts/ci.yml](./contracts/ci.yml) for the full workflow.

Key points:
- Triggers on push to main and PRs targeting main
- Uses `go-version-file: 'go.mod'` to match project Go version
- Runs `go build` and `go test`

### Step 3: Create Release Workflow

Create `.github/workflows/release.yml`:

See [contracts/release.yml](./contracts/release.yml) for the full workflow.

Key points:
- Triggers only on tags matching `v*.*.*`
- Builds 5 platforms in parallel (darwin/linux arm64/amd64, windows amd64)
- Uses `softprops/action-gh-release` for atomic release creation

## Usage

### Running CI

CI runs automatically on:
- Every push to `main` branch
- Every pull request targeting `main`

### Creating a Release

1. Tag the commit with a semver version:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. GitHub Actions will:
   - Build binaries for all 5 platforms
   - Create a GitHub Release with the tag name
   - Upload all binaries to the release

### Downloading Binaries

After release, users can download from:
```
https://github.com/{owner}/{repo}/releases/latest
```

Binary naming:
- macOS Apple Silicon: `byoman-darwin-arm64`
- macOS Intel: `byoman-darwin-amd64`
- Linux x64: `byoman-linux-amd64`
- Linux ARM64: `byoman-linux-arm64`
- Windows: `byoman-windows-amd64.exe`

## Local Testing

### Test the build locally

```bash
# Build for current platform
go build -v .

# Run the binary
./byoman
```

### Test cross-compilation locally

```bash
# Build for Linux on macOS
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o byoman-linux-amd64 .
```

## Troubleshooting

### Build fails with "package not found"

Ensure `main.go` is at repository root and imports `byoman/internal/app`.

### Release not triggered

Check that your tag matches `v*.*.*` pattern (e.g., v1.0.0). Tags like `v1` or `v1.0` won't trigger.

### Partial release created

This shouldn't happen with `fail_on_unmatched_files: true`. If it does, delete the draft release and re-push the tag.
