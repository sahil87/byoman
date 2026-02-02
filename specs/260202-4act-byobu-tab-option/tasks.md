**Input**: Design documents from `/specs/260202-4act-byobu-tab-option/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅, contracts ✅

**Tests**: Manual validation steps included in tasks.

## Format: `- [ ] [TaskID] [P?] [Story?] Description with file path`

---

## Phase 1: Setup

- [x] T001 [P1] [S1] Add byobu tab exit code constant (`EXIT_BYOBU_TAB_ERROR=5`) in `.specify/bin/wt-create`

---

## Phase 2: Foundational

- [x] T002 [P1] [S1] Implement `is_byobu_session` helper using environment cues (e.g., `BYOBU_TTY`, `BYOBU_BACKEND`, `TMUX`) in `.specify/bin/wt-create`
- [x] T003 [P1] [S1] Persist worktree context for menu actions (`WT_NAME`, `WT_PATH`, `REPO_NAME`) when creating worktrees in `.specify/bin/wt-create`
- [x] T004 [P1] [S1] Add helper to derive byobu tab name as `repo + worktree` in `.specify/bin/wt-create`

---

## Phase 3: User Story 1 - Open Worktree in Byobu Tab (Priority: P1)

- [x] T005 [P1] [S1] Append `Byobu tab` entry to `AVAILABLE_APPS` only when `is_byobu_session` is true in `.specify/bin/wt-create`
- [x] T006 [P1] [S1] Implement `open_in_app` handler for `byobu_tab` using `byobu new-window -n <tab> -c <path>` and focus semantics in `.specify/bin/wt-create`
- [x] T007 [P1] [S1] Emit error message per contract and exit with code 5 on byobu tab failure in `.specify/bin/wt-create`

---

## Phase 4: User Story 2 - No Byobu Option Outside Session (Priority: P2)

- [x] T008 [P2] [S2] Verify non-byobu runs never show the `Byobu tab` option in `.specify/bin/wt-create`

---

## Final: Polish

- [x] T009 [P1] [S1] Manual test inside byobu: select `Byobu tab`, confirm focus, cwd, and tab name format in `.specify/bin/wt-create`
- [x] T010 [P1] [S1] Manual test failure path: force byobu open failure and confirm error output + exit code 5 in `.specify/bin/wt-create`
