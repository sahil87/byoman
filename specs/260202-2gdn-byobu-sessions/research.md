# Research: Byobu Sessions

**Feature**: 260202-2gdn-byobu-sessions
**Date**: 2026-02-02

## Research Questions

### Q1: How does byobu wrap tmux commands?

**Decision**: Byobu commands directly mirror tmux commands with the same syntax.

**Rationale**: Byobu is a wrapper around tmux (or screen). When using tmux backend (default), byobu passes commands through to tmux while ensuring byobu's configuration (status bar, keybindings, profiles) is loaded. The command syntax is identical:

| tmux command | byobu equivalent |
|--------------|------------------|
| `tmux list-sessions` | `byobu list-sessions` or `byobu ls` |
| `tmux new-session -d -s name` | `byobu new-session -d -s name` |
| `tmux attach-session -t name` | `byobu attach-session -t name` |
| `tmux rename-session -t old new` | `byobu rename-session -t old new` |
| `tmux kill-session -t name` | `byobu kill-session -t name` |

**Alternatives considered**:
- Using `byobu-select-session` for attachment: Rejected because it's interactive and not scriptable
- Using `byobu new -s name`: Works but `new-session` is more explicit and consistent with current code

**Sources**:
- [Byobu Commands Gist](https://gist.github.com/jshaw/5255721)
- [DigitalOcean Byobu Tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-byobu-for-terminal-management-on-ubuntu-16-04)

---

### Q2: How to check byobu version and availability?

**Decision**: Use `byobu-version` command (not `byobu -V` or `byobu --version`).

**Rationale**: Byobu provides a dedicated `byobu-version` command that outputs version information in a reliable format. The `byobu --version` flag may not work consistently across versions.

**Implementation**:
```go
func CheckVersion() error {
    binary, err := exec.LookPath("byobu")
    if err != nil {
        return fmt.Errorf("byobu is not installed. Install with: brew install byobu (macOS) or apt install byobu (Ubuntu)")
    }

    // Optionally verify byobu-version works
    cmd := exec.Command("byobu-version")
    if err := cmd.Run(); err != nil {
        // byobu exists but byobu-version may not - byobu is still usable
        // This is acceptable; proceed without version check
    }

    return nil
}
```

**Note on version checking**: Unlike tmux (which has strict API changes), byobu's commands are stable because it wraps tmux. We only need to verify byobu is installed, not check a minimum version. Byobu's own error handling will catch tmux version issues.

**Alternatives considered**:
- Check tmux version through byobu: Rejected as unnecessary complexity; byobu handles tmux compatibility internally
- Parse byobu-version output: Rejected as overkill; presence check is sufficient

**Sources**:
- [Byobu Official Site](https://www.byobu.org/)
- [Ubuntu Byobu Documentation](https://ubuntu.com/server/docs/tools-byobu/)

---

### Q3: Does byobu see sessions created by raw tmux?

**Decision**: Yes, byobu can list and attach to tmux sessions.

**Rationale**: Byobu is a wrapper - it uses tmux as its backend. All sessions are ultimately tmux sessions, so:
- Sessions created by `tmux new-session` appear in `byobu list-sessions`
- Sessions created by `byobu new-session` appear in `tmux list-sessions`
- The difference is that byobu-created sessions have byobu's configuration loaded

This is important for FR-005: "System MUST be able to list and manage sessions created by byobu directly (not just via byoman)"

**Alternatives considered**: None - this is how byobu works by design.

---

### Q4: What happens when user attaches to a session via byobu vs tmux?

**Decision**: Use byobu for attachment to ensure full byobu experience.

**Rationale**:
- `byobu attach-session -t name`: Loads byobu's status bar, keybindings, and configuration
- `tmux attach-session -t name`: Raw tmux, no byobu enhancements

This is the core value proposition - users get byobu's enhanced UX (F1-F12 shortcuts, status bar, etc.) when attaching through byoman.

---

### Q5: Error handling for missing byobu?

**Decision**: Fail fast with actionable error message.

**Rationale**: Per FR-003 and SC-005, error messages must tell users how to install byobu:
- macOS: `brew install byobu`
- Ubuntu/Debian: `sudo apt install byobu`
- Fedora: `sudo dnf install byobu`

**Implementation**:
```go
func CheckVersion() error {
    _, err := exec.LookPath("byobu")
    if err != nil {
        return fmt.Errorf("byobu is not installed.\n\nInstall with:\n  macOS:   brew install byobu\n  Ubuntu:  sudo apt install byobu\n  Fedora:  sudo dnf install byobu")
    }
    return nil
}
```

---

## Summary

The implementation is straightforward:

1. **Replace binary name**: Change `"tmux"` to `"byobu"` in all `exec.Command()` calls
2. **Simplify version check**: Remove tmux version parsing, just verify byobu exists
3. **Improve error messages**: Make installation instructions actionable

No architectural changes needed. The data models, TUI, and session operations remain identical.
