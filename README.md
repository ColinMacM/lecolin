# lecolin

My dotfiles: Neovim (NvChad-based), kitty, and zsh (oh-my-zsh + zsh-autosuggestions).

## New machine

```sh
git clone https://github.com/ColinMacM/lecolin ~/lecolin
~/lecolin/install.sh
```

`install.sh` symlinks the configs into place and clones oh-my-zsh and zsh-autosuggestions.
Any existing file it would replace is moved to `<path>.pre-lecolin.<timestamp>`, not deleted.
It is safe to re-run.

| Repo path            | Linked to                       |
|----------------------|---------------------------------|
| `zsh/.zshrc`         | `~/.zshrc`                      |
| `nvim/`              | `~/.config/nvim`                |
| `kitty/kitty.conf`   | `~/.config/kitty/kitty.conf`    |
| `kitty/ssh.conf`     | `~/.config/kitty/ssh.conf`      |
| `bin/kitty-new-tab`  | `~/.local/bin/kitty-new-tab`    |

## Syncing

The live configs are symlinks into this repo, so edits land here directly.

```sh
cd ~/lecolin && git pull               # get changes from another machine
cd ~/lecolin && git commit -am "..." && git push   # send yours
```

Optional tools `.zshrc` uses when present: zoxide, pay-respects, miniconda/mamba at `~/Apps/miniconda3`, nvm, bun, cargo.

Note: `kitty.conf` maps `ctrl+shift+t` to `/home/colin/.local/bin/kitty-new-tab`, an absolute path, so it assumes the username `colin`.
