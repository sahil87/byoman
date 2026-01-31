---
description: Execute the full build pipeline (plan → tasks → implement) for unattended execution on a worktree.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

This command chains the complete spec-to-implementation workflow for unattended execution:
1. **Plan**: Generate research.md, data-model.md, contracts/, quickstart.md
2. **Tasks**: Generate tasks.md from the plan artifacts
3. **Implement**: Execute all tasks from tasks.md

**Intended use**: Run on a worktree without active monitoring. The spec.md should already be written and reviewed before invoking this command.

## Outline

### Phase 0: Setup & Validation

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --paths-only` to get paths.
   - If no current spec is set, **STOP** with error: "No spec selected. Run `/speckit.switch` first."
   - Parse: REPO_ROOT, SPEC, FEATURE_DIR, FEATURE_SPEC, IMPL_PLAN, TASKS

2. Validate spec.md exists at FEATURE_SPEC:
   - If missing, **STOP** with error: "spec.md not found. Run `/speckit.specify` first."
   - Read spec.md to confirm it has content (not just template)

3. Load constitution from `.specify/memory/constitution.md`

4. Report starting state:
   ```
   🔨 SPECKIT BUILD: Starting unattended pipeline
   Spec: [SPEC name]
   Feature: [FEATURE_DIR]
   ```

### Phase 1: Plan (from speckit.plan)

1. Run `.specify/scripts/bash/setup-plan.sh --json` to initialize plan.md template

2. Read FEATURE_SPEC and plan template

3. Execute plan workflow:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section
   - **Phase 0 (Research)**: Generate research.md resolving all NEEDS CLARIFICATION
   - **Phase 1 (Design)**: Generate data-model.md, contracts/, quickstart.md
   - Run `.specify/scripts/bash/update-agent-context.sh claude`

4. **Checkpoint**: Report artifacts generated:
   ```
   ✓ Plan phase complete
   Generated: research.md, data-model.md, contracts/, quickstart.md
   ```

### Phase 2: Tasks (from speckit.tasks)

1. Run `.specify/scripts/bash/check-prerequisites.sh --json` to verify plan artifacts exist

2. Load all design documents:
   - **Required**: plan.md, spec.md
   - **Optional**: data-model.md, contracts/, research.md, quickstart.md

3. Generate tasks.md following the task template:
   - Phase 1: Setup tasks
   - Phase 2: Foundational tasks
   - Phase 3+: One phase per user story (priority ordered)
   - Final Phase: Polish & cross-cutting

4. **Checkpoint**: Report task generation:
   ```
   ✓ Tasks phase complete
   Generated: tasks.md
   Total tasks: [N]
   User stories covered: [list]
   ```

### Phase 3: Implement (from speckit.implement)

1. **Skip checklist verification** - assume user has already verified the spec before running this command

2. Load implementation context:
   - tasks.md, plan.md, data-model.md, contracts/, research.md, quickstart.md

3. **Project Setup Verification**:
   - Create/verify ignore files (.gitignore, .dockerignore, etc.) based on tech stack
   - Follow patterns from plan.md technology choices

4. Parse tasks.md and extract execution plan:
   - Task phases, dependencies, parallel markers [P]

5. Execute implementation phase-by-phase:
   - Complete each phase before moving to next
   - Respect dependencies (sequential vs parallel)
   - Mark completed tasks as [X] in tasks.md
   - Report progress after each completed task

6. **Checkpoint after each phase**:
   ```
   ✓ Phase [N] complete: [phase name]
   Tasks completed: [list]
   ```

7. Handle errors gracefully:
   - Log errors with context
   - Continue with parallel tasks if one fails
   - Halt on sequential task failures
   - Suggest recovery steps

### Final Report

After all phases complete (or on error):

```
=====================================
SPECKIT BUILD: [SUCCESS/PARTIAL/FAILED]
=====================================
Spec: [SPEC name]
Duration: [time]

Phase Results:
  Plan:      [✓/✗] [artifacts list or error]
  Tasks:     [✓/✗] [task count or error]
  Implement: [✓/✗] [completed/total tasks]

Files Modified: [count]
Tests Status: [passing/failing/skipped]

Next Steps: [if any issues]
=====================================
```

## Key Rules

- **No interactive prompts** - designed for unattended execution
- Use absolute paths everywhere
- ERROR on gate failures or unresolved clarifications in plan phase
- Mark tasks complete in tasks.md as they finish
- Log progress frequently for later review
- If any phase fails critically, stop and report clearly
