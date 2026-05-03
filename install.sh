#!/usr/bin/env sh
set -eu

# Installer for pixi-env
# Usage:
#   curl -LsSf https://raw.githubusercontent.com/kszenes/pixi-env/main/install.sh | sh
#
# Options via env vars:
#   PIXI_ENV_INSTALL_DIR   Directory to install pixi-env into (default: ~/.local/bin)
#   PIXI_ENV_REPO          GitHub repo owner/name (default: kszenes/pixi-env)
#   PIXI_ENV_REF           Git ref/tag/branch to install from (default: main)
#   PIXI_ENV_BIN_URL       Direct URL to the pixi-env script (overrides repo/ref)

PIXI_ENV_INSTALL_DIR="${PIXI_ENV_INSTALL_DIR:-$HOME/.local/bin}"
PIXI_ENV_REPO="${PIXI_ENV_REPO:-kszenes/pixi-env}"
PIXI_ENV_REF="${PIXI_ENV_REF:-main}"
PIXI_ENV_BIN_URL="${PIXI_ENV_BIN_URL:-https://raw.githubusercontent.com/$PIXI_ENV_REPO/$PIXI_ENV_REF/bin/pixi-env}"
PIXI_ENV_BIN="$PIXI_ENV_INSTALL_DIR/pixi-env"

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
    err "need curl or wget to download pixi-env"
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
    err "Windows is not supported by pixi-env. This installer only supports Linux and macOS."
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

mkdir -p "$PIXI_ENV_INSTALL_DIR"

tmp="${TMPDIR:-/tmp}/pixi-env-install.$$"
trap 'rm -f "$tmp"' EXIT HUP INT TERM

if [ -f "./bin/pixi-env" ]; then
  cp -f "./bin/pixi-env" "$tmp"
else
  info "Downloading pixi-env from $PIXI_ENV_BIN_URL"
  download "$PIXI_ENV_BIN_URL" "$tmp"
fi

chmod +x "$tmp"
cp -f "$tmp" "$PIXI_ENV_BIN"
chmod +x "$PIXI_ENV_BIN"

info "Installed pixi-env to $PIXI_ENV_BIN"

case ":$PATH:" in
  *":$PIXI_ENV_INSTALL_DIR:"*) ;;
  *)
    warn "$PIXI_ENV_INSTALL_DIR is not in PATH"
    info "Add this to your shell config:"
    info "  export PATH=\"$PIXI_ENV_INSTALL_DIR:\$PATH\""
    ;;
esac

info ""
info "Initialize your shell so 'pixi env activate' can modify your current environment:"
info "  echo 'eval \"\$(pixi-env shell-init)\"' >> ~/.zshrc    # zsh"
info "  echo 'eval \"\$(pixi-env shell-init)\"' >> ~/.bashrc   # bash"
info ""
info "Then try:"
info "  pixi env create -n myenv mkl"
info "  pixi env activate -n myenv"
