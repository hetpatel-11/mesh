#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_ROOT="${HOME}/.switchboard"
BIN_DIR="${HOME}/.local/bin"
TMUX_DIR="${HOME}/.config/tmux"
MAIN_TMUX_CONF="${TMUX_DIR}/tmux.conf"
LAYER_CONF="${INSTALL_ROOT}/tmux.conf"
BRIDGE_BIN="${BIN_DIR}/switchboard"

say() {
  printf '[switchboard] %s\n' "$*"
}

ensure_tmux() {
  if command -v tmux >/dev/null 2>&1; then
    return
  fi

  say "tmux not found; installing"
  if command -v brew >/dev/null 2>&1; then
    brew install tmux
    return
  fi
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq tmux
    return
  fi
  say "could not install tmux automatically"
  exit 1
}

ensure_loader_block() {
  mkdir -p "$TMUX_DIR"
  if [[ ! -f "$MAIN_TMUX_CONF" ]]; then
    cat >"$MAIN_TMUX_CONF" <<EOF
# switchboard managed block
source-file "$LAYER_CONF"
EOF
    return
  fi

  if grep -Fq "$LAYER_CONF" "$MAIN_TMUX_CONF"; then
    return
  fi

  cat >>"$MAIN_TMUX_CONF" <<EOF

# switchboard managed block
source-file "$LAYER_CONF"
EOF
}

main() {
  ensure_tmux

  mkdir -p "$INSTALL_ROOT" "$BIN_DIR"
  install -m 0644 "$ROOT/tmux.conf" "$LAYER_CONF"
  install -m 0755 "$ROOT/bin/switchboard" "$BRIDGE_BIN"
  touch "${INSTALL_ROOT}/local.conf"
  ensure_loader_block

  say "installed managed tmux layer to $LAYER_CONF"
  say "installed bridge to $BRIDGE_BIN"
  say "local overrides live at ${INSTALL_ROOT}/local.conf"

  if tmux ls >/dev/null 2>&1; then
    tmux source-file "$MAIN_TMUX_CONF" || true
    say "reloaded tmux config"
  else
    say "tmux server not running; start tmux to pick up the config"
  fi

  say "done"
}

main "$@"
