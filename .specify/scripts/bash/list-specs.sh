#!/usr/bin/env bash

# List all available specs and show current spec
#
# Usage: ./list-specs.sh [OPTIONS]
#
# OPTIONS:
#   --json    Output in JSON format
#   --help    Show help message
#
# OUTPUTS:
#   JSON mode: {"specs":["001-foo","002-bar"],"current":"001-foo"}
#   Text mode: List of specs with current marked

set -e

JSON_MODE=false

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --help|-h)
            echo "Usage: $0 [--json]"
            echo "  --json    Output results in JSON format"
            echo "  --help    Show this help message"
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Source common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
SPECS_DIR="$REPO_ROOT/specs"
CURRENT=$(get_current_spec)

# Collect all specs using shared function
mapfile -t specs < <(list_available_specs)

# Output results
if $JSON_MODE; then
    # Build JSON array of specs
    if [[ ${#specs[@]} -eq 0 ]]; then
        json_specs="[]"
    else
        json_specs=$(printf '"%s",' "${specs[@]}")
        json_specs="[${json_specs%,}]"
    fi

    # Handle empty current
    if [[ -z "$CURRENT" ]]; then
        printf '{"specs":%s,"current":null}\n' "$json_specs"
    else
        printf '{"specs":%s,"current":"%s"}\n' "$json_specs" "$CURRENT"
    fi
else
    if [[ ${#specs[@]} -eq 0 ]]; then
        echo "No specs found in $SPECS_DIR"
        echo "Run /speckit.specify to create a new spec."
    else
        echo "Available specs:"
        for i in "${!specs[@]}"; do
            spec="${specs[$i]}"
            if [[ "$spec" == "$CURRENT" ]]; then
                echo "  $((i + 1)). $spec  [current]"
            else
                echo "  $((i + 1)). $spec"
            fi
        done

        if [[ -z "$CURRENT" ]]; then
            echo ""
            echo "No current spec set. Run /speckit.switch to select one."
        fi
    fi
fi
