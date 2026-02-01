#!/usr/bin/env bash

# List all available specs and show current spec
#
# Usage: ./list-specs.sh [OPTIONS]
#
# OPTIONS:
#   --json         Output in JSON format
#   --limit N      Show only the last N specs (default: 10)
#   --all          Show all specs (override limit)
#   --help         Show help message
#
# OUTPUTS:
#   JSON mode: {"specs":[...],"current":"...","total":N,"showing":M}
#   Text mode: List of specs with current marked

set -e

JSON_MODE=false
SHOW_ALL=false
LIMIT=10

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json)
            JSON_MODE=true
            shift
            ;;
        --all)
            SHOW_ALL=true
            shift
            ;;
        --limit)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "ERROR: --limit requires a number argument" >&2
                exit 1
            fi
            LIMIT="$2"
            shift 2
            ;;
        --limit=*)
            LIMIT="${1#--limit=}"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--json] [--limit N] [--all]"
            echo "  --json      Output results in JSON format"
            echo "  --limit N   Show only the last N specs (default: 10)"
            echo "  --all       Show all specs (override limit)"
            echo "  --help      Show this help message"
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$1'. Use --help for usage information." >&2
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

# Collect all specs using shared function (POSIX-compatible, no mapfile)
all_specs=()
while IFS= read -r line; do
    [[ -n "$line" ]] && all_specs+=("$line")
done < <(list_available_specs)

total_count=${#all_specs[@]}

# Determine which specs to show
if $SHOW_ALL || [[ $total_count -le $LIMIT ]]; then
    specs=("${all_specs[@]}")
    start_index=0
else
    # Show only the last N specs
    start_index=$((total_count - LIMIT))
    specs=("${all_specs[@]:$start_index:$LIMIT}")
fi

showing_count=${#specs[@]}

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
        printf '{"specs":%s,"current":null,"total":%d,"showing":%d}\n' "$json_specs" "$total_count" "$showing_count"
    else
        printf '{"specs":%s,"current":"%s","total":%d,"showing":%d}\n' "$json_specs" "$CURRENT" "$total_count" "$showing_count"
    fi
else
    if [[ $total_count -eq 0 ]]; then
        echo "No specs found in $SPECS_DIR"
        echo "Run /speckit.specify to create a new spec."
    else
        if [[ $start_index -gt 0 ]]; then
            hidden=$((total_count - showing_count))
            echo "Available specs (showing last $showing_count of $total_count, use --all to see all):"
            echo "  ... $hidden older specs hidden ..."
        else
            echo "Available specs:"
        fi

        for i in "${!specs[@]}"; do
            spec="${specs[$i]}"
            # Calculate actual index in full list for numbering
            actual_index=$((start_index + i + 1))
            if [[ "$spec" == "$CURRENT" ]]; then
                echo "  $actual_index. $spec  [current]"
            else
                echo "  $actual_index. $spec"
            fi
        done

        if [[ -z "$CURRENT" ]]; then
            echo ""
            echo "No current spec set. Run /speckit.switch to select one."
        fi
    fi
fi
