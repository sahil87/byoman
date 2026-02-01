---
description: Execute the full build pipeline (plan → tasks → implement) for unattended execution on a worktree.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

This command orchestrates the complete spec-to-implementation workflow using **subagents** for each phase to prevent context exhaustion:

1. **Plan subagent**: Generate research.md, data-model.md, contracts/, quickstart.md
2. **Tasks subagent**: Generate tasks.md from the plan artifacts
3. **Implement subagent**: Execute all tasks from tasks.md

**Intended use**: Run on a worktree without active monitoring. The spec.md should already be written and reviewed before invoking this command.

## Architecture

```
speckit.build (orchestrator - minimal context)
    │
    ├── Validate spec exists
    │
    ├── Spawn: speckit.plan subagent
    │   └── Returns: plan artifacts status
    │
    ├── Spawn: speckit.tasks subagent
    │   └── Returns: tasks.md status
    │
    └── Spawn: speckit.implement subagent
        └── Returns: implementation status
```

Each subagent runs in its own context, keeping the orchestrator lightweight.

## Outline

### Phase 0: Setup & Validation (orchestrator)

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --paths-only` to get paths.
   - If no current spec is set, **STOP** with error: "No spec selected. Run `/speckit.switch` first."
   - Parse: REPO_ROOT, SPEC, FEATURE_DIR, FEATURE_SPEC

2. Validate spec.md exists at FEATURE_SPEC:
   - If missing, **STOP** with error: "spec.md not found. Run `/speckit.specify` first."

3. Report starting state:
   ```
   🔨 SPECKIT BUILD: Starting pipeline
   Spec: [SPEC name]
   Feature: [FEATURE_DIR]
   ```

### Phase 1: Plan (subagent)

**Invoke the Skill tool** with skill `speckit.plan` and pass any relevant user arguments.

Wait for completion. Check result:
- **Success**: Report artifacts generated, continue to Phase 2
- **Failure**: Report error, **STOP** pipeline

```
✓ Plan phase complete
```

### Phase 2: Tasks (subagent)

**Invoke the Skill tool** with skill `speckit.tasks` and pass any relevant user arguments.

Wait for completion. Check result:
- **Success**: Report task count, continue to Phase 3
- **Failure**: Report error, **STOP** pipeline

```
✓ Tasks phase complete
```

### Phase 3: Implement (subagent)

**Invoke the Skill tool** with skill `speckit.implement` and pass any relevant user arguments.

**Note**: The implement phase includes checklist verification. If checklists are incomplete, the subagent will prompt for confirmation before proceeding.

Wait for completion. Check result:
- **Success**: Report implementation status
- **Partial**: Report completed tasks and failures
- **Failure**: Report error

```
✓ Implementation phase complete
```

### Final Report (orchestrator)

After all phases complete (or on error):

```
=====================================
SPECKIT BUILD: [SUCCESS/PARTIAL/FAILED]
=====================================
Spec: [SPEC name]

Phase Results:
  Plan:      [✓/✗]
  Tasks:     [✓/✗]
  Implement: [✓/✗] [completed/total tasks]

Next Steps: [if any issues]
=====================================
```

## Key Rules

- **Use subagents** - Each phase runs as a separate Skill invocation to preserve context
- **Orchestrator stays lightweight** - Only validates, spawns, and reports
- **Sequential phases** - Wait for each phase to complete before starting next
- **Checklist verification preserved** - The implement subagent handles checklist checks
- **Stop on critical failures** - If plan or tasks fail, don't attempt subsequent phases
- Use absolute paths everywhere
