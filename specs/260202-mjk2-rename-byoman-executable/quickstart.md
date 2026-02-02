# Quickstart: Rename Executable from byosm to byoman

**Feature**: 260202-mjk2-rename-byoman-executable
**Date**: 2026-02-02

## Prerequisites

- Go 1.21+ installed
- Project cloned to local machine

## Build & Verify

After applying all changes from this feature:

```bash
# Build the renamed executable
go build -o byoman ./cmd/byoman

# Verify build succeeded
ls -la byoman

# Run the TUI (requires byobu/tmux)
./byoman
```

## Verification Checklist

1. **Module compiles**: `go build ./...` exits with code 0
2. **Executable runs**: `./byoman` launches the TUI
3. **No old references**: `grep -r "byosm" --include="*.go" .` returns nothing
4. **Git status clean**: `git status` shows expected changes only

## Cleanup

If you have an old `byosm` binary from previous builds:

```bash
# Remove old binary (if exists)
rm -f byosm
```

The `.gitignore` is updated to ignore `byoman` only.

## Troubleshooting

### Build fails with import errors

Check that all import statements were updated:

```bash
# Find any remaining byosm imports
grep -r '"byosm/' --include="*.go" .
```

Update any found references to use `"byoman/..."`.

### Binary name wrong

Ensure you're building with explicit output name:

```bash
go build -o byoman ./cmd/byoman
```

Without `-o byoman`, Go may use a default name based on the directory.
