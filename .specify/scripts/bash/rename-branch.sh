#!/usr/bin/env bash
#
# rename-branch.sh - Rename git branch to match spec name
#
# Called after spec creation to rename temporary worktree branches (wt/*)
# to canonical spec-based names (YYMMDD-XXXX-slug format).
#
# Usage: rename-branch.sh --target <spec-name> [--custom-branch <name>]
#
# Exit codes:
#   0 - Success or correctly skipped
#   1 - General error
#   3 - Git command failed
#   4 - Retry exhausted (all collision suffixes tried)

set -e

# Source common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Exit codes
EXIT_SUCCESS=0
EXIT_GENERAL_ERROR=1
EXIT_GIT_ERROR=3
EXIT_RETRY_EXHAUSTED=4

# --- Helper Functions ---

# Check if branch matches wt/* pattern (temporary worktree branch)
is_temporary_branch() {
    local branch="$1"
    [[ "$branch" == wt/* ]]
}

# Check if branch is main or master (protected)
is_protected_branch() {
    local branch="$1"
    [[ "$branch" == "main" || "$branch" == "master" ]]
}

# Check if branch exists in local refs
branch_exists_locally() {
    local branch="$1"
    git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null
}

# Check if branch exists on origin remote
branch_exists_remotely() {
    local branch="$1"
    git ls-remote --heads origin "$branch" 2>/dev/null | grep -q "refs/heads/$branch"
}

# Sanitize branch name for git compatibility
# Extends clean_spec_name pattern: lowercase, spaces to hyphens, remove invalid chars
# Invalid chars: ~ ^ : ? * [ \ and control characters
sanitize_branch_name() {
    local name="$1"
    echo "$name" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/ /-/g' \
        | sed 's/[~^:?*\[\\]//g' \
        | sed 's/-\+/-/g' \
        | sed 's/^-//' \
        | sed 's/-$//'
}

# Find available branch name with numeric suffix collision resolution
# Tries up to 10 suffixes (-2 through -11)
# Returns: available branch name, or empty string if all exhausted
find_available_branch_name() {
    local target="$1"

    # If target doesn't exist locally, return it
    if ! branch_exists_locally "$target"; then
        echo "$target"
        return 0
    fi

    # Try suffixes -2 through -11 (10 attempts per R4)
    for i in $(seq 2 11); do
        local candidate="${target}-${i}"
        if ! branch_exists_locally "$candidate"; then
            echo "$candidate"
            return 0
        fi
    done

    # All suffixes exhausted
    return 1
}

# --- Main Function ---

# Main rename operation
# Returns: 0 on success/skip, non-zero on failure
rename_branch() {
    local target_spec="$1"
    local custom_branch="${2:-}"

    # Get current branch name
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || {
        log_error "Failed to get current branch"
        return $EXIT_GIT_ERROR
    }

    # Handle non-temporary (canonical) branches
    if ! is_temporary_branch "$current_branch"; then
        # Check if on protected branch (main/master)
        if is_protected_branch "$current_branch"; then
            log_warning "Warning: Working on '$current_branch' branch"
            log_warning "  Consider creating a feature branch: git checkout -b $target_spec"
            return $EXIT_SUCCESS
        fi

        # For canonical branches without explicit --branch flag, preserve
        if [ -z "$custom_branch" ]; then
            log_info "Branch preserved: $current_branch (already canonical)"
            return $EXIT_SUCCESS
        fi
        # With --branch flag, allow rename of canonical branches (FR-005)
    fi

    # Compute target branch name
    local target
    if [ -n "$custom_branch" ]; then
        target=$(sanitize_branch_name "$custom_branch")
    else
        target=$(sanitize_branch_name "$target_spec")
    fi

    # Find available branch name (handles local collision)
    local final_target
    final_target=$(find_available_branch_name "$target")
    if [ $? -ne 0 ] || [ -z "$final_target" ]; then
        log_warning "Branch rename failed"
        log_warning "  Why: Target branch '$target' exists locally and all suffixed variants exhausted"
        log_warning "  Spec created successfully. You can rename the branch manually with:"
        log_warning "    git branch -m $current_branch ${target}-custom"
        return $EXIT_RETRY_EXHAUSTED
    fi

    # Warn if target had local collision and was adjusted
    if [ "$final_target" != "$target" ]; then
        log_warning "Branch $target exists locally, using: $final_target"
    fi

    # Check remote collision for auto-generated names (not custom branch per R5)
    if [ -z "$custom_branch" ]; then
        if branch_exists_remotely "$final_target"; then
            log_warning "Branch $final_target exists on remote origin"
            log_warning "  (You may be continuing work on an existing feature)"
        fi
    fi

    # Execute the rename
    if ! git branch -m "$current_branch" "$final_target" 2>/dev/null; then
        log_error "Failed to rename branch: git branch -m $current_branch $final_target"
        return $EXIT_GIT_ERROR
    fi

    # Output success message
    log_success "Renamed branch: $current_branch → $final_target"

    # Prompt to push (T021, T022)
    # Skip if JSON mode or no remote configured
    if ! $JSON_MODE && git remote 2>/dev/null | grep -q origin; then
        echo -n "Push to origin and set up tracking? [y/N] "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            if git push -u origin "$final_target" 2>/dev/null; then
                log_success "Pushed and tracking set: origin/$final_target"
            else
                log_warning "Push failed. You can push manually: git push -u origin $final_target"
            fi
        fi
    fi

    return $EXIT_SUCCESS
}

# --- Argument Parsing ---

TARGET_SPEC=""
CUSTOM_BRANCH=""
JSON_MODE=false

while [ $# -gt 0 ]; do
    case "$1" in
        --target)
            shift
            TARGET_SPEC="$1"
            ;;
        --custom-branch)
            shift
            CUSTOM_BRANCH="$1"
            ;;
        --json)
            JSON_MODE=true
            ;;
        --help|-h)
            echo "Usage: $0 --target <spec-name> [--custom-branch <name>] [--json]"
            echo ""
            echo "Options:"
            echo "  --target <name>        Spec name to use for branch (required)"
            echo "  --custom-branch <name> Use this branch name instead of spec name"
            echo "  --json                 Output in JSON format"
            echo "  --help, -h             Show this help message"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit $EXIT_GENERAL_ERROR
            ;;
    esac
    shift
done

# Validate required arguments
if [ -z "$TARGET_SPEC" ]; then
    log_error "--target is required"
    exit $EXIT_GENERAL_ERROR
fi

# Run the rename
rename_branch "$TARGET_SPEC" "$CUSTOM_BRANCH"
