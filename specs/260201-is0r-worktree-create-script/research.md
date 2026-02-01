# Research: Git Worktree Creation Script

**Feature**: 260201-is0r-worktree-create-script
**Date**: 2026-02-01

## Research Topics

### 1. Git Worktree Best Practices

**Decision**: Create worktrees as siblings to main repository in `<repo>-worktrees/` directory

**Rationale**:
- Keeps worktrees visually separate from main repository
- Avoids .gitignore complications (worktrees inside repo need ignore rules)
- Provides easy discovery - all worktrees for a project in one sibling directory
- Standard practice recommended by git documentation and community

**Alternatives Considered**:
- Inside repository (rejected: .gitignore complexity, clutter)
- User-specified global directory (rejected: loses project association)
- Bare repository pattern (rejected: overkill for this use case)

### 2. POSIX-Compliant Random Name Generation

**Decision**: Use hardcoded city name array with index selection via `$RANDOM % array_length`

**Rationale**:
- POSIX sh doesn't have arrays, but bash does - target bash for array support
- `/dev/urandom` available on both macOS and Linux
- `$RANDOM` is bash-specific but simpler and sufficient
- ~100 city names provides enough uniqueness for typical use (collision retry handles edge cases)

**Alternatives Considered**:
- `/dev/urandom` with od/tr (more portable but complex)
- External word list file (rejected: adds dependency, harder to install)
- UUID-based names (rejected: not memorable, defeats purpose)
- Date-based names (rejected: not memorable)

**Implementation Pattern**:
```bash
CITIES=("tokyo" "london" "paris" "berlin" ...)
INDEX=$((RANDOM % ${#CITIES[@]}))
NAME="${CITIES[$INDEX]}"
```

### 3. Cross-Platform Application Detection

**Decision**: Tiered detection approach - CLI first, then OS-specific fallbacks

**Rationale**:
- `command -v` is POSIX-compliant and works everywhere
- Most apps with GUI also have CLI (code, cursor, ghostty)
- macOS `mdfind` catches GUI-only apps (iTerm2, Terminal.app)
- Linux .desktop file checks catch GUI-only apps

**Detection Order**:
1. `command -v <cli>` - fastest, cross-platform
2. macOS: `mdfind "kMDItemCFBundleIdentifier == '<bundle-id>'"`
3. Linux: check `/usr/share/applications/*.desktop` and `~/.local/share/applications/*.desktop`

**Alternatives Considered**:
- Only check CLI commands (rejected: misses GUI-only apps)
- Only check GUI methods (rejected: slower, less reliable)
- Hardcode available apps (rejected: not portable)

### 4. Git Default Branch Detection

**Decision**: Check `git symbolic-ref refs/remotes/origin/HEAD` first, fall back to checking main/master existence

**Rationale**:
- `origin/HEAD` is set by git clone and points to default branch
- Some repos may not have origin configured, so need fallback
- main/master check covers 99%+ of repositories

**Implementation Pattern**:
```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$DEFAULT_BRANCH" ]; then
    if git show-ref --verify --quiet refs/heads/main; then
        DEFAULT_BRANCH="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        DEFAULT_BRANCH="master"
    fi
fi
```

**Alternatives Considered**:
- Always use "main" (rejected: breaks master-based repos)
- Read from git config (rejected: not always set)
- Prompt user (rejected: adds friction)

### 5. Menu Interaction Pattern

**Decision**: Numbered menu with single-key selection, re-display on invalid input

**Rationale**:
- Familiar pattern (Conductor uses similar approach)
- Single keystroke for common actions reduces friction
- Clear visual feedback with numbered options
- Exit option (0 or Enter) for "just show me the path" case

**Implementation Pattern**:
```bash
show_menu() {
    echo "Open worktree in:"
    echo "  1) VSCode"
    echo "  2) Cursor"
    # ... dynamically based on available apps
    echo "  0) Exit (path only)"
    printf "Choice: "
}

read -r choice
case "$choice" in
    1) code "$path" ;;
    2) cursor "$path" ;;
    # ...
    0|"") ;; # exit
    *) echo "Invalid choice"; show_menu ;;
esac
```

### 6. Error Message Standards

**Decision**: Follow constitution requirement - what failed, why, suggested remediation

**Rationale**:
- Constitution III requires clear error messages
- Users should never see cryptic failures
- Remediation suggestions reduce support burden

**Error Message Template**:
```bash
error() {
    echo "Error: $1" >&2
    echo "  Why: $2" >&2
    [ -n "$3" ] && echo "  Fix: $3" >&2
    exit 1
}

# Usage:
error "Not a git repository" \
      "wt-create must be run from within a git repository" \
      "Navigate to a git repository and try again"
```

### 7. Branch Existence Detection

**Decision**: Check local branches first, then remote tracking branches

**Rationale**:
- Local branch check is fast: `git show-ref --verify refs/heads/<branch>`
- Remote check requires fetch for accuracy, but can check existing refs
- Auto-fetch and track if remote-only branch

**Implementation Pattern**:
```bash
branch_exists_locally() {
    git show-ref --verify --quiet "refs/heads/$1"
}

branch_exists_remotely() {
    git ls-remote --heads origin "$1" | grep -q "$1"
}

if branch_exists_locally "$BRANCH"; then
    # Use existing local branch
elif branch_exists_remotely "$BRANCH"; then
    # Fetch and track remote branch
else
    # Create new branch from default
fi
```

## Open Questions (Resolved)

All clarifications from spec.md have been resolved:
- ✅ Branch detection: auto-detect local → remote → create new
- ✅ Naming: Random memorable names from hardcoded city list
- ✅ Initial branch naming: `wt/<worktree-name>` pattern
- ✅ Access options: Numbered menu with tool detection
- ✅ Invocation: Standalone shell script
- ✅ Name collision: Silent auto-retry with different name

## Implementation Notes

1. **Shebang**: Use `#!/usr/bin/env bash` for portability (need bash for arrays)
2. **Shellcheck**: Run shellcheck on script before release
3. **Testing**: Manual testing matrix - macOS + Linux, various apps installed/missing
4. **Installation**: Document adding to PATH via symlink or copy
