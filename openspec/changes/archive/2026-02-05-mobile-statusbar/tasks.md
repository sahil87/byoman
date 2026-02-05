## 1. Core Implementation

- [x] 1.1 Add `ConfigureMinimalStatusBar(sessionName string) error` method to `internal/tmux/client.go`
- [x] 1.2 Implement the method using `byobu set-option -t <session> status-right` with CPU% display
- [x] 1.3 Update `Client` interface to include the new method

## 2. Integration

- [x] 2.1 Call `ConfigureMinimalStatusBar` after `NewSession` in the session creation flow
- [x] 2.2 Add error handling (log warning but don't fail session creation if status bar config fails)

## 3. Existing Sessions Support

- [x] 3.1 Expose `ConfigureMinimalStatusBar` for use on existing sessions (same method works for both)
- [x] 3.2 Verify the method can be called on any running session without disruption

## 4. Testing

- [x] 4.1 Manual test: create new session via byoman, verify minimal status bar
- [x] 4.2 Manual test: detach and reattach, verify status bar persists
- [x] 4.3 Manual test: verify other byobu sessions retain their original status bar
