# mesh

Use `mesh` when one coding agent needs to coordinate another through tmux.

Tool selection:

- If the current repo contains `./bin/mesh`, prefer that exact binary over a globally installed `mesh`.
- If the current repo contains `./bin/mesh-codex`, prefer that launcher for a fresh all-Codex workspace from a shell.
- If `mesh doctor` says the repo-local binary differs from the installed one, use `./bin/mesh` or tell the human to run `bash ./install.sh`.

Preferred loop:

1. `mesh list`
2. `mesh context <self>`
3. `mesh summary <self>`
4. `mesh changes <self>`
5. `mesh read <target>`
6. `mesh assign <target> "<instruction>"`
7. `mesh read <target>`

Rules:

- If the human started their lead coding CLI outside tmux, prefer telling them to run `tmux`, restart the lead coding CLI inside tmux, and then retry `mesh workspace`.
- Do not substitute built-in subagents, delegated helper agents, or any non-tmux fallback for real mesh workers. If tmux socket access is blocked or mesh cannot create a real workspace, say that clearly and stop.
- Do not claim success unless a real tmux-backed mesh workspace or worker pane actually exists.
- Read before writing unless you intentionally use `--force`.
- Use `mesh context <self> --lines <n>` to pull recent output from sibling panes before coordinating or reporting status.
- Use `mesh summary <self> --lines <n>` when you want a quicker per-agent status view instead of a full pane dump.
- Use `mesh changes <self> --lines <n>` to inspect the live shared repo state before starting work and again before reporting back.
- Use `mesh log <target>` if you need the saved snapshot history for a pane, and `mesh follow <target>` when you want to watch one worker live without changing tmux focus.
- When the lead hands off work, prefer `mesh assign <target> "<instruction>"` instead of raw `mesh ask` so the worker receives sibling context and live repo changes with the assignment.
- Use pane titles like `claude`, `codex`, or `reviewer` so targets stay stable.
- Prefer `mesh spawn --title <name> -- <command>` when starting a new worker.
- For a fresh Codex-only workspace from a shell, prefer `./bin/mesh-codex --count <n> --replace` instead of synthesizing the command yourself.
- For larger live layouts, use `mesh workspace --session <name> --count <n> --cmd zsh` from inside tmux.
- Inside tmux, `mesh workspace` keeps the current pane as the lead and expands around it instead of switching the human away.
- Outside tmux on macOS, `mesh workspace` opens the new session in Terminal.app by default so the panes are visible, but that does not preserve the current lead session.
- If the requested agent count does not fit comfortably in one tmux window, `mesh workspace` will split agents across additional `mesh-*` windows.
- `mesh workspace` should stay on-screen by default; use `--detach` only when you intentionally want it off-screen.
- If a pane title is ambiguous, rename the panes instead of guessing.
