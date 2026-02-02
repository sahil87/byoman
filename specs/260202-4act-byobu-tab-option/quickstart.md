# Quickstart: Byobu Tab Option for wt-create

**Feature**: 260202-4act-byobu-tab-option
**Date**: 2026-02-02

## Overview

`wt-create` now offers a byobu tab option when run inside a byobu session, opening a focused tab for the new worktree and naming it with `repo + worktree`.

## Prerequisites

- byobu installed
- running inside an active byobu session
- git repository available

## Basic Usage (inside byobu)

```bash
cd /path/to/your/repo
wt-create
```

When prompted, select **Byobu tab** from the menu. The new tab opens focused at the worktree path.

## Naming Behavior

The tab name is derived from the repo name plus the worktree name to make multiple repos easy to distinguish.

## Outside Byobu

If you run `wt-create` outside a byobu session, the byobu tab option is not shown and behavior remains unchanged.
