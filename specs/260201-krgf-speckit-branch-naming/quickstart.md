# Quickstart: Speckit Branch Naming

## Overview

When you run `speckit specify` on a temporary worktree branch (like `wt/amsterdam`), it automatically renames the branch to match your feature spec name.

## Basic Usage

### Scenario 1: Auto-rename from Feature Description (P1)

```bash
# 1. Create a worktree (assigns random branch like wt/amsterdam)
wt-create

# 2. Define your feature - branch is automatically renamed
speckit specify "Add user authentication"

# Output:
# ✓ Created spec: 260201-krgf-user-auth
# ✓ Renamed branch: wt/amsterdam → 260201-krgf-user-auth
# Push to origin and set up tracking? [y/N]
```

### Scenario 2: Use Linear Branch Name (P2)

```bash
# Provide your own branch name via --branch flag
speckit specify --branch "feature/dev-907-byoman" "Implement user dashboard"

# Output:
# ✓ Created spec: 260201-abcd-user-dashboard
# ✓ Renamed branch: wt/tokyo → feature/dev-907-byoman
# Push to origin and set up tracking? [y/N]
```

### Scenario 3: Already on Canonical Branch (P3)

```bash
# Already on a feature branch? No rename happens
git checkout -b feature/existing-work
speckit specify "Continue existing feature"

# Output:
# ✓ Created spec: 260201-efgh-existing-feature
# ℹ Branch preserved: feature/existing-work (already canonical)
```

## Command Reference

```bash
speckit specify [OPTIONS] "<feature description>"

Options:
  --branch <name>    Use this branch name instead of auto-generating
  --no-rename        Skip branch rename entirely
  --json             Output results as JSON (non-interactive)
```

## What Gets Renamed

| Current Branch | With `speckit specify` | With `--branch "custom"` |
|----------------|------------------------|--------------------------|
| `wt/amsterdam` | → `260201-xxxx-slug` | → `custom` |
| `wt/tokyo` | → `260201-xxxx-slug` | → `custom` |
| `feature/foo` | *(no change)* | → `custom` |
| `main` | *(warning, no change)* | → `custom` |

## Edge Cases

### Branch Name Collision (Local)

```bash
# If 260201-krgf-user-auth already exists locally
speckit specify "Add user authentication"

# Output:
# ✓ Created spec: 260201-krgf-user-auth
# ⚠ Branch 260201-krgf-user-auth exists locally, using: 260201-krgf-user-auth-2
# ✓ Renamed branch: wt/amsterdam → 260201-krgf-user-auth-2
```

### Branch Name Collision (Remote)

```bash
# If branch exists on origin but not locally
speckit specify "Add user authentication"

# Output:
# ✓ Created spec: 260201-krgf-user-auth
# ⚠ Branch 260201-krgf-user-auth exists on remote origin
#   (You may be continuing work on an existing feature)
# ✓ Renamed branch: wt/amsterdam → 260201-krgf-user-auth
```

### Protected Branch Warning

```bash
# Running from main branch
speckit specify "Quick fix"

# Output:
# ✓ Created spec: 260201-ijkl-quick-fix
# ⚠ Warning: Working on 'main' branch
#   Consider creating a feature branch: git checkout -b 260201-ijkl-quick-fix
```

### Rename Failure

```bash
# If git rename fails for any reason
speckit specify "Add user authentication"

# Output:
# ✓ Created spec: 260201-krgf-user-auth
# ⚠ Branch rename failed: [error details]
#   Spec created successfully. You can rename manually:
#   git branch -m wt/amsterdam 260201-krgf-user-auth
```

## JSON Output

For scripting, use `--json` flag:

```bash
speckit specify --json "Add user authentication"
```

```json
{
  "spec_name": "260201-krgf-user-auth",
  "spec_file": "/path/to/specs/260201-krgf-user-auth/spec.md",
  "branch": {
    "original": "wt/amsterdam",
    "current": "260201-krgf-user-auth",
    "renamed": true,
    "pushed": false
  }
}
```

## Common Workflows

### Linear Integration

```bash
# Get branch name from Linear issue
LINEAR_BRANCH=$(linear issue branch --issue DEV-907)

# Use it with speckit
speckit specify --branch "$LINEAR_BRANCH" "$(linear issue title --issue DEV-907)"
```

### CI/Automation

```bash
# Non-interactive mode for scripts
speckit specify --json --no-rename "Automated feature" | jq -r '.spec_name'
```

## See Also

- [Feature Spec](spec.md) - Full requirements
- [Data Model](data-model.md) - Entity definitions
- [Research](research.md) - Design decisions
