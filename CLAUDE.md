# montevideo Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-01-31

## Active Technologies
- Bash (POSIX-compliant shell scripts) + Standard POSIX utilities (date, tr, head, /dev/urandom or $RANDOM) (260132-spec-naming-scheme)
- Filesystem (specs/ directory) (260132-spec-naming-scheme)
- POSIX-compliant shell script (sh/bash compatible) + git, standard POSIX utilities (date, tr, head, /dev/urandom or $RANDOM) (260201-is0r-worktree-create-script)
- N/A (git manages worktree metadata) (260201-is0r-worktree-create-script)
- Bash (POSIX-compliant shell scripts, tested with bash 3.2+ and bash 5+) + git (core), gh CLI (required for `wt-merge`, optional with fallback for `wt-pr`) (260201-gvao-wt-lifecycle-scripts)
- N/A (git manages all metadata) (260201-gvao-wt-lifecycle-scripts)
- Bash (POSIX-compliant, tested with bash 3.2+ and 5+) + git (branch operations, remote checks), standard POSIX utilities (260201-krgf-speckit-branch-naming)
- N/A (git manages all branch state) (260201-krgf-speckit-branch-naming)
- Bash (POSIX-compliant shell scripts, tested with bash 3.2+ and 5+) + git (for worktree scripts), standard POSIX utilities (260201-gofw-consolidate-bin-specify)
- N/A (filesystem operations only) (260201-gofw-consolidate-bin-specify)
- N/A (all session data sourced directly from tmux at runtime) (260201-2o4w-byoby-session-manager)
- Go 1.21+ (existing project) + bubbletea (TUI framework), lipgloss (styling), bubbles (input components) - unchanged (260202-mjk2-rename-byoman-executable)
- N/A (session data sourced from tmux at runtime) (260202-mjk2-rename-byoman-executable)
- Go 1.25.6 + bubbletea v1.3.10 (TUI), lipgloss v1.1.0 (styling), bubbles v0.21.0 (components) (260202-2gdn-byobu-sessions)
- N/A (all session data sourced from byobu/tmux at runtime) (260202-2gdn-byobu-sessions)
- Go 1.25.6 (per go.mod) + bubbletea, lipgloss, bubbles (Charm ecosystem for TUI) (260202-gtx1-github-actions-cicd)
- N/A (runtime only - tmux manages session data) (260202-gtx1-github-actions-cicd)
- POSIX-compliant shell script (bash 3.2+ compatible) + git, byobu (optional), tmux (byobu backend), standard POSIX utilities (260202-4act-byobu-tab-option)
- Bash (POSIX-compliant, bash 3.2+ compatible) + git (for repo root detection), standard POSIX utilities (date) (260205-k8ui-ideas-checklist-command)
- Flat file (`.specify/ideas.md`) (260205-k8ui-ideas-checklist-command)

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
- 260205-k8ui-ideas-checklist-command: Added Bash (POSIX-compliant, bash 3.2+ compatible) + git (for repo root detection), standard POSIX utilities (date)
- 260202-4act-byobu-tab-option: Added POSIX-compliant shell script (bash 3.2+ compatible) + git, byobu (optional), tmux (byobu backend), standard POSIX utilities
- 260202-gtx1-github-actions-cicd: Added Go 1.25.6 (per go.mod) + bubbletea, lipgloss, bubbles (Charm ecosystem for TUI)


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
