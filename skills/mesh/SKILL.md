---
name: mesh
description: Let Claude Code, Codex, and other terminal coding agents communicate through real tmux panes. Use when one agent needs to start or coordinate other agents, read sibling panes, send prompts across sessions, show the live workspace to the human, inspect shared repo context, or recover from blocked Codex tmux access with mesh-codex or mesh-codex-open.
---

# mesh

Use `mesh` to coordinate real tmux-backed agent sessions.

## Prefer the repo-local tools

- Prefer `./bin/mesh` over any globally installed `mesh`.
- Prefer `./bin/mesh-codex` for a fresh all-Codex workspace from a shell.
- Prefer `./bin/mesh-codex-open` on macOS when Codex is blocked from tmux socket access in its sandbox.
- If `mesh doctor` says the repo-local binary differs from the installed one, use the repo-local binary or tell the human to rerun `bash ./install.sh`.

## Default loop

1. Run `mesh list`.
2. Run `mesh context <self>`.
3. Run `mesh summary <self>`.
4. Run `mesh changes <self>`.
5. Run `mesh read <target>`.
6. Run `mesh assign <target> "<instruction>"`.
7. Run `mesh read <target>` again.

## Workspace rules

- Tell the human to start `tmux` and relaunch the lead coding CLI inside tmux if the lead was started outside tmux and the task depends on preserving that lead pane.
- Use `mesh workspace --session <name> --count <n> --cmd zsh` for larger live layouts from inside tmux.
- Expect `mesh workspace` to keep the current pane as the visible lead when it is run from inside tmux.
- Use `--detach` only when the workspace should intentionally stay off-screen.
- Use `mesh show <session>` when the workspace exists and the human needs to see it live.
- Expect `mesh workspace` to split large swarms across multiple `mesh-*` windows when one window would be too crowded.

## Read and write rules

- Read before writing unless there is a good reason to use `--force`.
- Use `mesh context <self> --lines <n>` to inspect recent sibling output before coordinating or reporting status.
- Use `mesh summary <self> --lines <n>` for a tighter per-agent status view.
- Use `mesh changes <self> --lines <n>` before starting work and again before reporting back.
- Use `mesh log <target>` when you need saved snapshot history for a pane.
- Use `mesh follow <target>` when you want to watch one worker live without changing tmux focus.
- Prefer `mesh assign <target> "<instruction>"` over raw `mesh ask` when handing work to a worker, because it includes sibling context and live repo changes.

## Worker launch rules

- Prefer `mesh spawn --title <name> -- <command>` when starting one new worker.
- Prefer `./bin/mesh-codex --count <n> --replace` for a fresh Codex-only workspace from a normal shell.
- Prefer `./bin/mesh-codex-open --count <n> --replace` from a blocked Codex sandbox on macOS.
- Use stable pane titles such as `lead`, `codex-01`, `codex-02`, `claude`, or `reviewer`.
- Rename ambiguous pane titles instead of guessing.

## Failure rules

- Do not substitute built-in subagents, delegated helper agents, or any non-tmux fallback for real mesh workers.
- Do not claim success unless a real tmux-backed mesh workspace or worker pane exists.
- Stop clearly if tmux socket access is blocked and no real workspace can be created.
- If Codex is blocked in its sandbox, try `./bin/mesh-codex-open ...` before giving up.
