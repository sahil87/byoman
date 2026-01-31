#!/usr/bin/env bash

set -e

# Source common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
SHORT_NAME=""
SPEC_NUMBER=""
ARGS=()
i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --short-name)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --short-name requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --short-name requires a value' >&2
                exit 1
            fi
            SHORT_NAME="$next_arg"
            ;;
        --number)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --number requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --number requires a value' >&2
                exit 1
            fi
            SPEC_NUMBER="$next_arg"
            ;;
        --help|-h)
            echo "Usage: $0 [--json] [--short-name <name>] [--number N] <feature_description>"
            echo ""
            echo "Options:"
            echo "  --json              Output in JSON format"
            echo "  --short-name <name> Provide a custom short name (2-4 words) for the spec"
            echo "  --number N          Specify spec number manually (overrides auto-detection)"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 'Add user authentication system' --short-name 'user-auth'"
            echo "  $0 'Implement OAuth2 integration for API' --number 5"
            exit 0
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
    i=$((i + 1))
done

FEATURE_DESCRIPTION="${ARGS[*]}"
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Usage: $0 [--json] [--short-name <name>] [--number N] <feature_description>" >&2
    exit 1
fi

# Get highest number from specs directory only
get_highest_from_specs() {
    local specs_dir="$1"
    local highest=0

    if [ -d "$specs_dir" ]; then
        for dir in "$specs_dir"/*; do
            [ -d "$dir" ] || continue
            dirname=$(basename "$dir")
            number=$(echo "$dirname" | grep -o '^[0-9]\+' || echo "0")
            number=$((10#$number))
            if [ "$number" -gt "$highest" ]; then
                highest=$number
            fi
        done
    fi

    echo "$highest"
}

# Function to clean and format a spec name
clean_spec_name() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

# Function to generate spec name with stop word filtering
generate_spec_name() {
    local description="$1"

    # Common stop words to filter out
    local stop_words="^(i|a|an|the|to|for|of|in|on|at|by|with|from|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|should|could|can|may|might|must|shall|this|that|these|those|my|your|our|their|want|need|add|get|set)$"

    # Convert to lowercase and split into words
    local clean_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g')

    # Filter words: remove stop words and words shorter than 3 chars
    local meaningful_words=()
    for word in $clean_name; do
        [ -z "$word" ] && continue

        if ! echo "$word" | grep -qiE "$stop_words"; then
            if [ ${#word} -ge 3 ]; then
                meaningful_words+=("$word")
            elif echo "$description" | grep -q "\b${word^^}\b"; then
                meaningful_words+=("$word")
            fi
        fi
    done

    # Use first 3-4 meaningful words
    if [ ${#meaningful_words[@]} -gt 0 ]; then
        local max_words=3
        if [ ${#meaningful_words[@]} -eq 4 ]; then max_words=4; fi

        local result=""
        local count=0
        for word in "${meaningful_words[@]}"; do
            if [ $count -ge $max_words ]; then break; fi
            if [ -n "$result" ]; then result="$result-"; fi
            result="$result$word"
            count=$((count + 1))
        done
        echo "$result"
    else
        local cleaned=$(clean_spec_name "$description")
        echo "$cleaned" | tr '-' '\n' | grep -v '^$' | head -3 | tr '\n' '-' | sed 's/-$//'
    fi
}

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

SPECS_DIR="$REPO_ROOT/specs"
mkdir -p "$SPECS_DIR"

# Generate spec name
if [ -n "$SHORT_NAME" ]; then
    SPEC_SUFFIX=$(clean_spec_name "$SHORT_NAME")
else
    SPEC_SUFFIX=$(generate_spec_name "$FEATURE_DESCRIPTION")
fi

# Determine spec number from specs/ directory only
if [ -z "$SPEC_NUMBER" ]; then
    HIGHEST=$(get_highest_from_specs "$SPECS_DIR")
    SPEC_NUMBER=$((HIGHEST + 1))
fi

# Format spec number with leading zeros
FEATURE_NUM=$(printf "%03d" "$((10#$SPEC_NUMBER))")
SPEC_NAME="${FEATURE_NUM}-${SPEC_SUFFIX}"

# Truncate if too long (keep reasonable length for directory names)
MAX_LENGTH=100
if [ ${#SPEC_NAME} -gt $MAX_LENGTH ]; then
    MAX_SUFFIX_LENGTH=$((MAX_LENGTH - 4))
    TRUNCATED_SUFFIX=$(echo "$SPEC_SUFFIX" | cut -c1-$MAX_SUFFIX_LENGTH | sed 's/-$//')

    ORIGINAL_SPEC_NAME="$SPEC_NAME"
    SPEC_NAME="${FEATURE_NUM}-${TRUNCATED_SUFFIX}"

    >&2 echo "[specify] Warning: Spec name exceeded $MAX_LENGTH chars"
    >&2 echo "[specify] Original: $ORIGINAL_SPEC_NAME (${#ORIGINAL_SPEC_NAME} chars)"
    >&2 echo "[specify] Truncated to: $SPEC_NAME (${#SPEC_NAME} chars)"
fi

# Create spec directory and files
FEATURE_DIR="$SPECS_DIR/$SPEC_NAME"
mkdir -p "$FEATURE_DIR"

TEMPLATE="$REPO_ROOT/.specify/templates/spec-template.md"
SPEC_FILE="$FEATURE_DIR/spec.md"
if [ -f "$TEMPLATE" ]; then cp "$TEMPLATE" "$SPEC_FILE"; else touch "$SPEC_FILE"; fi

# Set as current spec
set_current_spec "$SPEC_NAME"

if $JSON_MODE; then
    printf '{"SPEC_NAME":"%s","SPEC_FILE":"%s","FEATURE_NUM":"%s"}\n' "$SPEC_NAME" "$SPEC_FILE" "$FEATURE_NUM"
else
    echo "SPEC_NAME: $SPEC_NAME"
    echo "SPEC_FILE: $SPEC_FILE"
    echo "FEATURE_NUM: $FEATURE_NUM"
    echo "Current spec set to: $SPEC_NAME"
fi
