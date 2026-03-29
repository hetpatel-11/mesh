# switchboard

Use `switchboard` when one coding agent needs to coordinate another through tmux.

Preferred loop:

1. `switchboard list`
2. `switchboard read <target>`
3. `switchboard ask <target> "<instruction>"`
4. `switchboard read <target>`

Rules:

- Read before writing unless you intentionally use `--force`.
- Use pane titles like `claude`, `codex`, or `reviewer` so targets stay stable.
- Prefer `switchboard spawn --title <name> -- <command>` when starting a new worker.
- If a pane title is ambiguous, rename the panes instead of guessing.

