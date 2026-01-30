# BYOMAN

A manager for byobu sessions

## Motivation

Byobu was created because tmux commands are tough to remember. Byobu simplifed the shortcuts and made tmux easier to use.
However even Byobu sufferes from some problems:
* The command line options to choose from an older Byobu session is tough to remember
* There's no central interface to manage all sessions

## What are we building

A command line program (or shell script) that shows you an interface which lists all byobu sessions.

### Session Metrics

The interface should display useful metrics for each session (all sourced directly from tmux):
* Session name
* Created time
* Last attached time
* Attached/detached status
* Number of windows
* Current running command (per pane)

### Actions

There should be an easy way to:
* Start a new session
* Attach to an existing session
* Rename a session
* Kill a session

## Design Principles

- Pure tmux wrapper - no config files or hidden state
- All session data comes directly from tmux
- Works immediately on any system with tmux installed

## Who is this for?

If you use remote sessions a lot for development and use byobu (or want to) for long running sessions, this tool is for you.
