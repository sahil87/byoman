## Context

BYOMAN is the **BYO**bu **MAN**ager. The codebase already uses `byobu` commands for all operations (`exec.Command("byobu", ...)`), but the package structure and documentation still reference "tmux" heavily:

- Package `internal/tmux/` should be `internal/byobu/`
- Comments say "tmux session", "tmux internal ID" when they should say "byobu session"
- README mentions tmux prominently before byobu
- 437 occurrences of "tmux" across 41 files

The code correctly wraps byobu (which itself wraps tmux), but the naming doesn't reflect this.

## Goals / Non-Goals

**Goals:**
- Rename `internal/tmux/` package to `internal/byobu/`
- Update all imports from `internal/tmux` to `internal/byobu`
- Update comments in Go source to use "byobu" terminology
- Update README to lead with byobu, mention tmux only as underlying tech
- Update spec documentation for consistency

**Non-Goals:**
- Changing any functionality or behavior
- Modifying the actual commands executed (already using `byobu`)
- Updating archived specs (leave historical context intact)
- Changing external API or CLI interface

## Decisions

### 1. Package rename: `internal/tmux/` → `internal/byobu/`

**Rationale**: The package name should match what it abstracts. Since all commands use `byobu`, the package should be named `byobu`.

**Alternatives considered**:
- Keep `tmux` package name: Rejected - creates confusion about tool identity
- Name it `sessions/`: Rejected - too generic, doesn't convey the byobu wrapper purpose

### 2. Preserve "tmux" in technical explanations only

**Rationale**: tmux is the underlying technology. References like "byobu runs on tmux" or "tmux internal ID (e.g., `$0`)" are accurate technical descriptions.

**Rule**: Use "byobu" for user-facing concepts (sessions, commands, the tool). Use "tmux" only when explaining the underlying implementation detail.

### 3. Update active specs only

**Rationale**: Archived specs are historical records. Changing them would misrepresent what was designed at the time.

**Scope**: Update `specs/` and `openspec/specs/`, skip `openspec/changes/archive/`.

## Risks / Trade-offs

**[Git history disruption]** → The `git mv` rename preserves history. All import changes are mechanical and easily reviewable.

**[Potential missed references]** → Use grep to find all occurrences. The count (437) provides a verification baseline - after changes, remaining "tmux" references should be only technical explanations.

**[Spec file churn]** → Many spec files will be touched. Mitigation: batch all doc changes in a single commit, separate from code changes.
