# Tasks: Ideas Checklist Format and Command

**Feature**: 260205-k8ui-ideas-checklist-command
**Generated**: 2026-02-05
**Source**: spec.md, plan.md, research.md, quickstart.md

## Summary

| Metric | Value |
|--------|-------|
| Total Tasks | 6 |
| Story 1 (P1) Tasks | 2 |
| Story 2 (P2) Tasks | 1 |
| Verification Tasks | 3 |
| Parallel Opportunities | 1 (T002 + T003) |

---

## Phase 1: Setup

No setup required - using existing infrastructure (`.specify/bin/`, `.claude/commands/changes/`).

---

## Phase 2: Data Migration (P1 - User Story 1)

- [x] [T001] [P1] [S1] Migrate existing ideas.md entries to checkbox format
      Files: .specify/ideas.md
      Details: Convert 9 existing entries from `- YYYY-MM-DD:` to `- [ ] YYYY-MM-DD:` format
      Acceptance: All entries match pattern `- [ ] YYYY-MM-DD: text`

---

## Phase 3: Script Update (P1 - User Story 1)

- [x] [T002] [P1] [S1] Update ideas script to output checkbox format
      Files: .specify/bin/ideas
      Details: Change echo from `- $(date +%Y-%m-%d):` to `- [ ] $(date +%Y-%m-%d):`
      Acceptance: New ideas added via script include unchecked checkbox

---

## Phase 4: Skill Command (P2 - User Story 2)

- [x] [T003] [P2] [S2] [P] Create /changes:idea skill file
      Files: .claude/commands/changes/idea.md
      Details: Create skill that invokes `.specify/bin/ideas` with user-provided argument
      Acceptance: `/changes:idea <text>` adds properly formatted entry to ideas.md

---

## Phase 5: Verification

- [x] [T004] [P1] [S1] Verify migrated format matches specification
      Files: .specify/ideas.md
      Details: Confirm all 9 entries show `- [ ] YYYY-MM-DD:` pattern (Scenario 1 from quickstart.md)
      Acceptance: Visual inspection confirms format, count matches 9 original entries

- [x] [T005] [P1] [S1] Test script output format and error handling
      Files: .specify/bin/ideas
      Details: Run script with and without arguments (Scenarios 3, 4 from quickstart.md)
      Acceptance: New entry has checkbox format; no-arg shows usage message with exit 1

- [x] [T006] [P2] [S2] Test skill command end-to-end
      Files: .claude/commands/changes/idea.md, .specify/ideas.md
      Details: Run `/changes:idea Test idea` and verify entry appears (Scenario 5 from quickstart.md)
      Acceptance: Entry appears in ideas.md with today's date and checkbox format

---

## Task Dependencies

```
T001 (migrate) ──┬──> T004 (verify migration)
                 │
T002 (script)  ──┼──> T005 (verify script)
                 │
T003 (skill)   ──┴──> T006 (verify skill)
```

**Parallel Opportunity**: T002 and T003 can run in parallel - the script update and skill creation are independent. Both depend on T001 being complete to test with real data.

---

## Requirements Traceability

| Requirement | Task(s) |
|-------------|---------|
| FR-001: Checkbox format | T001, T002 |
| FR-002: Include date | T001, T002 |
| FR-003: Format `- [ ] YYYY-MM-DD:` | T001, T002 |
| FR-004: Migrate existing | T001 |
| FR-005: Skill invokes script | T003 |
| FR-006: Script outputs checklist | T002 |
| FR-007: Skill accepts argument | T003 |

| Success Criteria | Task(s) |
|------------------|---------|
| SC-001: 9 ideas migrated | T001, T004 |
| SC-002: Command adds entry <2s | T005 |
| SC-003: Toggle works | T004 (manual verify) |
| SC-004: Readable in viewers | T004 (manual verify) |
