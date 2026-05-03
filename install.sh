#!/usr/bin/env sh
set -eu

# Installer for pg (pixi-global-env)
# Usage:
#   curl -LsSf https://raw.githubusercontent.com/kszenes/pixi-global-env/main/install.sh | sh
#
# Options via env vars:
#   PG_INSTALL_DIR   Directory to install pg into (default: ~/.local/bin)
#   PG_REPO          GitHub repo owner/name (default: kszenes/pixi-global-env)
#   PG_REF           Git ref/tag/branch to install from (default: main)
#   PG_BIN_URL       Direct URL to the pg script (overrides PG_REPO/PG_REF)

PG_INSTALL_DIR="${PG_INSTALL_DIR:-$HOME/.local/bin}"
PG_REPO="${PG_REPO:-kszenes/pixi-global-env}"
PG_REF="${PG_REF:-main}"
PG_BIN_URL="${PG_BIN_URL:-https://raw.githubusercontent.com/$PG_REPO/$PG_REF/bin/pg}"
PG_BIN="$PG_INSTALL_DIR/pg"

info() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
err() { printf 'error: %s\n' "$*" >&2; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

download() {
  url="$1"
  dest="$2"
  if need_cmd curl; then
    curl -LsSf "$url" -o "$dest"
  elif need_cmd wget; then
    wget -q "$url" -O "$dest"
  else
    err "need curl or wget to download pg"
    exit 1
  fi
}

install_pixi() {
  if ! need_cmd curl; then
    err "pixi is not installed, and curl is required to install it automatically"
    exit 1
  fi

  info "pixi was not found in PATH; installing pixi..."
  curl -fsSL https://pixi.sh/install.sh | sh

  # Make pixi available to the rest of this install script when the installer
  # placed it in the default location but the user's shell has not reloaded yet.
  if [ -x "$HOME/.pixi/bin/pixi" ]; then
    PATH="$HOME/.pixi/bin:$PATH"
    export PATH
  fi

  if ! need_cmd pixi; then
    err "pixi installation completed, but pixi is still not available in PATH"
    err "restart your shell or add ~/.pixi/bin to PATH, then rerun this installer"
    exit 1
  fi
}

case "$(uname -s 2>/dev/null || printf unknown)" in
  Linux|Darwin) ;;
  CYGWIN*|MINGW*|MSYS*)
    err "Windows is not supported by pg. This installer only supports Linux and macOS."
    exit 1
    ;;
  *)
    err "unsupported OS. This installer only supports Linux and macOS."
    exit 1
    ;;
esac

if ! need_cmd pixi; then
  install_pixi
fi

mkdir -p "$PG_INSTALL_DIR"

tmp="${TMPDIR:-/tmp}/pg-install.$$"
trap 'rm -f "$tmp"' EXIT HUP INT TERM

# If run from a checked-out repository, prefer the local bin/pg.
# If run through `curl ... | sh`, download bin/pg from GitHub.
if [ -f "./bin/pg" ]; then
  cp -f "./bin/pg" "$tmp"
else
  info "Downloading pg from $PG_BIN_URL"
  download "$PG_BIN_URL" "$tmp"
fi

chmod +x "$tmp"
cp -f "$tmp" "$PG_BIN"
chmod +x "$PG_BIN"

info "Installed pg to $PG_BIN"

case ":$PATH:" in
  *":$PG_INSTALL_DIR:"*) ;;
  *)
    warn "$PG_INSTALL_DIR is not in PATH"
    info "Add this to your shell config:"
    info "  export PATH=\"$PG_INSTALL_DIR:\$PATH\""
    ;;
esac

info ""
info "Initialize your shell so 'pg activate' and 'pg deactivate' can modify your current environment:"
info "  eval \"\$(pg shell-init)\""
info ""
info "To make this permanent, add it to your shell config:"
info "  echo 'eval \"\$(pg shell-init)\"' >> ~/.zshrc    # zsh"
info "  echo 'eval \"\$(pg shell-init)\"' >> ~/.bashrc   # bash"
info ""
info "Then restart your shell, or run this now:"
info "  eval \"\$(pg shell-init)\""
info ""
info "Then try:"
info "  pg create -n qc python"
info "  pg activate -n qc"
