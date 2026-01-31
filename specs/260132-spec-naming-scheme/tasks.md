# Tasks: Spec Naming Scheme Update

**Input**: Design documents from `/specs/260132-spec-naming-scheme/`
**Prerequisites**: plan.md (required), spec.md (required), research.md

**Tests**: Not explicitly requested in spec - omitted.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Prepare for script modification

- [x] T001 Create backup of .specify/scripts/bash/create-new-feature.sh
- [x] T002 Review research.md decisions for implementation approach

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core helper functions that MUST be complete before user story implementation

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Add `generate_random_string()` function in .specify/scripts/bash/create-new-feature.sh using `/dev/urandom` approach from research.md
- [x] T004 Add `generate_date_prefix()` function in .specify/scripts/bash/create-new-feature.sh using `date +%y%m%d`
- [x] T005 Add `generate_unique_prefix()` function in .specify/scripts/bash/create-new-feature.sh with collision detection (max 3 retries)

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Create New Spec with Date-Based Naming (Priority: P1) 🎯 MVP

**Goal**: Generate spec directories with format `{YYMMDD}-{4-char-random}-{slug}` instead of sequential numbering

**Independent Test**: Run `create-new-feature.sh "test feature"` and verify output directory matches pattern `YYMMDD-XXXX-test-feature`

### Implementation for User Story 1

- [x] T006 [US1] Remove `get_highest_from_specs()` function from .specify/scripts/bash/create-new-feature.sh (no longer needed)
- [x] T007 [US1] Remove `--number` flag handling and add error message for deprecated usage in .specify/scripts/bash/create-new-feature.sh (FR-006)
- [x] T008 [US1] Update help text to remove `--number` option in .specify/scripts/bash/create-new-feature.sh
- [x] T009 [US1] Replace `FEATURE_NUM` generation with `generate_unique_prefix()` call in .specify/scripts/bash/create-new-feature.sh
- [x] T010 [US1] Update `SPEC_NAME` construction to use new prefix format in .specify/scripts/bash/create-new-feature.sh
- [x] T011 [US1] Update JSON output to remove FEATURE_NUM field in .specify/scripts/bash/create-new-feature.sh (FR-007)
- [x] T012 [US1] Update human-readable output to remove FEATURE_NUM line in .specify/scripts/bash/create-new-feature.sh

**Checkpoint**: User Story 1 complete - basic date-based naming works

---

## Phase 4: User Story 2 - Short Name Processing Preserved (Priority: P2)

**Goal**: Preserve existing slug generation behavior when using `--short-name` flag

**Independent Test**: Run `create-new-feature.sh "test" --short-name "My OAuth Feature"` and verify slug portion is `my-oauth-feature`

### Implementation for User Story 2

- [x] T013 [US2] Verify `clean_spec_name()` function is unchanged in .specify/scripts/bash/create-new-feature.sh
- [x] T014 [US2] Verify `generate_spec_name()` function is unchanged in .specify/scripts/bash/create-new-feature.sh
- [x] T015 [US2] Update truncation logic to preserve date-random prefix when truncating in .specify/scripts/bash/create-new-feature.sh (FR-005)
- [x] T016 [US2] Test `--short-name` with special characters to verify slug cleaning works

**Checkpoint**: User Story 2 complete - short name processing works with new format

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Edge cases and final validation

- [x] T017 Add inline comments documenting new naming scheme in .specify/scripts/bash/create-new-feature.sh
- [x] T018 Manually test collision scenario by creating two specs with same slug on same day
- [x] T019 Verify existing specs (001-xxx format) still work with list-specs.sh and set-current.sh
- [x] T020 Run quickstart.md validation scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion
- **User Story 2 (Phase 4)**: Depends on Foundational phase completion (can run parallel with US1)
- **Polish (Phase 5)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Independent - core naming change
- **User Story 2 (P2)**: Independent of US1 - tests existing behavior with new prefix

### Within Each User Story

- Remove old code before adding new
- Update logic before updating output
- Test after each logical change

### Parallel Opportunities

- T003, T004 can run in parallel (different functions)
- T007, T008 can run in parallel (flag removal + help text)
- T011, T012 can run in parallel (JSON output + human output)
- US1 and US2 can be worked on in parallel after Phase 2

---

## Parallel Example: Foundational Phase

```bash
# Launch helper function creation in parallel:
Task: "Add generate_random_string() function"
Task: "Add generate_date_prefix() function"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (backup)
2. Complete Phase 2: Foundational (helper functions)
3. Complete Phase 3: User Story 1 (date-based naming)
4. **STOP and VALIDATE**: Test basic spec creation
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Helper functions ready
2. Add User Story 1 → Test independently → Basic naming works (MVP!)
3. Add User Story 2 → Test independently → Short names work
4. Polish → Final validation complete

---

## Summary

| Metric | Value |
|--------|-------|
| Total Tasks | 20 |
| Phase 1 (Setup) | 2 tasks |
| Phase 2 (Foundational) | 3 tasks |
| Phase 3 (US1) | 7 tasks |
| Phase 4 (US2) | 4 tasks |
| Phase 5 (Polish) | 4 tasks |
| Parallel Opportunities | 4 groups |
| Files Modified | 1 (.specify/scripts/bash/create-new-feature.sh) |

---

## Notes

- All changes are in a single file: `.specify/scripts/bash/create-new-feature.sh`
- Existing scripts (list-specs.sh, set-current.sh) need no changes
- Old and new spec name formats will coexist
- No migration required for existing specs
