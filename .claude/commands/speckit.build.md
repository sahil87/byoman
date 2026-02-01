---
description: Execute the full build pipeline (plan → tasks → implement) for unattended execution.
---

## User Input

```text
$ARGUMENTS
```

## Purpose

This command orchestrates the complete spec-to-implementation workflow. Each phase runs as a **separate Claude CLI invocation** for complete context isolation.

## Execution

**Tell the user to run the script directly** from their terminal (not via Claude) so they see real-time output from each phase:

```bash
.specify/bin/speckit-build $ARGUMENTS
```

**Do NOT run this via the Bash tool** - the sub-command output would be hidden. The user needs to run it directly to see the streaming output from each Claude session.

### Argument Handling

- If `$ARGUMENTS` is empty: Run with no arguments (uses current spec)
- If `$ARGUMENTS` contains a spec name: Pass it through
- If `$ARGUMENTS` contains `--force` or `-f`: Pass it through
- If `$ARGUMENTS` contains `--dry-run` or `-n`: Pass it through
- If `$ARGUMENTS` is `help`: Pass it through

### Example Invocations

```bash
# No arguments - build current spec
.specify/bin/speckit-build

# Build specific spec
.specify/bin/speckit-build my-feature

# Force re-run all phases
.specify/bin/speckit-build --force

# Preview what would run
.specify/bin/speckit-build --dry-run

# Show help
.specify/bin/speckit-build help
```

## Why This Approach

The bash script runs each phase (`/speckit.plan`, `/speckit.tasks`, `/speckit.implement`) as a **separate `claude` CLI invocation**. This provides:

1. **Complete context isolation** - Each phase starts fresh
2. **No context exhaustion** - The orchestrator doesn't accumulate tokens
3. **Reliable execution** - Phases can't interfere with each other

## What Happens

1. Script validates spec exists
2. Detects which phases are already complete
3. Runs only needed phases sequentially
4. Each phase gets its own Claude session
5. Reports final status

## Output

You'll see progress like:

```
╔═══════════════════════════════════════════════════════════╗
║  SPECKIT BUILD                                            ║
╚═══════════════════════════════════════════════════════════╝

▸ Spec: my-feature
▸ Path: /path/to/specs/my-feature

Phase Status:
  Plan:   ○ pending
  Tasks:  ○ pending

▸ Phases to run: plan tasks implement

═══ Phase 1: Planning ═══
[Claude session runs /speckit.plan]
✓ Phase 1: Planning complete

═══ Phase 2: Task Generation ═══
[Claude session runs /speckit.tasks]
✓ Phase 2: Task Generation complete

═══ Phase 3: Implementation ═══
[Claude session runs /speckit.implement]
✓ Phase 3: Implementation complete

═══════════════════════════════════════════════════════════
SPECKIT BUILD: SUCCESS
═══════════════════════════════════════════════════════════
```
