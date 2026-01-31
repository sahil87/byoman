# Feature Specification: Spec Naming Scheme Update

**Feature Branch**: `260132-spec-naming-scheme`
**Created**: 2026-01-31
**Status**: Draft
**Input**: User description: "Update speckit scripts to use naming scheme {YYMMDD}-{4-char-random}-{slug} in specs"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create New Spec with Date-Based Naming (Priority: P1)

A developer runs `/speckit.specify` to create a new feature specification. The system generates a spec directory using the format `{YYMMDD}-{4-char-random}-{slug}` (e.g., `260131-a7k2-user-auth`), where the date reflects when the spec was created and the random string ensures uniqueness even for specs created on the same day.

**Why this priority**: This is the core functionality - every new spec must use the new naming scheme. Without this, the feature delivers no value.

**Independent Test**: Can be tested by running `create-new-feature.sh` and verifying the output directory name matches the expected pattern.

**Acceptance Scenarios**:

1. **Given** no existing specs, **When** a developer runs `/speckit.specify "Add user authentication"`, **Then** a spec directory is created with format `{YYMMDD}-{4-char-random}-user-auth` where YYMMDD is today's date
2. **Given** an existing spec created today, **When** a developer creates another spec, **Then** the new spec has a different 4-char random string ensuring uniqueness
3. **Given** the system clock shows 2026-01-31, **When** a developer creates a spec with short-name "oauth", **Then** the directory is named `260131-{4-char-random}-oauth`

---

### User Story 2 - Short Name Processing Preserved (Priority: P2)

A developer provides a custom short name via `--short-name` flag. The system preserves existing slug generation behavior: cleaning special characters, converting to lowercase, and using hyphen separators, while prepending the new date-random prefix.

**Why this priority**: Developers rely on meaningful slugs to identify specs. Breaking slug generation would harm usability.

**Independent Test**: Can be tested by running `create-new-feature.sh --short-name "My OAuth Feature"` and verifying the slug portion is cleaned to `my-oauth-feature`.

**Acceptance Scenarios**:

1. **Given** a short name with spaces "user auth flow", **When** the spec is created, **Then** the slug portion is `user-auth-flow`
2. **Given** a short name with uppercase and special chars "OAuth2_Integration!", **When** the spec is created, **Then** the slug portion is `oauth2-integration`

---

### Edge Cases

- What happens when two specs are created in the same second? The 4-character random string provides uniqueness.
- What happens if the random string collides with an existing spec? The system should regenerate the random string (collision is extremely unlikely with 4 alphanumeric characters = 1.6M combinations).
- What happens with very long short names? Existing truncation behavior should be preserved, applied to the full spec name including the date-random prefix.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST generate spec directory names in format `{YYMMDD}-{4-char-random}-{slug}`
- **FR-002**: The YYMMDD component MUST reflect the current date when the spec is created (2-digit year, 2-digit month, 2-digit day)
- **FR-003**: The 4-char random component MUST be alphanumeric (lowercase letters and digits only) for filesystem compatibility
- **FR-004**: System MUST preserve existing slug generation logic (lowercase, hyphen-separated, special chars removed)
- **FR-005**: System MUST handle name truncation if total length exceeds filesystem limits, preserving the date-random prefix
- **FR-006**: The `--number` flag MUST be removed or deprecated since sequential numbering no longer applies
- **FR-007**: The JSON output MUST reflect the new naming format in SPEC_NAME field

### Key Entities

- **Spec Name**: The full directory name following pattern `{YYMMDD}-{4-char-random}-{slug}`
- **Date Prefix**: 6-character date in YYMMDD format (e.g., "260131" for Jan 31, 2026)
- **Random String**: 4-character alphanumeric string for uniqueness (e.g., "a7k2")
- **Slug**: Cleaned, hyphen-separated descriptive name (e.g., "user-auth")

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of newly created specs use the `{YYMMDD}-{4-char-random}-{slug}` naming format
- **SC-002**: Developers can identify spec creation date at a glance from the directory name
- **SC-003**: No naming collisions occur when multiple specs are created on the same day
- **SC-004**: Existing spec listing and switching functionality (`/speckit.switch`, `list-specs.sh`) continues to work with new names

## Assumptions

- The 4-character alphanumeric random string provides sufficient uniqueness (1,679,616 combinations)
- Existing specs with the old naming format (e.g., `001-byobu-session-manager`) will remain functional - no migration required
- The date uses the local system timezone for consistency with developer expectations
- Lowercase alphanumeric characters are sufficient for the random string (no need for special characters)
