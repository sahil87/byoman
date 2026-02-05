## Why

When working on a mobile phone, byobu's status bar is too long and consumes valuable screen space. The right side of the status bar shows many widgets that eat up the whole terminal width, making it impractical for mobile use.

## What Changes

- All byobu sessions started via byoman use a minimal status bar (always-on mobile mode)
- Minimal status bar shows only time and date (can be extended later)
- New sessions created by byoman automatically get the minimal config
- (Optional) Allow applying minimal mode to existing byobu sessions if feasible

## Capabilities

### New Capabilities
- `mobile-statusbar`: Minimal byobu status bar (time/date only) applied to all byoman-created sessions - always on, toggle option to be added later

### Modified Capabilities
<!-- None - this is additive functionality -->

## Impact

- **Code**: `internal/tmux/client.go` - `NewSession` function needs to apply mobile config
- **Config**: May need byobu config files (status, statusrc) for mobile mode
- **Dependencies**: None new - uses existing byobu configuration mechanisms
- **User experience**: Byoman-created sessions will have cleaner mobile display by default
