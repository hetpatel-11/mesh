# switchboard

`switchboard` is a tmux wrapper for coding agents.

It is deliberately small:

- one install script
- one tmux config layer
- one bridge CLI

The goal is simple local agent coordination without relying on brittle tmux muscle memory or heavy background infrastructure.

## What It Does

- installs a managed tmux config without blowing away the whole user config
- exposes easy no-prefix tmux bindings for panes, movement, resize, and titles
- provides a shell bridge for listing panes, reading output, sending prompts, naming panes, and spawning workers
- adds a safety check so blind writes require either a recent read or an explicit `--force`

## Install

```bash
bash ./install.sh
```

That installs:

- `~/.switchboard/tmux.conf`
- `~/.local/bin/switchboard`
- a managed source block in `~/.config/tmux/tmux.conf`

Then start tmux or reload it:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

## Bridge Commands

List panes:

```bash
switchboard list
```

Read a pane before writing:

```bash
switchboard read codex --lines 80
```

Send a message and press enter:

```bash
switchboard ask codex "Implement auth middleware and reply with tests run."
```

Force a write when you know what you are doing:

```bash
switchboard ask --force codex "Continue from your last checkpoint."
```

Spawn a worker pane to the right and name it:

```bash
switchboard spawn --title codex --cwd "$PWD" --right -- codex
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

