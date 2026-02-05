---
description: Execute the full build pipeline (plan → tasks → implement) for unattended execution.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty):
- If contains `--force` or `-f`: Re-run all phases regardless of existing artifacts
- If contains `--dry-run` or `-n`: Show what would run without executing
- If contains a spec name: Switch to that spec first
- If `help`: Show usage information and stop

## Workflow

### Step 1: Setup & Phase Detection

Run `.specify/scripts/bash/setup-plan.sh --json` from repo root to get paths:
```bash
.specify/scripts/bash/setup-plan.sh --json
```

Parse the JSON output for:
- `FEATURE_SPEC`: Path to spec.md
- `IMPL_PLAN`: Path to plan.md
- `FEATURE_DIR`: Feature directory path
- `SPEC`: Current spec name

**If script fails** (no current spec): ERROR with "No spec selected. Run /speckit.switch first."

**Detect phase completion**:

1. **Plan complete** if ALL of these are true:
   - `plan.md` exists in FEATURE_DIR
   - At least 2 of these exist: `research.md`, `data-model.md`, `quickstart.md`, `contracts/` (non-empty)

2. **Tasks complete** if:
   - `tasks.md` exists in FEATURE_DIR
   - Contains at least one task pattern (`## Task` or `- [ ] T`)

**Report status to user**:
```
╔═══════════════════════════════════════════════════════════╗
║  SPECKIT BUILD                                            ║
╚═══════════════════════════════════════════════════════════╝

▸ Spec: {SPEC}
▸ Path: {FEATURE_DIR}

Phase Status:
  Plan:   ✓ complete | ○ pending
  Tasks:  ✓ complete | ○ pending

▸ Phases to run: [plan] [tasks] implement
```

**If --dry-run**: Report what would run and STOP here.

### Step 2: Plan Phase (if needed)

**Skip if**: Plan is already complete AND not --force

**Execute**: Use the Task tool to spawn a planning agent with its own context:

```
Task(
  subagent_type="general-purpose",
  description="Execute planning phase",
  prompt="You are executing the planning phase for spec: {SPEC}

FEATURE_DIR: {FEATURE_DIR}

Execute the /speckit.plan workflow:
1. Read the spec at {FEATURE_DIR}/spec.md
2. Read constitution at .specify/memory/constitution.md (if exists)
3. Generate research.md - resolve any technical unknowns
4. Generate data-model.md - extract entities from spec
5. Generate contracts/ - API contracts if applicable
6. Generate quickstart.md - test scenarios
7. Run .specify/scripts/bash/update-agent-context.sh claude

Write all artifacts to {FEATURE_DIR}/

Report: List all generated artifacts and any issues encountered."
)
```

**After Task completes**:
- If successful: Report "✓ Plan phase complete" and list artifacts
- If failed: Report error, suggest fixes, and STOP

### Step 3: Tasks Phase (if needed)

**Skip if**: Tasks are already complete AND not --force

**Execute**: Use the Task tool to spawn a task generation agent:

```
Task(
  subagent_type="general-purpose",
  description="Generate implementation tasks",
  prompt="You are generating tasks for spec: {SPEC}

FEATURE_DIR: {FEATURE_DIR}

Execute the /speckit.tasks workflow:
1. Run .specify/scripts/bash/check-prerequisites.sh --json to verify context
2. Read plan.md for tech stack and architecture
3. Read spec.md for user stories with priorities (P1, P2, P3...)
4. Read data-model.md, contracts/, research.md if they exist
5. Generate tasks.md organized by user story phases:
   - Phase 1: Setup
   - Phase 2: Foundational
   - Phase 3+: One phase per user story in priority order
   - Final: Polish

Each task MUST follow format: - [ ] [TaskID] [P?] [Story?] Description with file path

Write tasks.md to {FEATURE_DIR}/tasks.md

Report: Total task count, tasks per story, parallel opportunities."
)
```

**After Task completes**:
- If successful: Report "✓ Tasks phase complete" with summary
- If failed: Report error and STOP

### Step 4: Implementation Phase

**Execute**: Use the Task tool to spawn an implementation agent:

```
Task(
  subagent_type="general-purpose",
  description="Execute implementation",
  prompt="You are implementing spec: {SPEC}

FEATURE_DIR: {FEATURE_DIR}

Execute the /speckit.implement workflow:
1. Run .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
2. Check checklists status in {FEATURE_DIR}/checklists/ if exists
3. Read tasks.md for the complete task list
4. Read plan.md for tech stack and file structure
5. Execute tasks phase by phase:
   - Setup phase first
   - Then each user story phase in order
   - Polish phase last
6. For each completed task, mark as [X] in tasks.md
7. Respect dependencies - sequential tasks in order, [P] tasks can parallelize

Report: Completed tasks, any failures, final status."
)
```

**After Task completes**:
- If successful: Report "✓ Implementation phase complete"
- If failed: Report which tasks failed and why

### Step 5: Final Report

```
═══════════════════════════════════════════════════════════
SPECKIT BUILD: {SUCCESS | FAILED}
═══════════════════════════════════════════════════════════
Spec: {SPEC}
Phases executed: {list}
Artifacts generated: {list}

{If failed: "Failed at: {phase}" with error details}
{If success: "All phases completed successfully."}
```

## Key Design: Context Isolation via Task Tool

Each phase runs as a **separate Task subagent** with its own ~200k context window. This prevents:
- Context exhaustion from accumulating file reads
- Cross-phase interference
- The "stops after first phase" problem

The orchestrator (this skill) stays lightweight - it only:
- Detects phase status
- Spawns Task agents
- Reports results

Heavy work (file reading, generation, implementation) happens in subagents.
