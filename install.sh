#!/usr/bin/env bash
# Symlink these dotfiles into place and install the zsh plugins they need.
# Safe to re-run. Anything already at a target path that is not our symlink is
# moved aside to <path>.pre-lecolin.<timestamp>, never deleted.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {  # link <source in repo> <target>
  local src="$REPO/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok       $dst"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.pre-lecolin.$STAMP"
    echo "backup   $dst -> $dst.pre-lecolin.$STAMP"
  fi
  ln -s "$src" "$dst"
  echo "linked   $dst -> $src"
}

clone() {  # clone <url> <dir>
  if [ -d "$2/.git" ]; then
    echo "ok       $2"
  else
    git clone --depth=1 "$1" "$2"
  fi
}

# zsh: oh-my-zsh + custom plugins (cloned, not vendored)
clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

link zsh/.zshrc          "$HOME/.zshrc"
link nvim                "$HOME/.config/nvim"
link kitty/kitty.conf    "$HOME/.config/kitty/kitty.conf"
link kitty/ssh.conf      "$HOME/.config/kitty/ssh.conf"
link bin/kitty-new-tab   "$HOME/.local/bin/kitty-new-tab"

echo
echo "Done. Open a new shell; nvim installs its plugins (lazy.nvim) on first launch."
