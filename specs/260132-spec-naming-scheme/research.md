# Research: Spec Naming Scheme Update

**Date**: 2026-01-31
**Spec**: 260132-spec-naming-scheme

## Research Topics

### 1. Cross-Platform Random String Generation

**Context**: Need to generate 4-character alphanumeric strings that work on both macOS and Linux.

**Decision**: Use `/dev/urandom` with `tr` and `head`

**Rationale**:
- `/dev/urandom` is available on all POSIX systems (macOS, Linux, BSD)
- Provides cryptographically random bytes
- 4 lowercase alphanumeric characters = 36^4 = 1,679,616 unique combinations
- Simple, single-line implementation

**Implementation**:
```bash
generate_random_string() {
    head -c 100 /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 4
}
```

**Alternatives Considered**:
| Method | Pros | Cons | Decision |
|--------|------|------|----------|
| `/dev/urandom` + `tr` | Cross-platform, good entropy | Requires LC_ALL=C for reliability | ✅ Selected |
| `$RANDOM` | Built-in, simple | Only 32767 values, predictable | Rejected |
| `openssl rand` | High quality | Not always installed | Rejected |
| `uuidgen` | Unique | Overkill, long output | Rejected |

---

### 2. Date Formatting (YYMMDD)

**Context**: Need to generate date prefix in YYMMDD format.

**Decision**: Use `date +%y%m%d`

**Rationale**:
- Standard POSIX `date` command
- `%y` = 2-digit year, `%m` = 2-digit month, `%d` = 2-digit day
- Works identically on macOS and Linux
- Uses local timezone (matches user expectations)

**Implementation**:
```bash
DATE_PREFIX=$(date +%y%m%d)  # e.g., "260131"
```

**Alternatives Considered**:
- Full year (YYYYMMDD): Rejected - too long, 2-digit year sufficient for spec context
- ISO format (YYYY-MM-DD): Rejected - hyphens conflict with slug separators

---

### 3. Collision Handling Strategy

**Context**: What happens if two specs are created with the same random string on the same day?

**Decision**: Regenerate random string if collision detected

**Rationale**:
- Collision probability is extremely low: 1/1,679,616 per attempt
- Simple implementation: check if directory exists, regenerate if needed
- Maximum 3 retries before failing (prevents infinite loops)

**Implementation**:
```bash
generate_unique_prefix() {
    local max_attempts=3
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        local date_prefix=$(date +%y%m%d)
        local random_str=$(head -c 100 /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 4)
        local prefix="${date_prefix}-${random_str}"

        # Check for collision
        if ! ls "$SPECS_DIR"/"${prefix}"-* >/dev/null 2>&1; then
            echo "$prefix"
            return 0
        fi
        attempt=$((attempt + 1))
    done

    echo "ERROR: Failed to generate unique prefix after $max_attempts attempts" >&2
    return 1
}
```

---

### 4. Backward Compatibility

**Context**: Existing specs use `NNN-slug` format. Will they still work?

**Decision**: No migration needed - both formats coexist

**Rationale**:
- `list-specs.sh` lists all directories in `specs/` regardless of name format
- `set-current.sh` accepts any spec name string
- `setup-plan.sh` uses the spec name from `.specify/current` file
- Sorting: Old specs (001-xxx) sort before new specs (260131-xxx) alphabetically

**Verification**: All existing scripts are name-format agnostic.

---

### 5. Deprecating `--number` Flag

**Context**: FR-006 requires removing/deprecating the `--number` flag.

**Decision**: Remove the flag entirely with clear error message

**Rationale**:
- Sequential numbering is no longer meaningful with date-based naming
- Keeping the flag with a deprecation warning adds complexity
- Clean removal is simpler and avoids confusion

**Implementation**:
```bash
--number)
    echo "ERROR: --number flag removed. Specs now use date-based naming (YYMMDD-XXXX-slug)." >&2
    exit 1
    ;;
```

---

## Summary of Decisions

| Topic | Decision |
|-------|----------|
| Random generation | `/dev/urandom` + `tr -dc 'a-z0-9'` |
| Date format | `date +%y%m%d` (YYMMDD) |
| Collision handling | Regenerate up to 3 times, then fail |
| Backward compatibility | No migration - formats coexist |
| `--number` flag | Remove with clear error message |
