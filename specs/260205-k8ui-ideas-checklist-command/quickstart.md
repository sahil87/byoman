# Quickstart: Ideas Checklist Testing

**Feature**: 260205-k8ui-ideas-checklist-command
**Date**: 2026-02-05

## Prerequisites

- Git repository with `.specify/` directory
- Claude Code CLI (for skill testing)

## Test Scenarios

### Scenario 1: Verify Migrated Format

**Goal**: Confirm existing ideas are in checklist format.

**Steps**:
1. Open `.specify/ideas.md`
2. Verify each line matches pattern: `- [ ] YYYY-MM-DD: text`

**Expected**: All 9 existing entries show unchecked checkboxes with dates.

```markdown
- [ ] 2026-02-02: In wt-create also give option to open the worktree...
- [ ] 2026-02-02: Make the tui more slick...
...
```

### Scenario 2: Toggle Checkbox Manually

**Goal**: Confirm manual status toggling works.

**Steps**:
1. Open `.specify/ideas.md` in editor
2. Find any entry with `[ ]`
3. Change to `[x]`
4. Save file
5. Open in GitHub or markdown preview

**Expected**: Item displays as checked/completed.

### Scenario 3: Add Idea via Script

**Goal**: Confirm script outputs correct format.

**Steps**:
```bash
cd <repo-root>
.specify/bin/ideas "Test idea from script"
tail -1 .specify/ideas.md
```

**Expected Output**:
```
- [ ] 2026-02-05: Test idea from script
```

### Scenario 4: Script Error Handling

**Goal**: Confirm usage message on missing argument.

**Steps**:
```bash
.specify/bin/ideas
```

**Expected Output**:
```
Usage: ideas <your idea>
```

**Expected Exit Code**: 1

### Scenario 5: Add Idea via Skill Command

**Goal**: Confirm `/changes:idea` skill works.

**Steps**:
1. Open Claude Code in repository
2. Run: `/changes:idea Test idea from skill command`

**Expected**:
- Claude executes `.specify/bin/ideas "Test idea from skill command"`
- New entry appears in `.specify/ideas.md` with today's date and checkbox

### Scenario 6: Markdown Rendering

**Goal**: Confirm checkboxes render correctly.

**Steps**:
1. Push changes to GitHub (or open in VS Code)
2. View `.specify/ideas.md` in preview mode

**Expected**:
- Unchecked items show empty checkbox
- Checked items show filled checkbox
- GitHub allows clicking to toggle (creates commit)

## Cleanup

After testing, remove test entries:
```bash
# Remove lines containing "Test idea from"
sed -i '' '/Test idea from/d' .specify/ideas.md
```

## Success Criteria Verification

| Criteria | How to Verify | Pass |
|----------|---------------|------|
| SC-001: 9 ideas migrated | Count lines in ideas.md, verify format | [ ] |
| SC-002: Command adds entry <2s | Time the script execution | [ ] |
| SC-003: Toggle works | Edit [ ] to [x] and back | [ ] |
| SC-004: Readable in viewers | Check GitHub/VS Code preview | [ ] |
