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

## CRITICAL: Orchestrator Behavior

**You are an ORCHESTRATOR.** Each Skill invocation is a subagent call that will return control to you. When a subagent completes, you **MUST** continue to the next phase. **DO NOT STOP** until the Final Report is generated.

After Phase 0 detection, check this list and continue to the next uncompleted phase:

- [ ] Phase 0: Setup & Validation + **Phase Detection**
- [ ] Phase 1: Plan → **SKIP if plan already complete** → else invoke, then immediately continue
- [ ] Phase 2: Tasks → **SKIP if tasks already complete** → else invoke, then immediately continue
- [ ] Phase 3: Implement → **then immediately generate Final Report**
- [ ] Final Report

**Phase skipping**: If detection finds plan/tasks already complete, report the skip and proceed to the next needed phase.

## Architecture

```
speckit.build (orchestrator - minimal context)
    │
    ├── Validate spec exists
    │
    ├── Detect phase completion status
    │   ├── Check: plan.md exists? → plan_complete
    │   ├── Check: tasks.md exists? → tasks_complete
    │   └── Determine: starting_phase (1, 2, or 3)
    │
    ├── [If plan incomplete] Spawn: speckit.plan subagent
    │   └── Returns: plan artifacts status
    │
    ├── [If tasks incomplete] Spawn: speckit.tasks subagent
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

3. **Detect Phase Completion Status**:

   **Plan Validation** - Check if plan phase is complete:
   - Primary check: `${FEATURE_DIR}/plan.md` exists
   - Secondary checks (all should exist for complete plan):
     - `${FEATURE_DIR}/research.md`
     - `${FEATURE_DIR}/data-model.md`
     - `${FEATURE_DIR}/quickstart.md`
     - `${FEATURE_DIR}/contracts/` directory
   - **Plan complete**: Primary AND at least 2 secondary artifacts exist
   - **Plan incomplete**: Primary missing OR fewer than 2 secondary artifacts

   **Tasks Validation** - Check if tasks phase is complete:
   - Check: `${FEATURE_DIR}/tasks.md` exists
   - **Tasks complete**: File exists and contains at least one task (has `## Task` heading)
   - **Tasks incomplete**: File missing or empty

4. **Determine Starting Phase**:
   ```
   IF plan incomplete → START_PHASE = 1 (Plan)
   ELSE IF tasks incomplete → START_PHASE = 2 (Tasks)
   ELSE → START_PHASE = 3 (Implement)
   ```

5. Report starting state:
   ```
   🔨 SPECKIT BUILD: Starting pipeline
   Spec: [SPEC name]
   Feature: [FEATURE_DIR]

   Phase Status:
     Plan:   [✓ complete / ○ pending]
     Tasks:  [✓ complete / ○ pending]

   Starting from: Phase [START_PHASE] ([Plan/Tasks/Implement])
   ```

### Phase 1: Plan (subagent)

**Check if plan is already complete** (from Phase 0 detection):
- If **plan complete**:
  ```
  ⏭ Plan phase: SKIPPED (artifacts already exist)
  ```
  **Immediately proceed to Phase 2.**

- If **plan incomplete**:
  **Invoke the Skill tool** with skill `speckit.plan` and pass any relevant user arguments.

  Wait for completion. Check result:
  - **Success**: Report artifacts generated, continue to Phase 2
  - **Failure**: Report error, **STOP** pipeline

  ```
  ✓ Plan phase complete
  ```

**⚠️ DO NOT STOP HERE. Immediately invoke Phase 2 (speckit.tasks).**

### Phase 2: Tasks (subagent)

**Check if tasks are already complete** (from Phase 0 detection):
- If **tasks complete**:
  ```
  ⏭ Tasks phase: SKIPPED (tasks.md already exists)
  ```
  **Immediately proceed to Phase 3.**

- If **tasks incomplete**:
  **Invoke the Skill tool** with skill `speckit.tasks` and pass any relevant user arguments.

  Wait for completion. Check result:
  - **Success**: Report task count, continue to Phase 3
  - **Failure**: Report error, **STOP** pipeline

  ```
  ✓ Tasks phase complete
  ```

**⚠️ DO NOT STOP HERE. Immediately invoke Phase 3 (speckit.implement).**

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

**⚠️ DO NOT STOP HERE. Immediately generate the Final Report.**

### Final Report (orchestrator)

After all phases complete (or on error):

```
=====================================
SPECKIT BUILD: [SUCCESS/PARTIAL/FAILED]
=====================================
Spec: [SPEC name]

Phase Results:
  Plan:      [✓ done / ⏭ skipped / ✗ failed]
  Tasks:     [✓ done / ⏭ skipped / ✗ failed]
  Implement: [✓/✗] [completed/total tasks]

Started from: Phase [N] ([phase name])
Next Steps: [if any issues]
=====================================
```

## Key Rules

- **NEVER STOP EARLY** - After each Skill returns, immediately continue to the next phase. Only stop after Final Report.
- **Use subagents** - Each phase runs as a separate Skill invocation to preserve context
- **Orchestrator stays lightweight** - Only validates, spawns, and reports
- **Sequential phases** - Wait for each phase to complete before starting next
- **Checklist verification preserved** - The implement subagent handles checklist checks
- **Stop on critical failures** - If plan or tasks fail, don't attempt subsequent phases
- **Respect phase detection** - Skip phases that are already complete unless `--force` is specified
- Use absolute paths everywhere

## Force Flag

If the user provides `--force` or `force` in arguments:
- **Ignore phase detection** - Run all phases regardless of existing artifacts
- Report: `⚠️ Force mode: Re-running all phases`

Example: `/speckit.build --force` or `/speckit.build force`
