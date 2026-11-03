#!/usr/bin/env bash
# Linux, macOS and WSL installer. (Native Windows: run install.ps1 instead.)
#
# 1. Installs the tools these configs use, only if missing: zsh, git, curl,
#    ripgrep, unzip, neovim, kitty, zoxide, pay-respects, nvm + node LTS,
#    oh-my-zsh, zsh-autosuggestions, omp.
# 2. Symlinks the configs into place.
#
# Safe to re-run. Anything already at a target path that is not our symlink is
# moved aside to <path>.pre-lecolin.<timestamp>, never deleted.
#   --no-tools   only create the symlinks
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"          # Linux | Darwin
ARCH="$(uname -m)"        # x86_64 | aarch64 | arm64
IS_WSL=0; grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=1
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:$PATH"

have() { command -v "$1" >/dev/null 2>&1; }
say()  { printf '%-8s %s\n' "$1" "$2"; }

link() {  # link <source in repo> <target> [backup path]
  local src="$REPO/$1" dst="$2" backup="${3:-$2.pre-lecolin.$STAMP}"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    say ok "$dst"; return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$(dirname "$backup")"
    mv "$dst" "$backup"
    say backup "$dst -> $backup"
  fi
  ln -s "$src" "$dst"
  say linked "$dst -> $src"
}

clone() {  # clone <url> <dir>
  if [ -d "$2/.git" ]; then say ok "$2"; else git clone --depth=1 "$1" "$2"; fi
}

# System packages via whatever package manager this machine has.
pkg_install() {
  [ $# -eq 0 ] && return
  if [ "$OS" = Darwin ]; then
    have brew || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
    brew install "$@"
  elif have apt-get; then sudo apt-get update -qq && sudo apt-get install -y "$@"
  elif have dnf;     then sudo dnf install -y "$@"
  elif have pacman;  then sudo pacman -S --needed --noconfirm "$@"
  elif have zypper;  then sudo zypper install -y "$@"
  elif have apk;     then sudo apk add "$@"
  else echo "No known package manager; please install: $*"; exit 1
  fi
}

install_tools() {
  local want=() t
  for t in zsh git curl unzip; do have "$t" || want+=("$t"); done
  have rg || want+=(ripgrep)
  [ ${#want[@]} -gt 0 ] && pkg_install "${want[@]}"

  # Neovim: distro packages are often too old for omp.nvim (needs >= 0.11),
  # so use the official release build.
  if ! have nvim; then
    if [ "$OS" = Darwin ]; then
      brew install neovim
    else
      local a=x86_64; [ "$ARCH" = aarch64 ] || [ "$ARCH" = arm64 ] && a=arm64
      curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$a.tar.gz" \
        | tar -xz -C "$HOME/.local"
      ln -sf "$HOME/.local/nvim-linux-$a/bin/nvim" "$LOCAL_BIN/nvim"
    fi
  else say ok nvim; fi

  # kitty: skip on WSL / headless boxes (use it from the desktop OS instead).
  if ! have kitty && ! [ -d /Applications/kitty.app ]; then
    if [ "$OS" = Darwin ] || { [ $IS_WSL = 0 ] && [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; }; then
      curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
      if [ "$OS" = Linux ]; then
        ln -sf "$HOME/.local/kitty.app/bin/kitty"  "$LOCAL_BIN/kitty"
        ln -sf "$HOME/.local/kitty.app/bin/kitten" "$LOCAL_BIN/kitten"
      fi
    else say skip "kitty (no desktop session)"; fi
  else say ok kitty; fi

  if have zoxide; then say ok zoxide; else curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; fi
  if have pay-respects; then say ok pay-respects; else curl -fsSL https://raw.githubusercontent.com/iffse/pay-respects/main/install.sh | sh; fi

  # Use the recorded harness version on fresh machines; do not replace an
  # existing omp installation (which may be a development build).
  if have omp; then
    say ok "omp ($(omp --version))"
  else
    local omp_version
    read -r omp_version < "$REPO/omp/version"
    curl -fsSL https://omp.sh/install | sh -s -- --binary --ref "v$omp_version"
  fi

  # nvm + node: nvim needs node for prettier, tree-sitter and node-based LSPs.
  if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
    PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh)"
    # shellcheck disable=SC1091
    . "$HOME/.nvm/nvm.sh" && nvm install --lts && nvm alias default 'lts/*'
  else say ok nvm; fi

  clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  clone https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
}

[ "${1:-}" = --no-tools ] || install_tools

link zsh/.zshrc          "$HOME/.zshrc"
link nvim                "$HOME/.config/nvim"
link kitty/kitty.conf    "$HOME/.config/kitty/kitty.conf"
link kitty/ssh.conf      "$HOME/.config/kitty/ssh.conf"
link kitty/current-theme.conf "$HOME/.config/kitty/current-theme.conf"
link kitty/scrollback.lua     "$HOME/.config/kitty/scrollback.lua"
link kitty/os-macos.conf      "$HOME/.config/kitty/os-macos.conf"
link bin/kitty-new-tab   "$LOCAL_BIN/kitty-new-tab"
link omp/config.yml     "$HOME/.omp/agent/config.yml"
link omp/mcp.json       "$HOME/.omp/agent/mcp.json"
for skill in "$REPO"/omp/skills/*; do
  [ -d "$skill" ] || continue
  name="$(basename "$skill")"
  # Keep backup SKILL.md files outside the active discovery directory.
  link "omp/skills/$name" "$HOME/.omp/agent/skills/$name" \
    "$HOME/.omp/agent/skills.pre-lecolin.$STAMP/$name"
done

echo
if [ "$(basename "${SHELL:-}")" != zsh ]; then
  echo "Your login shell is ${SHELL:-unknown}. Make zsh the default with:"
  echo "  chsh -s \"$(command -v zsh)\""
fi
echo "Done. Open a new shell; nvim installs its plugins on first launch."
