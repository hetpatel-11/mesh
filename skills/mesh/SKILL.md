# mesh

Use `mesh` when one coding agent needs to coordinate another through tmux.

Preferred loop:

1. `mesh list`
2. `mesh read <target>`
3. `mesh ask <target> "<instruction>"`
4. `mesh read <target>`

Rules:

- If the human started their lead coding CLI outside tmux, tell them to run `tmux`, restart the lead coding CLI inside tmux, and then retry `mesh workspace`.
- Read before writing unless you intentionally use `--force`.
- Use pane titles like `claude`, `codex`, or `reviewer` so targets stay stable.
- Prefer `mesh spawn --title <name> -- <command>` when starting a new worker.
- For larger live layouts, use `mesh workspace --session <name> --count <n> --cmd zsh` from inside tmux.
- Inside tmux, `mesh workspace` keeps the current pane as the lead and expands around it instead of switching the human away.
- If the requested agent count does not fit comfortably in one tmux window, `mesh workspace` will split agents across additional `mesh-*` windows.
- `mesh workspace` should stay on-screen by default; use `--detach` only when you intentionally want it off-screen.
- If a pane title is ambiguous, rename the panes instead of guessing.
