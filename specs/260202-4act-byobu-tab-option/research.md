# Research: Byobu Tab Option for wt-create

**Feature**: 260202-4act-byobu-tab-option
**Date**: 2026-02-02

## Decision 1: Byobu Session Detection

**Decision**: Detect active byobu sessions using standard byobu/tmux environment cues already available to `wt-create` runtime.

**Rationale**: This avoids additional dependencies and keeps detection consistent with existing byobu usage patterns while preserving graceful degradation when byobu is not active.

**Alternatives considered**:
- Probe external byobu commands to detect sessions (adds overhead and possible failures).
- Always show option and fail if not in byobu (worse UX, violates spec requirement).

## Decision 2: Tab Focus Behavior

**Decision**: Focus the new byobu tab immediately after creation.

**Rationale**: Aligns with the primary user goal of landing in the new worktree without extra navigation.

**Alternatives considered**:
- Create the tab in the background (extra step for user).
- Defer to byobu defaults (less deterministic).

## Decision 3: Tab Naming Convention

**Decision**: Name the tab using the repo name plus the worktree name.

**Rationale**: Improves disambiguation when multiple repos are open and aligns with user mental model.

**Alternatives considered**:
- Use worktree name only (can collide across repos).
- Use branch name (less clear when worktree name differs).
- Use byobu default naming (no explicit control).
