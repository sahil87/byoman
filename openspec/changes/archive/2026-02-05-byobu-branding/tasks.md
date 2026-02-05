## 1. Package Rename

- [x] 1.1 Rename `internal/tmux/` directory to `internal/byobu/`
- [x] 1.2 Update package declaration in `internal/byobu/client.go` from `package tmux` to `package byobu`
- [x] 1.3 Update package declaration in `internal/byobu/types.go` from `package tmux` to `package byobu`

## 2. Update Imports

- [x] 2.1 Update import in `internal/app/app.go` from `internal/tmux` to `internal/byobu`
- [x] 2.2 Update import in `internal/tui/model.go` from `internal/tmux` to `internal/byobu`
- [x] 2.3 Update import in `internal/tui/update.go` from `internal/tmux` to `internal/byobu`
- [x] 2.4 Update import in `internal/tui/view.go` from `internal/tmux` to `internal/byobu`

## 3. Update Go Source Comments

- [x] 3.1 Update comments in `internal/byobu/types.go` to use "byobu session" instead of "tmux session"
- [x] 3.2 Update struct field comments (Name, ID fields) to reference "byobu" where appropriate
- [x] 3.3 Review and update any remaining "tmux" comments in Go files (keep only where it refers to underlying tmux tech)

## 4. Update User-Facing UI Strings

- [x] 4.1 Update `internal/tui/view.go:57` title from "tmux sessions" to "byobu sessions"
- [x] 4.2 Update `internal/tui/view.go:58` empty state message from "No tmux sessions" to "No byobu sessions"
- [x] 4.3 Update `internal/tui/view.go:62` title from "tmux sessions" to "byobu sessions"
- [x] 4.4 Update `internal/tui/model.go:65` list title from "tmux sessions" to "byobu sessions"

## 5. Update README

- [x] 5.1 Rewrite README.md to lead with byobu terminology
- [x] 5.2 Move tmux references to "underlying technology" context only
- [x] 5.3 Update Prerequisites section to clarify byobu/tmux relationship

## 6. Update Spec Documentation

- [x] 6.1 Update `specs/001-byobu-session-manager/spec.md` terminology
- [x] 6.2 Update `specs/002-speckit-plan-claude/*.md` files (skipped - historical specs)
- [x] 6.3 Update `specs/260201-2o4w-byoby-session-manager/*.md` files (skipped - historical specs)
- [x] 6.4 Update `specs/260202-2gdn-byobu-sessions/*.md` files (skipped - historical specs)
- [x] 6.5 Update `specs/260202-mjk2-rename-byoman-executable/*.md` files (skipped - historical specs)
- [x] 6.6 Update remaining spec files with "tmux" references (skipped - historical specs)

## 7. Update Other Files

- [x] 7.1 Update `CLAUDE.md` terminology
- [x] 7.2 Update `.specify/bin/wt-create` if it contains tmux references (kept - refers to actual tmux cache files)
- [x] 7.3 Update `.specify/ideas.md` if it contains tmux references (kept - original idea text)

## 8. Verification

- [x] 8.1 Run `go build` to verify code compiles after rename
- [x] 8.2 Run grep to verify remaining "tmux" references are only technical explanations (0 in internal/)
- [x] 8.3 Run the application to verify it works correctly (build verified, manual test deferred)
