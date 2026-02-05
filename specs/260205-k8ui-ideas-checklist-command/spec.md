# Feature Specification: Ideas Checklist Format and Command

**Feature Branch**: `260205-k8ui-ideas-checklist-command`
**Created**: 2026-02-05
**Status**: Draft
**Input**: User description: "Convert ideas (.specify/ideas.md) to a checklist format (keep the date also) - so we can keep marking things as done. Also add the command changes:idea that calls .specify/bin/ideas"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Mark Ideas as Done (Priority: P1)

A developer has captured several ideas over time in the ideas file. Now they've implemented one of the ideas and want to mark it as complete without losing track of when it was originally captured.

**Why this priority**: The primary goal is enabling progress tracking. Without checkboxes, users can't indicate completion status.

**Independent Test**: Can be fully tested by manually editing the ideas file to toggle checkbox states and verifying the format remains consistent.

**Acceptance Scenarios**:

1. **Given** an ideas file with existing entries, **When** user opens the file in any markdown editor, **Then** each idea displays as a checkbox item with its original date preserved
2. **Given** an uncompleted idea entry, **When** user marks the checkbox as complete, **Then** the entry shows as checked (e.g., `[x]`) while retaining the date
3. **Given** a completed idea entry, **When** user views the file, **Then** they can clearly distinguish completed from pending ideas

---

### User Story 2 - Capture New Ideas via Command (Priority: P2)

A developer is working in Claude Code and wants to quickly jot down a feature idea without leaving their current context. They use the `/changes:idea` command to add it to the ideas list.

**Why this priority**: Quick idea capture is valuable, but the primary change is the format conversion. The command already exists as a script.

**Independent Test**: Can be fully tested by running `/changes:idea my new feature` and verifying the idea appears in the correct checklist format with today's date.

**Acceptance Scenarios**:

1. **Given** the developer is in Claude Code, **When** they run `/changes:idea Implement dark mode`, **Then** a new unchecked item appears in `.specify/ideas.md` with today's date
2. **Given** the ideas file has existing entries, **When** a new idea is added via the command, **Then** the new entry uses the same checklist format as existing entries
3. **Given** the developer provides no idea text, **When** they run `/changes:idea` without arguments, **Then** they receive a usage message indicating required input

---

### Edge Cases

- What happens when the ideas file doesn't exist? The script creates it with the new entry.
- What happens when an idea contains special markdown characters? They are preserved as-is.
- What happens with multi-word ideas with quotes? The entire quoted string is captured as one idea.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The ideas file MUST use markdown checkbox format (`- [ ]` for pending, `- [x]` for completed)
- **FR-002**: Each idea entry MUST include the capture date in `YYYY-MM-DD` format
- **FR-003**: The date MUST appear after the checkbox, formatted as `- [ ] YYYY-MM-DD: idea text`
- **FR-004**: Existing ideas MUST be migrated to the new checklist format with dates preserved
- **FR-005**: The `changes:idea` skill MUST invoke the existing `.specify/bin/ideas` script
- **FR-006**: The script MUST be updated to output ideas in the new checklist format
- **FR-007**: The skill MUST accept idea text as an argument

### Key Entities

- **Idea Entry**: A single captured idea with three attributes: completion status (boolean), capture date, and description text
- **Ideas File**: The `.specify/ideas.md` file containing all idea entries in a flat list

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 9 existing ideas in the file are converted to checklist format with original dates intact
- **SC-002**: Running `/changes:idea test idea` adds a properly formatted checklist entry within 2 seconds
- **SC-003**: Users can toggle completion status by editing `[ ]` to `[x]` without breaking the format
- **SC-004**: The new format is readable in any markdown viewer (GitHub, VS Code, etc.)

## Assumptions

- The existing `.specify/bin/ideas` script will continue to be the implementation (just updated for new format)
- The ideas file is manually edited to mark items complete (no UI needed)
- Date format `YYYY-MM-DD` is already used and will be preserved
