# lecolin

My dotfiles: Neovim (NvChad-based), kitty, zsh (oh-my-zsh + zsh-autosuggestions),
and the portable omp harness setup, with zoxide and pay-respects.

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
| omp | official binary installer, version in `omp/version` | same | install separately |

Then it links the configs:

| Repo path | Linux / macOS | Windows |
|---|---|---|
| `nvim/` | `~/.config/nvim` | `%LOCALAPPDATA%\nvim` (junction) |
| `zsh/.zshrc` | `~/.zshrc` | — |
| `kitty/kitty.conf`, `kitty/ssh.conf` | `~/.config/kitty/` | — |
| `kitty/current-theme.conf`, `kitty/scrollback.lua`, `kitty/os-macos.conf` | `~/.config/kitty/` | — |
| `omp/config.yml`, `omp/mcp.json` | `~/.omp/agent/` | — |
| each directory in `omp/skills/` | `~/.omp/agent/skills/` | — |
| `bin/kitty-new-tab` | `~/.local/bin/kitty-new-tab` | — |
| `windows/profile.ps1` | — | dot-sourced from `$PROFILE` |

Existing targets are backed up, not deleted. Most backups use
`<path>.pre-lecolin.<timestamp>`; omp skills instead move to
`~/.omp/agent/skills.pre-lecolin.<timestamp>/<name>`, outside active skill
discovery. Both installers are safe to re-run.

Neovim needs 0.11+ for `omp.nvim`. The combined plugin set keeps the existing
notebook, LeetCode, Markdown, Codex, window-management, and undo integrations,
and adds `omp.nvim`, Swift/Rust/TOML support, and macOS-only Xcode tooling.
`<leader>omp` or `Ctrl+,` toggles omp in a right-hand split. Xcode actions use
`<leader>X…`; SourceKit is enabled only on macOS when `sourcekit-lsp` is available.
Rust needs `rust-analyzer` and `rustfmt`; Swift formatting needs `swiftformat`.
The optional local RustDocs plugin loads only if `~/code/rustdocs.nvim` exists.

The existing Jupyter integration needs a separate Python environment on each machine:

```sh
python3 -m venv ~/.virtualenvs/neovim
~/.virtualenvs/neovim/bin/python -m pip install pynvim jupyter_client ipykernel jupytext pillow
~/.virtualenvs/neovim/bin/python -m ipykernel install --user --name neovim
```

Put `~/.virtualenvs/neovim/bin` on your local PATH for `jupytext`, then run
`:UpdateRemotePlugins` and restart Neovim. Notebook execution and Xcode builds
also need their project-specific environments/toolchains.

Kitty uses Tokyo Night Storm, with Cmd+arrow focus shortcuts only on macOS.
`Ctrl+Shift+H` or `Ctrl+Shift+[` opens the color-preserving Neovim scrollback
pager; `30G` or `:30` selects the 30th line from the bottom, and `q` closes it.

## Syncing

The live configs are links into this repo, so edits land here directly.

```sh
cd ~/lecolin && git pull                              # get changes
cd ~/lecolin && git commit -am "..." && git push      # send yours
```

## omp

Fresh Linux/macOS installations use the [official omp installer](https://omp.sh/docs/quickstart)
with the release in `omp/version` (currently `18.16.0`). An existing installation
is left alone, including development builds; `--no-tools` never installs a runtime.
To align a different machine explicitly:

```sh
cd ~/lecolin
curl -fsSL https://omp.sh/install | sh -s -- --binary --ref "v$(cat omp/version)"
```

The runtime owns the bundled system harness and subagents. Their exported copies
and the binary are not stored here. Shared files contain:

- Model roles, theme, composer, vim mode, and tool preferences in `omp/config.yml`.
- Browser MCP restrictions in `omp/mcp.json`; built-in browser access is disabled.
- Sixteen custom skills and their reference files in `omp/skills/`, including
  Swift, Rust style, UI design, prototyping, mobile, and animation guidance.
  The upstream Emil Kowalski MIT license is retained with its skill.

Each skill is linked individually, so unrelated installed skills are preserved.
Onboarding state and machine-local consent are not copied. Log into model
providers separately on each machine with `omp login`; shared model roles require
the corresponding provider access. Credentials, sessions, databases, caches,
SSH hosts, browser-container tooling, and Claude/Codex account settings stay local.

### peer-mail

Keep [peer-mail](https://github.com/ColinMacM/peer-mail) in its own checkout.
With [Bun](https://bun.sh/docs/installation) installed:

```sh
git clone https://github.com/ColinMacM/peer-mail.git ~/peer-mail
cd ~/peer-mail
bun install
omp plugin link "$HOME/peer-mail"
omp plugin list
```

Restart omp sessions after installing or updating the plugin. Existing linked
checkouts can stay where they are; do not clone or relink them unnecessarily.
Kitty's configured remote-control socket supports peer-mail's splits; restart
Kitty after changing the socket settings. Linux peer-mail sandboxes also require
`python3`. Mailboxes and sessions are per-machine, not synced across computers.

This repository is **public**. Live linked-file edits become Git changes:
never add tokens, account exports, private host definitions, or session data.
Review changes before committing or pushing.


## Optional, machine-specific

`.zshrc` also hooks up these tools if they exist, and skips them otherwise. The installer does not install them:
miniconda/mamba at `~/Apps/miniconda3`, bun, Rust/cargo, gh, and `~/.claude-profiles`.
