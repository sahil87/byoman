#!/usr/bin/env bash
#
# create-new-feature.sh - Create a new spec directory with date-based naming
#
# Naming scheme: {YYMMDD}-{4-char-random}-{slug}
#   - YYMMDD: Date of creation (local timezone)
#   - 4-char-random: Alphanumeric string for uniqueness
#   - slug: Cleaned description (lowercase, hyphen-separated)
#
# Example: 260131-a7k2-user-authentication

set -e

# Source common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Generate 4-character random alphanumeric string
# Uses /dev/urandom for cross-platform compatibility (macOS, Linux, BSD)
generate_random_string() {
    head -c 100 /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 4
}

# Generate date prefix in YYMMDD format
# Uses local timezone to match user expectations
generate_date_prefix() {
    date +%y%m%d
}

# Generate unique prefix with collision detection
# Format: {YYMMDD}-{4-char-random}
# Retries up to 3 times if collision detected (extremely unlikely)
generate_unique_prefix() {
    local specs_dir="$1"
    local slug="$2"
    local max_attempts=3
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        local date_prefix=$(generate_date_prefix)
        local random_str=$(generate_random_string)
        local prefix="${date_prefix}-${random_str}"

        # Check for collision with existing spec using same prefix
        if ! ls "$specs_dir"/"${prefix}"-* >/dev/null 2>&1; then
            echo "$prefix"
            return 0
        fi
        attempt=$((attempt + 1))
    done

    echo "ERROR: Failed to generate unique prefix after $max_attempts attempts" >&2
    return 1
}

JSON_MODE=false
SHORT_NAME=""
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
            echo "ERROR: --number flag removed. Specs now use date-based naming (YYMMDD-XXXX-slug)." >&2
            exit 1
            ;;
        --help|-h)
            echo "Usage: $0 [--json] [--short-name <name>] <feature_description>"
            echo ""
            echo "Options:"
            echo "  --json              Output in JSON format"
            echo "  --short-name <name> Provide a custom short name (2-4 words) for the spec"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Spec names use format: {YYMMDD}-{4-char-random}-{slug}"
            echo ""
            echo "Examples:"
            echo "  $0 'Add user authentication system'"
            echo "  $0 'Implement OAuth2 integration' --short-name 'oauth-login'"
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
    echo "Usage: $0 [--json] [--short-name <name>] <feature_description>" >&2
    exit 1
fi

# clean_spec_name() is now in common.sh

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

# Generate spec slug from description or short name
if [ -n "$SHORT_NAME" ]; then
    SPEC_SUFFIX=$(clean_spec_name "$SHORT_NAME")
else
    SPEC_SUFFIX=$(generate_spec_name "$FEATURE_DESCRIPTION")
fi

# Generate unique date-based prefix (YYMMDD-XXXX format)
SPEC_PREFIX=$(generate_unique_prefix "$SPECS_DIR" "$SPEC_SUFFIX")
if [ $? -ne 0 ]; then
    exit 1
fi

# Construct full spec name: {YYMMDD}-{4-char-random}-{slug}
SPEC_NAME="${SPEC_PREFIX}-${SPEC_SUFFIX}"

# Truncate if too long (keep reasonable length for directory names)
# Prefix is 12 chars (YYMMDD-XXXX-), so preserve that
MAX_LENGTH=100
PREFIX_LENGTH=12
if [ ${#SPEC_NAME} -gt $MAX_LENGTH ]; then
    MAX_SUFFIX_LENGTH=$((MAX_LENGTH - PREFIX_LENGTH))
    TRUNCATED_SUFFIX=$(echo "$SPEC_SUFFIX" | cut -c1-$MAX_SUFFIX_LENGTH | sed 's/-$//')

    ORIGINAL_SPEC_NAME="$SPEC_NAME"
    SPEC_NAME="${SPEC_PREFIX}-${TRUNCATED_SUFFIX}"

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
    printf '{"SPEC_NAME":"%s","SPEC_FILE":"%s"}\n' "$SPEC_NAME" "$SPEC_FILE"
else
    echo "SPEC_NAME: $SPEC_NAME"
    echo "SPEC_FILE: $SPEC_FILE"
    echo "Current spec set to: $SPEC_NAME"
fi
