# Research: Rename Executable from byosm to byoman

**Feature**: 260202-mjk2-rename-byoman-executable
**Date**: 2026-02-02

## Summary

This rename is a straightforward refactor with no technical unknowns. All required changes are deterministic.

## Findings

### 1. Go Module Renaming

**Decision**: Direct in-place rename of module declaration and imports
**Rationale**: Go modules support arbitrary names without registry dependencies. Since this is a local project (not published to pkg.go.dev), the rename has no external impact.
**Alternatives Considered**:
- Using `replace` directive in go.mod → Rejected: unnecessary complexity for a complete rename
- Creating alias module → Rejected: adds confusion, no backward compatibility needed

### 2. Directory Rename Strategy

**Decision**: Use `mv cmd/byosm cmd/byoman` (or `git mv` if tracking is preferred)
**Rationale**: Git handles directory renames gracefully. The Go toolchain will find the new location automatically after go.mod update.
**Alternatives Considered**:
- Creating new directory and copying → Rejected: loses git history
- Leaving cmd/byosm as symlink → Rejected: unnecessary complexity

### 3. Import Statement Updates

**Decision**: Direct string replacement in affected files
**Rationale**: With only 3 files affected and deterministic paths, manual/scripted replacement is reliable.
**Alternatives Considered**:
- Using `gofmt -r` rewrite rules → Rejected: overkill for 3 files
- IDE refactor tools → Acceptable alternative but not required

### 4. Documentation Updates

**Decision**: Update historical spec files for consistency
**Rationale**: Maintaining accurate documentation prevents confusion when referencing past features.
**Alternatives Considered**:
- Leave historical docs unchanged with note → Rejected: creates inconsistency, references to non-existent `byosm` binary

## Resolved Clarifications

| Item | Resolution |
|------|------------|
| cmd/byosm directory exists? | ✅ Confirmed: `cmd/byosm/main.go` exists |
| Any external references? | ✅ None - local project only |
| Test dependencies on name? | ✅ None - no test files reference binary name |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Missed import statement | Low | `go build ./...` will fail if any missed |
| Stale `byosm` binary confuses users | Low | Document cleanup in quickstart.md |

## Conclusion

No NEEDS CLARIFICATION items. Proceed directly to implementation via tasks.md.
