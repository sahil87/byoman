# montevideo Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-01-31

## Active Technologies
- Bash (POSIX-compliant shell scripts) + Standard POSIX utilities (date, tr, head, /dev/urandom or $RANDOM) (260132-spec-naming-scheme)
- Filesystem (specs/ directory) (260132-spec-naming-scheme)
- POSIX-compliant shell script (sh/bash compatible) + git, standard POSIX utilities (date, tr, head, /dev/urandom or $RANDOM) (260201-is0r-worktree-create-script)
- N/A (git manages worktree metadata) (260201-is0r-worktree-create-script)
- Bash (POSIX-compliant shell scripts, tested with bash 3.2+ and bash 5+) + git (core), gh CLI (required for `wt-merge`, optional with fallback for `wt-pr`) (260201-gvao-wt-lifecycle-scripts)
- N/A (git manages all metadata) (260201-gvao-wt-lifecycle-scripts)

- Go 1.21+ (compiled single binary, no runtime dependencies) + bubbletea (TUI framework), lipgloss (styling), bubbles (input components) (002-speckit-plan-claude)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Go 1.21+ (compiled single binary, no runtime dependencies)

## Code Style

Go 1.21+ (compiled single binary, no runtime dependencies): Follow standard conventions

## Recent Changes
- 260201-gvao-wt-lifecycle-scripts: Added Bash (POSIX-compliant shell scripts, tested with bash 3.2+ and bash 5+) + git (core), gh CLI (required for `wt-merge`, optional with fallback for `wt-pr`)
- 260201-is0r-worktree-create-script: Added POSIX-compliant shell script (sh/bash compatible) + git, standard POSIX utilities (date, tr, head, /dev/urandom or $RANDOM)
- 260132-spec-naming-scheme: Added Bash (POSIX-compliant shell scripts) + Standard POSIX utilities (date, tr, head, /dev/urandom or $RANDOM)


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
