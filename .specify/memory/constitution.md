<!--
Sync Impact Report
==================
Version change: 0.0.0 → 1.0.0 (initial ratification)
Modified principles: N/A (initial creation)
Added sections:
  - Core Principles (5 principles)
  - Performance Standards
  - Development Workflow
  - Governance
Removed sections: N/A
Templates requiring updates:
  - .specify/templates/plan-template.md: ✅ no changes needed (Constitution Check section is generic)
  - .specify/templates/spec-template.md: ✅ no changes needed (requirements structure is compatible)
  - .specify/templates/tasks-template.md: ✅ no changes needed (phase structure is compatible)
Follow-up TODOs: None
-->

# Byoman Constitution

## Core Principles

### I. Terminal-First Design

All user interactions MUST be optimized for shell terminal workflows:

- Output MUST be readable in standard 80-column terminals by default
- Commands MUST support both interactive and scriptable (non-interactive) modes
- All output MUST be parseable: human-readable by default, JSON via `--json` flag
- Exit codes MUST follow POSIX conventions: 0 for success, non-zero for errors
- Color output MUST respect `NO_COLOR` environment variable and `--no-color` flag

**Rationale**: Terminal users expect predictable, scriptable behavior. Byoman integrates into
existing shell workflows and must not break automation pipelines or accessibility tools.

### II. Byobu Session Integrity

Session management operations MUST preserve user data and state:

- MUST never destroy or corrupt active byobu sessions without explicit user confirmation
- Session state changes MUST be atomic: complete fully or roll back
- MUST gracefully handle concurrent access to the same sessions
- Session metadata MUST be stored in well-defined, recoverable locations
- MUST detect and warn about orphaned or corrupted sessions

**Rationale**: Users trust byoman with their terminal sessions containing potentially hours of
unsaved work. Data integrity is non-negotiable.

### III. Code Quality Standards

All code contributions MUST meet these quality gates:

- Functions MUST be <50 lines; files MUST be <500 lines (excluding tests)
- Public APIs MUST have docstrings with usage examples
- All user-facing strings MUST be defined in a single location for consistency
- Error messages MUST include: what failed, why, and suggested remediation
- No silent failures: all errors MUST be logged or reported

**Rationale**: A small, focused codebase is easier to maintain and debug. Clear error messages
reduce user frustration and support burden.

### IV. Performance Requirements

Terminal interactions MUST feel instantaneous:

- Command startup MUST complete in <100ms for simple operations
- Session listing MUST complete in <500ms for up to 100 sessions
- Long-running operations MUST show progress indicators
- Memory usage MUST stay under 50MB for typical operations
- MUST avoid unnecessary I/O: cache session state where safe

**Rationale**: Terminal users expect immediate feedback. Slow CLI tools break flow and encourage
users to switch to alternatives.

### V. Graceful Degradation

The system MUST handle adverse conditions without catastrophic failure:

- MUST operate correctly when byobu is not installed (with clear error message)
- MUST handle missing configuration files by using sensible defaults
- Network operations (if any) MUST have timeouts and offline fallbacks
- MUST log detailed diagnostics to `~/.byoman/logs/` for troubleshooting
- Partial failures SHOULD complete what's possible and report what failed

**Rationale**: Real-world environments are messy. Robust error handling builds user trust and
simplifies debugging.

## Performance Standards

### Benchmarks

| Operation | Target | Maximum |
|-----------|--------|---------|
| Command startup (no-op) | <50ms | 100ms |
| List all sessions | <200ms | 500ms |
| Create new session | <300ms | 1000ms |
| Attach to session | <100ms | 300ms |
| Configuration load | <20ms | 50ms |

### Monitoring

- Performance regression tests MUST run in CI for critical paths
- Any operation exceeding targets MUST be flagged for optimization review
- Memory profiling SHOULD be performed quarterly or after major changes

## Development Workflow

### Code Review Requirements

- All changes MUST be reviewed before merge
- Reviews MUST verify compliance with Core Principles
- Performance-sensitive changes MUST include benchmark results

### Testing Discipline

- Unit tests MUST cover all public functions
- Integration tests MUST cover all CLI commands
- Tests MUST NOT depend on actual byobu sessions (use mocks/fixtures)

### Release Process

- Versions follow MAJOR.MINOR.PATCH semantic versioning
- Breaking changes to CLI interface require MAJOR version bump
- All releases MUST include changelog entries

## Governance

This constitution supersedes all other development practices for byoman.

**Amendment Process**:
1. Propose changes via pull request to this document
2. Changes require explicit approval from project maintainer
3. Breaking changes to principles require migration plan

**Compliance**:
- All pull requests MUST pass Constitution Check in plan review
- Violations require documented justification in Complexity Tracking section
- Repeated violations trigger process review

**Version**: 1.0.0 | **Ratified**: 2026-01-30 | **Last Amended**: 2026-01-30
