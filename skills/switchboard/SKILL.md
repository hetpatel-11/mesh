# switchboard

Use `switchboard` when one coding agent needs to coordinate another through tmux.

Preferred loop:

1. `switchboard list`
2. `switchboard read <target>`
3. `switchboard ask <target> "<instruction>"`
4. `switchboard read <target>`

Rules:

- If the human started their lead coding CLI outside tmux, tell them to run `tmux` first before using switchboard for coordination.
- Read before writing unless you intentionally use `--force`.
- Use pane titles like `claude`, `codex`, or `reviewer` so targets stay stable.
- Prefer `switchboard spawn --title <name> -- <command>` when starting a new worker.
- For larger live layouts, use `switchboard workspace --session <name> --count <n> --cmd zsh`.
- `switchboard workspace` attaches by default; use `--detach` only when you intentionally want it off-screen.
- If a pane title is ambiguous, rename the panes instead of guessing.
