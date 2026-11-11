# lecolin

My dotfiles: Neovim (NvChad-based), kitty, zsh (oh-my-zsh + zsh-autosuggestions),
herdr (a patched build with its themes, keys and plugins), and the portable omp
harness setup, with zoxide and pay-respects.

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
| zsh, git, curl, unzip, jq, ripgrep | package manager | brew | winget (git, ripgrep) |
| Neovim | official release tarball → `~/.local` | brew | winget |
| kitty | official installer (skipped on WSL/headless) | official installer | no Windows build |
| zoxide, pay-respects | official install scripts → `~/.local/bin` | same | winget / install.ps1 |
| node | nvm + LTS | nvm + LTS | winget Node LTS |
| oh-my-zsh, zsh-autosuggestions | git clone | git clone | — |
| omp | official binary installer, version in `omp/version` | same | install separately |
| bun, uv | official installers (they don't edit `.zshrc`) | same | — |
| herdr | upstream source at `herdr/version` + `herdr/patches`, built with cargo (rustup if missing) | same | — |

Then it links the configs:

| Repo path | Linux / macOS | Windows |
|---|---|---|
| `nvim/` | `~/.config/nvim` | `%LOCALAPPDATA%\nvim` (junction) |
| `zsh/.zshrc` | `~/.zshrc` | — |
| `kitty/kitty.conf`, `kitty/ssh.conf` | `~/.config/kitty/` | — |
| `kitty/current-theme.conf`, `kitty/scrollback.lua`, `kitty/os-macos.conf` | `~/.config/kitty/` | — |
| `kitty/herdr_tab.py`, `kitty/herdr-themes/` | `~/.config/kitty/` | — |
| `herdr/config.toml`, `herdr/theme-overrides/` | `~/.config/herdr/` | — |
| `herdr/plugins/structupath.swarm/presets.conf` | `~/.config/herdr/plugins/config/structupath.swarm/` | — |
| `omp/config.yml`, `omp/mcp.json` | `~/.omp/agent/` | — |
| each directory in `omp/skills/` | `~/.omp/agent/skills/` | — |
| `bin/herdr-smart-split`, `bin/herdr-theme`, `bin/herdr-collie-themes` | `~/.local/bin/` | — |
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
Text is JetBrains Mono with FiraCode Nerd Font Mono for icons; install both
fonts on each machine (kitty falls back to its default font otherwise).
`kitten themes` writes the theme into `kitty.conf`; if a switch replaces the
link with a plain file, copy it back into the repo and rerun `install.sh --no-tools`.

## herdr

herdr runs as a patched build: upstream [herdr](https://github.com/ogulcancelik/herdr)
at the release in `herdr/version` with the commits in `herdr/patches` (sidebar on
the left edge, rounded corners and pill tabs, the icon sidebar token, pane border
theme tokens, and Delete closing the highlighted workspace in navigate mode). On a
machine without herdr, `install.sh` clones it to `~/Apps/herdr`, applies the
patches on branch `colin/ui-fork` and runs `cargo install`. An existing herdr or
checkout is left alone. To rebuild one, or to update the patches after changing
the fork:

```sh
cargo install --locked --path ~/Apps/herdr                        # rebuild
rm ~/lecolin/herdr/patches/*.patch && \
  git -C ~/Apps/herdr format-patch "v$(cat ~/lecolin/herdr/version)..colin/ui-fork" \
    -o ~/lecolin/herdr/patches                                     # export the fork
```

Moving to a newer herdr release means rebasing `colin/ui-fork` onto its tag,
exporting the patches again and updating `herdr/version`.

`herdr/config.toml` holds the keys (prefix+arrows/hjkl between panes, vim keys in
navigate mode), the sidebar layout and two custom commands from `bin/`:

- `herdr-smart-split` (`Ctrl+Alt+Enter` or prefix+Enter) splits the focused pane
  along its longer side. It needs `jq`.
- `herdr-theme` (prefix+t cycles; `herdr-theme <name>` picks) sets herdr's theme in
  `config.toml` and gives only the kitty window herdr runs in the matching colors:
  `kitty/herdr_tab.py`, a kitty watcher, applies them when herdr starts in a window
  and restores kitty's theme when it exits. Themes with a file in
  `herdr/theme-overrides/` (whitby, apple, the Collie themes) layer that palette
  over a built-in one; their kitty colors are in `kitty/herdr-themes/`.
  `herdr-collie-themes` turns Collie themes into such pairs.

Theme switches rewrite the linked `herdr/config.toml`, so they show up as Git changes.

`install.sh` also installs herdr's omp integration (`herdr integration install omp`,
which writes its own extension into `~/.omp/agent/extensions/`) and two herdr
plugins: [Collie](https://github.com/AltanS/collie) (phone web UI over Tailscale)
and [herdr-swarm](https://github.com/StructuPath/herdr-swarm), whose agent presets
are in `herdr/plugins/structupath.swarm/presets.conf`. Collie still needs Tailscale
and pairing on each machine; its `.env` and Tailscale handler stay local.

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
With [Bun](https://bun.sh/docs/installation) and uv installed:

```sh
git clone https://github.com/ColinMacM/peer-mail.git ~/peer-mail
cd ~/peer-mail
bun install
(cd view && uv sync)                 # the swarm view
omp plugin link "$HOME/peer-mail"
herdr plugin link "$HOME/peer-mail"  # the swarm view pane
omp plugin list
```

Restart omp sessions after installing or updating the plugin. Existing linked
checkouts can stay where they are; do not clone or relink them unnecessarily.
Kitty's configured remote-control socket supports peer-mail's splits; restart
Kitty after changing the socket settings. A hub running inside herdr spawns its
agents into a herdr workspace instead and opens the swarm view beside itself.
Linux peer-mail sandboxes also require `python3`. Mailboxes and sessions are
per-machine, not synced across computers.

This repository is **public**. Live linked-file edits become Git changes:
never add tokens, account exports, private host definitions, or session data.
Review changes before committing or pushing.


## Optional, machine-specific

`.zshrc` also hooks up these tools if they exist, and skips them otherwise. The installer does not install them:
miniconda/mamba at `~/Apps/miniconda3`, bun, Rust/cargo, gh, and `~/.claude-profiles`.
