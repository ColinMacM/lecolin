# lecolin

My dotfiles: Neovim (NvChad-based), kitty, and zsh (oh-my-zsh + zsh-autosuggestions),
with zoxide and pay-respects.

## Install

**Linux, macOS, WSL**

```sh
git clone https://github.com/ColinMacM/lecolin ~/lecolin
~/lecolin/install.sh            # add --no-tools to only create the symlinks
```

macOS needs [Homebrew](https://brew.sh) first. Linux uses apt, dnf, pacman, zypper or apk, and asks for sudo only when a system package is missing.

**Windows (native PowerShell)**

```powershell
git clone https://github.com/ColinMacM/lecolin $HOME\lecolin
powershell -ExecutionPolicy Bypass -File $HOME\lecolin\install.ps1
```

kitty and zsh don't run natively on Windows. Native Windows gets the Neovim config plus zoxide and `f` in PowerShell.
For the full zsh setup, install WSL (`wsl --install`) and run `install.sh` inside it.

## What it does

Each tool is installed only if it is missing:

| Tool | Linux | macOS | Windows |
|---|---|---|---|
| zsh, git, curl, unzip, ripgrep | package manager | brew | winget (git, ripgrep) |
| Neovim | official release tarball → `~/.local` | brew | winget |
| kitty | official installer (skipped on WSL/headless) | official installer | no Windows build |
| zoxide, pay-respects | official install scripts → `~/.local/bin` | same | winget / install.ps1 |
| node | nvm + LTS | nvm + LTS | winget Node LTS |
| oh-my-zsh, zsh-autosuggestions | git clone | git clone | — |

Then it links the configs:

| Repo path | Linux / macOS | Windows |
|---|---|---|
| `nvim/` | `~/.config/nvim` | `%LOCALAPPDATA%\nvim` (junction) |
| `zsh/.zshrc` | `~/.zshrc` | — |
| `kitty/kitty.conf`, `kitty/ssh.conf` | `~/.config/kitty/` | — |
| `bin/kitty-new-tab` | `~/.local/bin/kitty-new-tab` | — |
| `windows/profile.ps1` | — | dot-sourced from `$PROFILE` |

Any existing file in the way is renamed to `<path>.pre-lecolin.<timestamp>`, not deleted. Both installers are safe to re-run.

## Syncing

The live configs are links into this repo, so edits land here directly.

```sh
cd ~/lecolin && git pull                              # get changes
cd ~/lecolin && git commit -am "..." && git push      # send yours
```

## Optional, machine-specific

`.zshrc` also hooks up these tools if they exist, and skips them otherwise. The installer does not install them:
miniconda/mamba at `~/Apps/miniconda3`, bun, Rust/cargo, gh, and `~/.claude-profiles`.
