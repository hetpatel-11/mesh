#!/usr/bin/env bash
set -euo pipefail

SCRIPT_SOURCE="${BASH_SOURCE[0]:-}"
if [[ -n "$SCRIPT_SOURCE" ]]; then
  ROOT="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
else
  ROOT="$PWD"
fi
INSTALL_ROOT="${HOME}/.mesh"
BIN_DIR="${HOME}/.local/bin"
TMUX_DIR="${HOME}/.config/tmux"
MAIN_TMUX_CONF="${TMUX_DIR}/tmux.conf"
LAYER_CONF="${INSTALL_ROOT}/tmux.conf"
BRIDGE_BIN="${BIN_DIR}/mesh"
CODEX_LAUNCHER_BIN="${BIN_DIR}/mesh-codex"
CODEX_OPEN_BIN="${BIN_DIR}/mesh-codex-open"
SKILL_DIR="${INSTALL_ROOT}/skills/mesh"
SKILL_PATH="${SKILL_DIR}/SKILL.md"
SKILL_AGENTS_DIR="${SKILL_DIR}/agents"
SKILL_OPENAI_YAML_PATH="${SKILL_AGENTS_DIR}/openai.yaml"
BASE_URL="${MESH_BASE_URL:-https://het-patel.dev/mesh}"
TMP_DIR=""
ASSET_ROOT=""

say() {
  printf '[mesh] %s\n' "$*"
}

cleanup() {
  [[ -n "$TMP_DIR" ]] && [[ -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
}

need_download_assets() {
  [[ -f "$ROOT/tmux.conf" ]] || return 0
  [[ -f "$ROOT/bin/mesh" ]] || return 0
  [[ -f "$ROOT/bin/mesh-codex" ]] || return 0
  [[ -f "$ROOT/bin/mesh-codex-open" ]] || return 0
  [[ -f "$ROOT/skills/mesh/SKILL.md" ]] || return 0
  [[ -f "$ROOT/skills/mesh/agents/openai.yaml" ]] || return 0
  return 1
}

require_curl() {
  command -v curl >/dev/null 2>&1 || {
    say "curl is required to download mesh assets from $BASE_URL"
    exit 1
  }
}

download_asset() {
  local remote_path="$1"
  local local_path="$2"
  curl -fsSL "${BASE_URL}${remote_path}" -o "$local_path"
}

prepare_assets() {
  if need_download_assets; then
    require_curl
    if [[ -z "$TMP_DIR" ]]; then
      TMP_DIR="$(mktemp -d)"
      trap cleanup EXIT
      mkdir -p "$TMP_DIR/bin" "$TMP_DIR/skills/mesh/agents"
      printf '[mesh] downloading mesh assets from %s\n' "$BASE_URL" >&2
      download_asset "/tmux.conf" "$TMP_DIR/tmux.conf"
      download_asset "/bin/mesh" "$TMP_DIR/bin/mesh"
      download_asset "/bin/mesh-codex" "$TMP_DIR/bin/mesh-codex"
      download_asset "/bin/mesh-codex-open" "$TMP_DIR/bin/mesh-codex-open"
      download_asset "/skills/mesh/SKILL.md" "$TMP_DIR/skills/mesh/SKILL.md"
      download_asset "/skills/mesh/agents/openai.yaml" "$TMP_DIR/skills/mesh/agents/openai.yaml"
    fi
    ASSET_ROOT="$TMP_DIR"
  else
    ASSET_ROOT="$ROOT"
  fi

  [[ -f "$ASSET_ROOT/tmux.conf" ]] || { say "missing asset: $ASSET_ROOT/tmux.conf"; exit 1; }
  [[ -f "$ASSET_ROOT/bin/mesh" ]] || { say "missing asset: $ASSET_ROOT/bin/mesh"; exit 1; }
  [[ -f "$ASSET_ROOT/bin/mesh-codex" ]] || { say "missing asset: $ASSET_ROOT/bin/mesh-codex"; exit 1; }
  [[ -f "$ASSET_ROOT/bin/mesh-codex-open" ]] || { say "missing asset: $ASSET_ROOT/bin/mesh-codex-open"; exit 1; }
  [[ -f "$ASSET_ROOT/skills/mesh/SKILL.md" ]] || { say "missing asset: $ASSET_ROOT/skills/mesh/SKILL.md"; exit 1; }
  [[ -f "$ASSET_ROOT/skills/mesh/agents/openai.yaml" ]] || { say "missing asset: $ASSET_ROOT/skills/mesh/agents/openai.yaml"; exit 1; }
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
# mesh managed block
source-file "$LAYER_CONF"
EOF
    return
  fi

  if grep -Fq "$LAYER_CONF" "$MAIN_TMUX_CONF"; then
    return
  fi

  cat >>"$MAIN_TMUX_CONF" <<EOF

# mesh managed block
source-file "$LAYER_CONF"
EOF
}

main() {
  ensure_tmux
  prepare_assets

  mkdir -p "$INSTALL_ROOT" "$BIN_DIR" "$SKILL_DIR" "$SKILL_AGENTS_DIR"
  mkdir -p "${INSTALL_ROOT}/logs" "${INSTALL_ROOT}/state"
  install -m 0644 "$ASSET_ROOT/tmux.conf" "$LAYER_CONF"
  install -m 0755 "$ASSET_ROOT/bin/mesh" "$BRIDGE_BIN"
  install -m 0755 "$ASSET_ROOT/bin/mesh-codex" "$CODEX_LAUNCHER_BIN"
  install -m 0755 "$ASSET_ROOT/bin/mesh-codex-open" "$CODEX_OPEN_BIN"
  install -m 0644 "$ASSET_ROOT/skills/mesh/SKILL.md" "$SKILL_PATH"
  install -m 0644 "$ASSET_ROOT/skills/mesh/agents/openai.yaml" "$SKILL_OPENAI_YAML_PATH"
  xattr -d com.apple.provenance "$BRIDGE_BIN" 2>/dev/null || true
  xattr -d com.apple.provenance "$CODEX_LAUNCHER_BIN" 2>/dev/null || true
  xattr -d com.apple.provenance "$CODEX_OPEN_BIN" 2>/dev/null || true
  touch "${INSTALL_ROOT}/local.conf"
  ensure_loader_block

  say "installed managed tmux layer to $LAYER_CONF"
  say "installed bridge to $BRIDGE_BIN"
  say "installed codex launcher to $CODEX_LAUNCHER_BIN"
  say "installed codex external launcher to $CODEX_OPEN_BIN"
  say "installed optional agent skill to $SKILL_PATH"
  say "installed agent metadata to $SKILL_OPENAI_YAML_PATH"
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
