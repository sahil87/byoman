#!/usr/bin/env bash
# Common functions and variables for all scripts
# Git-agnostic: uses .specify/current file for spec context

# Get repository root (looks for .specify directory or git root)
get_repo_root() {
    # First try git
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
        return
    fi

    # Fall back to finding .specify directory
    local dir="$(pwd)"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.specify" ]]; then
            echo "$dir"
            return
        fi
        dir="$(dirname "$dir")"
    done

    # Last resort: script location
    local script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    (cd "$script_dir/../../.." && pwd)
}

# Get path to .specify/current file
get_current_spec_file() {
    echo "$(get_repo_root)/.specify/current"
}

# Read current spec from .specify/current
get_current_spec() {
    local current_file=$(get_current_spec_file)
    if [[ -f "$current_file" ]]; then
        cat "$current_file"
    else
        echo ""  # Empty = no current spec
    fi
}

# Write current spec to .specify/current
set_current_spec() {
    local spec_name="$1"
    local current_file=$(get_current_spec_file)
    echo "$spec_name" > "$current_file"
}

# List all available specs in specs/ directory
list_available_specs() {
    local repo_root=$(get_repo_root)
    local specs_dir="$repo_root/specs"

    if [[ -d "$specs_dir" ]]; then
        for dir in "$specs_dir"/*; do
            if [[ -d "$dir" ]]; then
                basename "$dir"
            fi
        done
    fi
}

# Get feature directory path from spec name
get_feature_dir() {
    local repo_root="$1"
    local spec_name="$2"
    echo "$repo_root/specs/$spec_name"
}

# Get all feature paths for current spec
# Returns error if no current spec is set
get_feature_paths() {
    local repo_root=$(get_repo_root)
    local current_spec=$(get_current_spec)

    if [[ -z "$current_spec" ]]; then
        echo "ERROR: No current spec set. Run /speckit.switch to select a spec." >&2
        return 1
    fi

    local feature_dir="$repo_root/specs/$current_spec"

    cat <<EOF
REPO_ROOT='$repo_root'
CURRENT_SPEC='$current_spec'
FEATURE_DIR='$feature_dir'
FEATURE_SPEC='$feature_dir/spec.md'
IMPL_PLAN='$feature_dir/plan.md'
TASKS='$feature_dir/tasks.md'
RESEARCH='$feature_dir/research.md'
DATA_MODEL='$feature_dir/data-model.md'
QUICKSTART='$feature_dir/quickstart.md'
CONTRACTS_DIR='$feature_dir/contracts'
EOF
}

# Helper functions for checking files/directories
check_file() { [[ -f "$1" ]] && echo "  ✓ $2" || echo "  ✗ $2"; }
check_dir() { [[ -d "$1" && -n $(ls -A "$1" 2>/dev/null) ]] && echo "  ✓ $2" || echo "  ✗ $2"; }
