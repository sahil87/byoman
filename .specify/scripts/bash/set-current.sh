#!/usr/bin/env bash

# Set the current spec
#
# Usage: ./set-current.sh <spec-name-or-number>
#
# ARGUMENTS:
#   spec-name-or-number    Either the full spec name (e.g., "001-my-feature")
#                          or just the number (e.g., "1" or "001")
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
            echo "Usage: $0 [--json] <spec-name-or-number>"
            echo ""
            echo "Arguments:"
            echo "  spec-name-or-number    Full spec name (e.g., '001-my-feature')"
            echo "                         or number (e.g., '1' or '001')"
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

# First, try exact match
if [[ -d "$SPECS_DIR/$SPEC_ARG" ]]; then
    FOUND_SPEC="$SPEC_ARG"
else
    # Try matching by number prefix
    # Normalize the number (remove leading zeros, then re-pad)
    if [[ "$SPEC_ARG" =~ ^[0-9]+$ ]]; then
        PADDED_NUM=$(printf "%03d" "$((10#$SPEC_ARG))")

        for dir in "$SPECS_DIR"/"$PADDED_NUM"-*; do
            if [[ -d "$dir" ]]; then
                FOUND_SPEC="$(basename "$dir")"
                break
            fi
        done
    fi
fi

if [[ -z "$FOUND_SPEC" ]]; then
    echo "ERROR: Spec not found: $SPEC_ARG" >&2
    echo "Available specs:" >&2
    for dir in "$SPECS_DIR"/*; do
        if [[ -d "$dir" ]]; then
            echo "  $(basename "$dir")" >&2
        fi
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
