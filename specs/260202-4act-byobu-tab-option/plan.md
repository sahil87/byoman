# Implementation Plan: Byobu Tab Option for wt-create

**Branch**: `260202-4act-byobu-tab-option` | **Date**: 2026-02-02 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/260202-4act-byobu-tab-option/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Add a byobu-specific post-create option to `wt-create` that opens a new byobu tab (focused) to the newly created worktree and names it using the repo name plus worktree name, while preserving existing behavior outside byobu sessions.

## Technical Context

**Language/Version**: POSIX-compliant shell script (bash 3.2+ compatible)  
**Primary Dependencies**: git, byobu (optional), tmux (byobu backend), standard POSIX utilities  
**Storage**: N/A (git manages worktree metadata)  
**Testing**: Manual CLI testing + shellcheck linting  
**Target Platform**: macOS, Linux  
**Project Type**: single (standalone script in `.specify/bin/`)  
**Performance Goals**: <100ms startup, no extra I/O beyond existing worktree operations  
**Constraints**: Terminal-first output; preserve byobu session integrity; graceful degradation when byobu not installed  
**Scale/Scope**: Single script change; new menu option and byobu open behavior only

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Terminal-First Design | ✅ PASS | Interactive menu remains 80-col friendly, POSIX exit codes preserved, NO_COLOR respected, no JSON requirement introduced |
| II. Byobu Session Integrity | ✅ PASS | Adds a new tab only, no destructive session actions, failure leaves worktree intact |
| III. Code Quality Standards | ✅ PASS | Changes scoped to single script, error messages remain what/why/fix, no silent failures |
| IV. Performance Requirements | ✅ PASS | Minimal additional work, no extra I/O beyond byobu command |
| V. Graceful Degradation | ✅ PASS | Option only shown in byobu sessions; missing byobu yields clear error and no side effects |

**Gate Result**: PASS - No violations requiring justification

## Project Structure

### Documentation (this feature)

```text
specs/260202-4act-byobu-tab-option/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
.specify/bin/
└── wt-create            # Standalone POSIX shell script for worktree creation
```

**Structure Decision**: Single script change in `.specify/bin/wt-create`. No new packages or tests required beyond manual verification and shellcheck.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations - table not required.*
