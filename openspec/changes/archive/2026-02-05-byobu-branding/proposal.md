## Why

The project name is **BYOMAN** (BYObu MANager), but the codebase heavily references "tmux" instead of "byobu" throughout. This creates confusion about the tool's identity and purpose. Users should immediately understand this is a byobu-focused tool, with tmux being the underlying implementation detail.

## What Changes

- **Rename `internal/tmux/` package** to `internal/byobu/` - this is the primary interface abstraction
- **Update all Go source files** to import and reference `byobu` instead of `tmux` where it represents our abstraction layer
- **Update README.md** to lead with byobu terminology, mentioning tmux only as the underlying backend
- **Update documentation/specs** to use consistent byobu-first language
- **Preserve tmux references** only where they refer to actual tmux commands/APIs (e.g., `tmux list-sessions`)

## Capabilities

### New Capabilities

None - this is a terminology/branding refactor, not new functionality.

### Modified Capabilities

None - no behavioral changes, only naming consistency.

## Impact

- **Go source code**: `internal/tmux/` → `internal/byobu/`, all imports updated
- **Documentation**: README.md, spec files, CLAUDE.md
- **No API changes**: The tool's CLI interface and behavior remain identical
- **No breaking changes**: Users won't notice any functional difference
