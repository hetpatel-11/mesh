# mesh

`mesh` is a tmux wrapper for local coding-agent swarms.

The simplest way to understand it is this: `mesh` lets one coding agent talk to another through real terminal panes. For example, you can run Claude Code as the lead, open Codex workers beside it, and have Claude send work to Codex without hiding anything in the background.

That same workflow scales beyond two agents. You can use one lead agent and many workers in the same tmux workspace, keep every session visible, and let the human watch, interrupt, or type in any pane at any time. `mesh` is built for people who want multiple coding agents working on the same problem, but still want the work to stay understandable and under human control.

## Why mesh

`mesh` is not just a way to type into another pane. It is built around the real workflow people want when they use multiple coding agents together:

- one visible lead agent can coordinate the rest of the swarm without disappearing off-screen
- the human stays in the loop and can watch, interrupt, or type in any agent terminal at any time
- work can scale from one lead plus one worker to larger live workspaces spread across multiple tmux windows
- handoffs are more informed because workers can receive sibling context, session summaries, and live repo-change snapshots
- Codex, Claude Code, and other terminal coding agents can all participate, even when some environments need a launcher workaround
- worker titles are inferred from the command you launch, so a Codex workspace gets names like `codex-01` instead of generic pane labels

## What It Does

- lets Claude Code, Codex, and other terminal-based coding agents communicate through tmux-backed panes
- creates shared workspaces where one lead agent can coordinate multiple worker agents
- keeps every agent visible in real terminals so the human can watch, interrupt, and type directly into any pane
- installs a managed tmux config without blowing away the whole user config
- exposes easy no-prefix tmux bindings for panes, movement, resize, and titles
- provides a shell bridge for listing panes, reading output, sending prompts, naming panes, showing live sessions, and spawning workers
- gives any pane a grouped sibling-context snapshot with `mesh context`
- keeps clean snapshot logs so agent state can be inspected after the fact
- adds a safety check so blind writes require either a recent read or an explicit `--force`

## Demo

https://github.com/user-attachments/assets/bb58b668-06f9-4458-a10c-bf767e538d2b

## Install

The public one-line install is:

```bash
curl -fsSL https://het-patel.dev/mesh/install.sh | bash
```

If you want a coding agent to learn the mesh workflow, install the skill right after:

```bash
npx skills add hetpatel-11/mesh --skill mesh
```

If you want it to appear in Claude Code immediately, rerun `bash ./install.sh` or the one-line installer and restart Claude Code. The installer links the mesh skill into `~/.claude/skills/mesh`.

If you prefer cloning the repo first:

```bash
git clone https://github.com/hetpatel-11/mesh.git
cd mesh
bash ./install.sh
```

That installs:

- `~/.mesh/tmux.conf`
- `~/.local/bin/mesh`
- `~/.local/bin/mesh-codex`
- `~/.local/bin/mesh-codex-open`
- `~/.mesh/skills/mesh/SKILL.md`
- `~/.claude/skills/mesh` (symlink for Claude Code discovery)
- a managed source block in `~/.config/tmux/tmux.conf`

Then start tmux or reload it:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

To update:

```bash
curl -fsSL https://het-patel.dev/mesh/install.sh | bash
```

## Quick Start

For lead-driven agent work, start tmux first and launch your lead coding agent inside that tmux session:

```bash
tmux
```

Then inside that lead terminal:

```bash
mesh workspace --session agents --count 5 --cmd zsh
```

If you start Claude Code, Codex, or another coding CLI outside tmux, `mesh workspace` will try to open the new workspace in a visible Terminal window on macOS. That gets the panes on screen, but your current lead is still outside tmux. For the best lead-preserving behavior, start tmux first and launch the lead inside it.

## Codex Note

Some Codex environments can run shell commands locally but still block tmux socket creation or connection inside the Codex tool runner. When that happens, `mesh` cannot create a real tmux-backed workspace from inside that Codex session.

That is a Codex sandbox limitation, not a `mesh` protocol failure. The practical workarounds are:

- launch Codex workers from a normal tmux-backed shell with `mesh-codex`
- use `mesh-codex-open` on macOS to open the Codex mesh in Terminal.app outside the blocked sandbox
- use Claude Code or another lead agent with real tmux access to steer the rest of the swarm

So yes: Claude Code can act as the lead and coordinate Codex workers, as long as Claude is running in an environment that can access tmux normally.

## Common Flows

Create a workspace and keep the lead visible:

```bash
mesh workspace --session agents --count 10 --cmd zsh
```

Bring an existing workspace onscreen:

```bash
mesh show agents
```

Boot an all-Codex workspace:

```bash
mesh-codex --count 5 --replace
```

If Codex is sandboxed and cannot touch tmux sockets, open it outside the blocked runner:

```bash
mesh-codex-open --count 5 --replace
```

## Bridge Commands

List panes:

```bash
mesh list
```

Resolve a target before acting on it:

```bash
mesh resolve codex
```

Subcommand help works directly now:

```bash
mesh workspace --help
mesh assign --help
```

If a workspace exists but is not the visible session yet, bring it onscreen with:

```bash
mesh show agents
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

Get a tighter status-style view of sibling panes:

```bash
mesh summary lead --lines 12
```

See the live repo status and diff that every worker is sharing:

```bash
mesh changes lead --lines 20
```

Read the saved snapshot log for a pane:

```bash
mesh log codex-01 --lines 80
```

Follow a pane live without switching focus:

```bash
mesh follow codex-01 --lines 30
```

Hand a task to a worker with sibling context and live repo changes included automatically:

```bash
mesh assign codex-01 "Own auth tests. Avoid overlapping with the reviewer and report what you verified."
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

Boot an all-Codex workspace from a shell with one command:

```bash
mesh-codex --count 5 --replace
```

If a coding agent is blocked from tmux socket access in its own sandbox, use the external launcher instead. It opens Terminal.app and boots the Codex mesh there:

```bash
mesh-codex-open --count 5 --replace
```

Or name the Codex panes explicitly:

```bash
mesh-codex --session review --replace \
  --agent lead \
  --agent codex-01 \
  --agent codex-02
```

Create a real multi-agent workspace in one shot from inside tmux:

```bash
mesh workspace --session agents --count 10 --cmd zsh
```

Inside tmux, `mesh workspace` keeps the current pane as the lead, leaves it on screen, and expands the workspace around it. If you want a background workspace instead:

```bash
mesh workspace --session agents --count 10 --cmd zsh --detach
```

Outside tmux on macOS, the default non-detached behavior is to open the new session in Terminal.app so the human sees it immediately.

If an agent creates a workspace and the human should see it live, prefer `mesh show <session>` instead of printing raw tmux switching commands back to the user.

When `mesh workspace` builds workers from a command like `codex` or `claude`, it now infers worker titles from that command automatically, so you get names like `codex-01`, `codex-02`, or `claude-01` by default instead of generic `agent-*` titles.

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
- sibling summaries and saved snapshot logs so agents can stay aware of each other
- contextual worker handoffs so the lead can send tasks with live swarm and repo awareness attached

## Public Endpoints

- `https://het-patel.dev/mesh`
- `https://het-patel.dev/mesh/install.sh`
