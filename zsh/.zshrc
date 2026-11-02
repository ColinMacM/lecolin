# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Lazy-load nvm: sourcing nvm.sh costs ~0.3s on every shell (and was previously
# done twice). Instead define stubs that load nvm on first use of a node tool.
# Trade-off: auto .nvmrc switching on `cd` won't fire until you run one of these
# once per session.
export NVM_DIR="$HOME/.nvm"
# The stub body is SELF-CONTAINED on purpose. It used to call a shared _load_nvm
# helper. Claude Code snapshots the shell's functions once per session and replays
# them into every non-interactive shell it runs; the seven stubs survived that but
# _load_nvm's definition did not, so each stub called a command that no longer
# existed, never reached its `unset -f`, and recursed into itself until zsh hit
# FUNCNEST. Inlining the loader means a stub can never outlive it.
#
# `claude` is deliberately NOT in this list: it is a native binary
# (~/.local/bin/claude -> ~/.local/share/claude/versions/*, a standalone ELF that
# links only libc) and needs nothing from node or nvm. Stubbing it forced a 0.3s
# nvm source onto every invocation for no reason.
for _cmd in nvm node npm npx yarn pnpm rea; do
  eval "${_cmd}() {
    unset -f nvm node npm npx yarn pnpm rea 2>/dev/null
    [ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"
    [ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"
    ${_cmd} \"\$@\"
  }"
done
unset _cmd
export PATH="$HOME/.local/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# Fast init: source conda.sh directly instead of `conda shell.zsh hook`, which
# spawns python (~1s) on every shell. This defines the `conda` function with no
# python spawn (~0s). Base is NOT auto-activated; use `conda activate <env>`.
if [ -f "$HOME/Apps/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/Apps/miniconda3/etc/profile.d/conda.sh"
else
    export PATH="$HOME/Apps/miniconda3/bin:$PATH"
fi
# <<< conda initialize <<<


# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE="$HOME/Apps/miniconda3/bin/mamba";
export MAMBA_ROOT_PREFIX="$HOME/Apps/miniconda3";
if [ -x "$MAMBA_EXE" ]; then
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
fi
# <<< mamba initialize <<<

# zoxide: smarter cd (`z <dir>`, `zi` for interactive). https://github.com/ajeetdsouza/zoxide
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# pay-respects: type `f` after a failed command to auto-correct it. https://github.com/iffse/pay-respects
if command -v pay-respects >/dev/null; then
eval "$(pay-respects init zsh)"
# ...but only when asked. Its init also installs a command_not_found_handler that
# auto-"corrects" and re-runs any unknown command, which can execute something
# unintended (e.g. re-running the `mv` half of `tool > f.tmp && mv f.tmp orig`).
# Drop it so a typo is just a typo; `f` and ^X^X still work.
unset -f command_not_found_handler
fi

# graphify: keep the Obsidian vault in step with the graph on every rebuild.
# `graphify update` / `graphify extract` only rewrite graphify-out/; the vault is a
# separate export step that nothing triggers on its own. scripts/graphify-sync.sh
# pairs the two for agent-driven runs and sets GRAPHIFY_SYNC=1, which this wrapper
# honours so the export never runs twice.
graphify() {
    # Repos that keep graphify output inside their vault (antivibe-robot-model):
    # point graphify at it when run from the repo root.
    if [[ -z "${GRAPHIFY_OUT:-}" && -d Knowledge-Base/graphify-out ]]; then
        GRAPHIFY_OUT=Knowledge-Base/graphify-out command graphify "$@"
    else
        command graphify "$@"
    fi
    local rc=$?
    [[ -n "${GRAPHIFY_SYNC:-}" ]] && return $rc
    [[ $rc -eq 0 ]] || return $rc
    case "${1:-}" in
        update|extract) ;;
        *) return $rc ;;
    esac

    local root="${2:-.}"
    [[ -d "$root" ]] || root="."
    [[ -f "$root/graphify-out/graph.json" ]] || return $rc

    # Prefer a vault that already exists (its manifest marks the one graphify owns),
    # otherwise fall back to the default location.
    local vault
    for vault in "$root/3D-Knowledge-Base/code-graph" "$root/Knowledge-Base/code-graph" "$root/graphify-out/obsidian"; do
        [[ -f "$vault/.graphify_obsidian_manifest.json" ]] && break
    done

    # Hard-capped like scripts/graphify-sync.sh: this fires implicitly off your own
    # `graphify update`, so it must never turn a short command into a long one. On a
    # large graph the export will not finish inside the cap — run
    # `graphify export obsidian --dir <vault>` directly for a full one. `timeout`
    # signals the whole process group, with SIGKILL 5s after SIGTERM.
    local budget="${GRAPHIFY_SYNC_TIMEOUT:-30}"
    if ! [[ "$budget" =~ ^[0-9]+$ ]] || (( budget < 1 || budget > 30 )); then
        budget=30
    fi
    # timeout(1) needs a real executable, not the `command` builtin.
    local bin
    bin="$(whence -p graphify)" || return $rc
    timeout --kill-after=5s "${budget}s" \
        "$bin" export obsidian --graph "$root/graphify-out/graph.json" --dir "$vault"
    local erc=$?
    if (( erc == 124 || erc == 137 )); then
        print -u2 "graphify: Obsidian export exceeded the ${budget}s cap and was killed; vault may be stale"
    fi
    return $rc
}

# Claude Code account profiles: `cc` to pick/launch, `claude-profile` to manage.
[ -f "$HOME/.claude-profiles/shell.zsh" ] && . "$HOME/.claude-profiles/shell.zsh"
# alias vim=nvim   # removed: real vim installed (vim.gtk3)

# Rust toolchain (rustup): puts rustc, cargo, rust-analyzer on PATH.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# GitHub MCP plugin for Claude Code (reuses gh CLI login)
export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token 2>/dev/null)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
