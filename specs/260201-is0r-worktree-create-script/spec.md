# Feature Specification: Git Worktree Creation Script

**Feature Branch**: `260201-is0r-worktree-create-script`
**Created**: 2026-02-01
**Status**: Draft
**Input**: User description: "Add a script to create a new worktree. Need to determine best practices for worktree location."
**Invocation**: `wt-create` standalone shell script (independent of speckit)

## Clarifications

### Session 2026-02-01

- Q: How should the script distinguish between creating a new branch vs using an existing branch? → A: Auto-detect - if branch exists (local or remote), use it; otherwise create new branch
- Q: How should worktree directories be named? → A: Random memorable names (like Conductor's city names) - decoupled from branch name, enables "explore first, name later" workflow
- Q: What should the initial branch be named for exploratory worktrees? → A: Match worktree name with `wt/` prefix (e.g., `wt/prague`) - clear link to worktree, easily renamed later by `/speckit.specify`
- Q: How should users open/access the new worktree after creation? → A: Present numbered menu of options (Conductor-style): 1) VSCode, 2) Cursor, 3) Terminal, 4) Finder, 5) Copy path, etc. User picks a number to execute.
- Q: How should users invoke worktree creation? → A: Standalone shell script (`wt-create`) - independent of speckit, usable from any terminal
- Q: How should users continue Claude Code work in the newly created worktree? → A: Out of scope - script creates worktree and offers access options; what user does after (including starting Claude) is their responsibility
- Q: Should worktree creation be part of speckit? → A: No - standalone script independent of speckit. Worktrees are a git concept; script is reusable across any project.
- Q: How should memorable random names be generated? → A: Hardcoded list in script (~50-100 city names) - no external dependencies, sufficient uniqueness for typical usage
- Q: What if randomly selected name collides with existing worktree? → A: Auto-retry with different random name (silent, up to N attempts before failing)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create Exploratory Worktree (Priority: P1)

A developer wants to start working on something new without disturbing their current work, even if they don't yet know exactly what they'll build. They run `wt-create`, which creates a new worktree with a memorable random name (e.g., "prague") and a corresponding temporary branch (`wt/prague`), allowing them to immediately begin exploration.

**Why this priority**: This is the primary use case. Developers need to quickly spin up isolated workspaces for parallel development. The "explore first, name later" approach removes friction - no need to decide on a feature name before starting.

**Independent Test**: Can be fully tested by running `wt-create` with no arguments and verifying a worktree is created with a random memorable name and matching `wt/` branch.

**Acceptance Scenarios**:

1. **Given** a user is in a git repository, **When** they run `wt-create` with no arguments, **Then** a new worktree is created with a random memorable name (e.g., "prague") and branch `wt/prague`
2. **Given** a worktree is created, **When** creation completes, **Then** the script displays the worktree name/path and presents the "open in" menu
3. **Given** a user runs the script, **When** creation is successful, **Then** the worktree contains a fresh checkout ready for development

---

### User Story 2 - Create Worktree for Existing Branch (Priority: P2)

