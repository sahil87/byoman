#!/usr/bin/env bash

# Set the current spec
#
# Usage: ./set-current.sh <spec-identifier>
#
# ARGUMENTS:
#   spec-identifier    Can be:
#                      - Full spec name (e.g., "260131-a7k2-user-auth")
#                      - List index (e.g., "1" for first spec, "2" for second)
#                      - Partial match (e.g., "user-auth" matches "260131-a7k2-user-auth")
#
# OPTIONS:
#   --json    Output in JSON format
#   --help    Show help message

set -e

JSON_MODE=false
SPEC_ARG=""

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --help|-h)
            echo "Usage: $0 [--json] <spec-identifier>"
            echo ""
            echo "Arguments:"
            echo "  spec-identifier    Can be:"
            echo "                     - Full spec name (e.g., '260131-a7k2-user-auth')"
            echo "                     - List index (e.g., '1' for first, '2' for second)"
            echo "                     - Partial match (e.g., 'user-auth')"
            echo ""
            echo "Options:"
            echo "  --json    Output results in JSON format"
            echo "  --help    Show this help message"
            exit 0
            ;;
        *)
            if [[ -z "$SPEC_ARG" ]]; then
                SPEC_ARG="$arg"
            else
                echo "ERROR: Too many arguments. Use --help for usage information." >&2
                exit 1
            fi
            ;;
    esac
done

if [[ -z "$SPEC_ARG" ]]; then
    echo "ERROR: Spec name or number required. Use --help for usage information." >&2
    exit 1
fi

# Source common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
SPECS_DIR="$REPO_ROOT/specs"

# Find the spec
FOUND_SPEC=""

# Collect all specs into an array
mapfile -t all_specs < <(list_available_specs)

# First, try exact match
if [[ -d "$SPECS_DIR/$SPEC_ARG" ]]; then
    FOUND_SPEC="$SPEC_ARG"
# Try matching by list index (1, 2, 3, etc.)
elif [[ "$SPEC_ARG" =~ ^[0-9]+$ ]]; then
    index=$((10#$SPEC_ARG - 1))  # Convert to 0-based index
    if [[ $index -ge 0 ]] && [[ $index -lt ${#all_specs[@]} ]]; then
        FOUND_SPEC="${all_specs[$index]}"
    fi
fi

# If still not found, try partial/substring match
if [[ -z "$FOUND_SPEC" ]]; then
    matches=()
    for spec in "${all_specs[@]}"; do
        if [[ "$spec" == *"$SPEC_ARG"* ]]; then
            matches+=("$spec")
        fi
    done

    if [[ ${#matches[@]} -eq 1 ]]; then
        FOUND_SPEC="${matches[0]}"
    elif [[ ${#matches[@]} -gt 1 ]]; then
        echo "ERROR: Ambiguous spec '$SPEC_ARG' matches multiple specs:" >&2
        for match in "${matches[@]}"; do
            echo "  $match" >&2
        done
        exit 1
    fi
fi

if [[ -z "$FOUND_SPEC" ]]; then
    echo "ERROR: Spec not found: $SPEC_ARG" >&2
    echo "Available specs:" >&2
    i=1
    for spec in "${all_specs[@]}"; do
        echo "  $i. $spec" >&2
        ((i++))
    done
    exit 1
fi

# Set as current
set_current_spec "$FOUND_SPEC"

# Output results
if $JSON_MODE; then
    printf '{"current":"%s","success":true}\n' "$FOUND_SPEC"
else
    echo "Current spec set to: $FOUND_SPEC"
fi
