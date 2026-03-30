# mesh

Use `mesh` when one coding agent needs to coordinate another through tmux.

Preferred loop:

1. `mesh list`
2. `mesh read <target>`
3. `mesh ask <target> "<instruction>"`
4. `mesh read <target>`

Rules:

- If the human started their lead coding CLI outside tmux, tell them to run `tmux` first before using mesh for coordination.
- Read before writing unless you intentionally use `--force`.
- Use pane titles like `claude`, `codex`, or `reviewer` so targets stay stable.
- Prefer `mesh spawn --title <name> -- <command>` when starting a new worker.
- For larger live layouts, use `mesh workspace --session <name> --count <n> --cmd zsh`.
- `mesh workspace` attaches by default; use `--detach` only when you intentionally want it off-screen.
- If a pane title is ambiguous, rename the panes instead of guessing.
