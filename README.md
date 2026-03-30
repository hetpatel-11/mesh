# mesh

`mesh` is a tmux wrapper for coding agents.

It is deliberately small:

- one install script
- one tmux config layer
- one bridge CLI

The goal is simple local agent coordination without relying on brittle tmux muscle memory or heavy background infrastructure.

## What It Does

- installs a managed tmux config without blowing away the whole user config
- exposes easy no-prefix tmux bindings for panes, movement, resize, and titles
- provides a shell bridge for listing panes, reading output, sending prompts, naming panes, and spawning workers
- gives any pane a grouped sibling-context snapshot with `mesh context`
- adds a safety check so blind writes require either a recent read or an explicit `--force`

## Install

```bash
bash ./install.sh
```

That installs:

- `~/.mesh/tmux.conf`
- `~/.local/bin/mesh`
- a managed source block in `~/.config/tmux/tmux.conf`

Then start tmux or reload it:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

For lead-driven agent work, start tmux first and launch your lead coding agent inside that tmux session:

```bash
tmux
```

If you start Claude Code, Codex, or another coding CLI outside tmux, `mesh workspace` will stop and tell you to restart inside tmux instead of silently creating a hidden session.

## Bridge Commands

List panes:

```bash
mesh list
```

Resolve a target before acting on it:

```bash
mesh resolve codex
```

Read a pane before writing:

```bash
mesh read codex --lines 80
```

Pull a grouped snapshot of the other panes in the same session:

```bash
mesh context lead --lines 25
```

Workers can use the same command to stay aware of sibling agents:

```bash
mesh context codex-01 --lines 20
```

Send a message and press enter:

```bash
mesh ask codex "Implement auth middleware and reply with tests run."
```

Force a write when you know what you are doing:

```bash
mesh ask --force codex "Continue from your last checkpoint."
```

Broadcast to every live pane except your own:

```bash
mesh broadcast --force --except claude "Stand by for a new task."
```

Spawn a worker pane to the right and name it:

```bash
mesh spawn --title codex --cwd "$PWD" --right -- codex
```

Create a real multi-agent workspace in one shot from inside tmux:

```bash
mesh workspace --session agents --count 10 --cmd zsh
```

Inside tmux, `mesh workspace` keeps the current pane as the lead, leaves it on screen, and expands the workspace around it. If you want a background workspace instead:

```bash
mesh workspace --session agents --count 10 --cmd zsh --detach
```

Large workspaces spill into additional `mesh-*` windows automatically based on the current tmux window size, so `mesh` does not cram more panes into a window than the view can reasonably hold:

```bash
mesh workspace --session agents --count 24 --cmd zsh --per-window 8
```

Create a named multi-agent workspace with real commands. When you run this inside tmux, the first agent title names the current lead pane; it does not replace the lead process you already started:

```bash
mesh workspace --session agents --replace \
  --agent lead:claude \
  --agent codex-01:codex \
  --agent codex-02:codex \
  --agent reviewer:claude
```

## Targeting

Targets can be:

- a tmux pane id like `%3`
- a pane title like `codex`
- a tmux address like `session:window.pane`

If a title is ambiguous, the command fails instead of guessing.

## Default Bindings

These bindings are available without a tmux prefix:

- `Alt-Enter`: split down
- `Alt-\\`: split right
- `Alt-h/j/k/l`: move focus
- `Alt-H/J/K/L`: resize
- `Alt-r`: rename current pane
- `Alt-,`: previous window
- `Alt-.`: next window
- `Alt-z`: zoom current pane

## Why This Shape

The wrapper stays close to tmux because real coding agents already run well in terminals. The improvement is not “more infrastructure.” It is:

- safer installs
- better pane addressing
- a stronger read-before-write loop
- built-in worker spawn helpers
- a local override layer for custom tmux tweaks
- one-command workspace layouts for live multi-agent sessions of arbitrary size
- current-pane-first workspace bootstrapping so the human always keeps the lead in view