A developer needs to work on an existing branch (e.g., a bug fix branch or someone else's feature branch) in isolation. They run `wt-create <branch-name>` specifying the existing branch name, and a worktree is created for that branch.

**Why this priority**: Working on existing branches is common for code reviews, bug fixes, and collaboration, but less frequent than starting new work.

**Independent Test**: Can be tested by creating a worktree for an existing branch and verifying the worktree uses that branch without creating a duplicate.

**Acceptance Scenarios**:

1. **Given** an existing branch in the repository, **When** the user runs the script with that branch name, **Then** a worktree is created that checks out the existing branch
2. **Given** a branch that doesn't exist locally but exists on remote, **When** the user runs the script, **Then** the script fetches and creates a worktree tracking the remote branch

---

### User Story 3 - Open Worktree in Preferred Tool (Priority: P2)

After creating a worktree, the developer is presented with a numbered menu of options for how to open/access it. They pick a number (e.g., "1" for VSCode, "2" for Cursor), and the corresponding action executes.

**Why this priority**: Reduces friction - users don't need to remember commands or manually navigate. Directly supports the parallel development workflow.

**Independent Test**: Can be tested by creating a worktree and verifying the numbered menu appears with working options.

**Acceptance Scenarios**:

1. **Given** a worktree was just created, **When** creation completes, **Then** a numbered menu of "open in" options is displayed
2. **Given** the menu is displayed, **When** user enters a number, **Then** the corresponding action executes (e.g., opens in VSCode)
3. **Given** the menu is displayed, **When** user enters an invalid option, **Then** an error is shown and the menu is re-displayed
4. **Given** the menu is displayed, **When** user presses Enter or 0, **Then** script exits without opening anything (just shows path)

---

### User Story 4 - View and Manage Worktree Information (Priority: P3)

A developer wants to see where worktrees are being created or understand the script's behavior. They run `wt-create help` to see usage information and the configured worktree location.

**Why this priority**: Documentation and discoverability improve usability but aren't core functionality.

**Independent Test**: Can be tested by running `wt-create help` and verifying useful information is displayed.

**Acceptance Scenarios**:

1. **Given** a user wants help, **When** they run `wt-create help`, **Then** usage information including the worktree location pattern is displayed

---

### Edge Cases

- What happens when a worktree with the same random name already exists? → Script silently auto-retries with a different random name (up to N attempts; fails with error if all exhausted)
- What happens when the user is not in a git repository? → Script reports error with clear message
- What happens when the worktrees parent directory doesn't exist? → Script creates it automatically
- What happens when the user doesn't have write permissions to the worktree location? → Script reports permission error with suggested fix
- What happens when a branch name contains special characters? → Script sanitizes the directory name while preserving the branch name

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Script MUST create a new git worktree in the designated worktrees directory
- **FR-002**: Script MUST auto-detect branch existence: if the specified branch exists (locally or on remote), check it out; otherwise create a new branch
- **FR-003**: Script MUST NOT require explicit flags to distinguish between new vs existing branch behavior
- **FR-004**: Script MUST use a consistent, predictable directory naming convention for worktrees
- **FR-005**: Script MUST output the path to the created worktree upon success
- **FR-006**: Script MUST detect and report when not run from within a git repository
- **FR-007**: Script MUST handle the case where a worktree with the same name already exists by reporting the conflict
- **FR-008**: Script MUST create the worktrees parent directory if it doesn't exist
- **FR-009**: Script MUST provide usage guidance when user asks for help
- **FR-010**: Script MUST base new branches off the repository's default branch (main/master)
- **FR-011**: Script MUST name new branches with `wt/<worktree-name>` format (e.g., `wt/prague`) when creating exploratory worktrees
- **FR-012**: Script MUST display a numbered "open in" menu after successful worktree creation
- **FR-013**: Menu MUST include options for: VSCode, Cursor, Terminal (cd), Finder/File Explorer, Copy path to clipboard, and Exit (path only)
- **FR-014**: Script MUST detect which tools are available on the system and only show valid options
- **FR-015**: Script MUST be implemented as a standalone POSIX-compliant shell script, installable to user's PATH

### Application Detection Requirements

- **FR-016**: Script MUST detect installed applications using OS-appropriate methods:
  - **macOS**: Use `mdfind "kMDItemCFBundleIdentifier == '<bundle-id>'"` for GUI apps
  - **Linux**: Check `.desktop` files in `/usr/share/applications/` and `~/.local/share/applications/`
  - **Cross-platform fallback**: Use `command -v <cli-tool>` (POSIX-compliant, works everywhere)

- **FR-017**: Script MUST use OS-appropriate commands to open folders:
  - **macOS**: `open <path>` (native) or `open -a <AppName> <path>` (specific app)
  - **Linux**: `xdg-open <path>` (respects user's default apps)
  - For editors with CLI: `code <path>`, `cursor <path>` work on both platforms

- **FR-018**: Script MUST support the following applications:

  | Application | macOS Bundle ID | Linux .desktop | CLI Command | macOS Open | Linux Open |
  |-------------|-----------------|----------------|-------------|------------|------------|
  | VSCode | `com.microsoft.VSCode` | `code.desktop` | `code` | `code <path>` | `code <path>` |
  | Cursor | `com.todesktop.230313mzl4w4u92` | `cursor.desktop` | `cursor` | `cursor <path>` | `cursor <path>` |
  | Ghostty | `com.mitchellh.ghostty` | `com.mitchellh.ghostty.desktop` | `ghostty` | `open -a Ghostty <path>` | `ghostty -e "cd <path> && $SHELL"` |
  | iTerm2 | `com.googlecode.iterm2` | - | - | `open -a iTerm <path>` | - |
  | Terminal.app | `com.apple.Terminal` | - | - | `open -a Terminal <path>` | - |
  | GNOME Terminal | - | `org.gnome.Terminal.desktop` | `gnome-terminal` | - | `gnome-terminal --working-directory=<path>` |
  | Konsole | - | `org.kde.konsole.desktop` | `konsole` | - | `konsole --workdir <path>` |
  | Finder | `com.apple.finder` | - | - | `open <path>` | - |
  | Nautilus | - | `org.gnome.Nautilus.desktop` | `nautilus` | - | `nautilus <path>` |
  | Dolphin | - | `org.kde.dolphin.desktop` | `dolphin` | - | `dolphin <path>` |

- **FR-019**: Detection priority order:
  1. Check CLI command existence (`command -v`) - fastest, cross-platform
  2. macOS: Query Spotlight if CLI not found (`mdfind`)
  3. Linux: Check `.desktop` files if CLI not found

### Key Entities

- **Worktree**: An additional working tree linked to the repository, allowing parallel development on different branches
- **Worktrees Directory**: The parent directory where all worktrees for a repository are created (sibling to the main repository)
- **Branch**: The git branch associated with a worktree; either newly created or existing

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can create a new worktree in under 10 seconds using a single command
- **SC-002**: 100% of created worktrees follow the consistent naming convention
- **SC-003**: Users can immediately begin development in the new worktree without additional setup
- **SC-004**: Script provides clear feedback on success or failure with actionable error messages

## Assumptions

The following assumptions are made based on git worktree best practices:

1. **Worktree Location**: Worktrees will be created as siblings to the main repository in a directory named `<repo-name>-worktrees/`. For example, if the main repo is at `/code/myproject`, worktrees are created at `/code/myproject-worktrees/<branch-name>`. This is the recommended approach because:
   - Keeps worktrees visually separate from the main repository
   - Avoids .gitignore complications
   - Provides easy discovery and navigation
   - Groups related worktrees together

2. **Naming Convention**: Worktree directories will use random memorable names from a hardcoded list of ~50-100 city names (e.g., "prague", "tokyo", "berlin") embedded in the script, decoupled from the branch name, enabling an "explore first, name later" workflow

3. **Base Branch**: New branches will be created from the repository's default branch (detected automatically as main or master)

4. **Implementation**: Standalone POSIX-compliant shell script (`wt-create`) that can be installed to user's PATH and invoked from any terminal

5. **Cross-Platform Strategy**: Application detection uses a tiered approach:
   - **Primary**: `command -v` checks for CLI tools (POSIX-compliant, works on macOS/Linux/WSL)
   - **macOS fallback**: Spotlight queries via `mdfind` for GUI-only apps
   - **Linux fallback**: `.desktop` file checks in XDG standard locations
   - **Folder opening**: `open` (macOS) or `xdg-open` (Linux) for default file manager

## Dependencies & Follow-ups

- **Follow-up**: Enhance `/speckit.specify` to detect when running in a worktree and offer to rename the current branch (e.g., `wt/prague` → `260201-xxxx-feature-name`) to match the new spec name. This completes the "explore first, name later" workflow.

## Out of Scope

- Automatic deletion/cleanup of worktrees
- Remote worktree synchronization
- Worktree-specific environment configuration
- Deep IDE integration (e.g., VSCode extension APIs) - limited to launching editors via CLI commands
- Post-creation workflow orchestration (e.g., auto-starting Claude sessions) - script ends at access handoff
