---
description: Switch to a different spec or show current spec context
---

## User Input

```text
$ARGUMENTS
```

## Outline

1. **List specs**: Run `.specify/scripts/bash/list-specs.sh --json` from repo root to get:
   - All available specs in `specs/` directory
   - Current spec from `.specify/current` (if set)

2. **If ARGUMENTS contains a spec name or number**:
   - Run `.specify/scripts/bash/set-current.sh --json <spec>` to set it as current
   - Confirm: "Switched to: NNN-feature-name"
   - Show brief summary of what's available in that spec (spec.md, plan.md, tasks.md, etc.)

3. **If no ARGUMENTS**:
   - Display numbered list of all specs
   - Show which is currently active (if any) with `[current]` marker
   - Ask user to select by number or name
   - After selection, run `.specify/scripts/bash/set-current.sh <selected-spec>`
   - Confirm switch

4. **If no specs exist**:
   - Tell user: "No specs found. Run /speckit.specify to create a new spec."

## Output Format

When listing specs:
```
Available specs:
  1. 001-user-authentication
  2. 002-payment-integration  [current]
  3. 003-dashboard-redesign

Select a spec (number or name):
```

When switching:
```
Switched to: 003-dashboard-redesign

Available artifacts:
  - spec.md
  - plan.md
  - tasks.md (12 tasks, 8 completed)
```
