**This repo is supposed to be used as config by NvChad users!**

- The main nvchad repo (NvChad/NvChad) is used as a plugin by this repo.
- So you just import its modules , like `require "nvchad.options" , require "nvchad.mappings"`
- So you can delete the .git from this repo ( when you clone it locally ) or fork it :)

## Portable additions

The existing Linux plugin set and mappings are retained. `ColinMacM/omp.nvim`
installs from GitHub, opens a right split at 40% width, and uses its default
`<leader>omp` / `Ctrl+,` toggle, `<leader>os` selection send, `<leader>ob` buffer
mention, and `<leader>od` review mappings. Install the `omp` executable separately.

Rust uses `rust-analyzer` from rustup on either platform. Swift's `sourcekit-lsp`
is enabled only on macOS when its executable is available. Treesitter adds Swift,
Rust, and TOML without removing NvChad's base parsers; run `:TSInstallAll` after
installing plugins (requires the Treesitter CLI and a C compiler).

On macOS, `xcodebuild.nvim` provides `<leader>Xp` actions, `Xs` setup, `Xb` build,
`Xr` build/run, `Xd` device selection, `Xl` logs, and `Xx` cancellation. It is
disabled on Linux. Install Xcode and the plugin's external tools before building
an Apple project; run `:checkhealth xcodebuild` for the required tools.

Conform supports `rustfmt` and `swiftformat` through the existing `<leader>fm`
manual-format mapping. Install those executables separately. Save-time formatting
remains limited to Markdown (Prettier) and Python (trailing whitespace only).
The repository's Everforest theme, dashboard, custom statusline, window layouts,
and existing keymaps take precedence over the Mac starter's defaults.

The existing Rust Book/Rustonomicon integration uses the local-only checkout
`~/code/rustdocs.nvim`. It is enabled only when that directory exists; without
it, the rest of the configuration still installs and starts normally.

# Credits

1) Lazyvim starter https://github.com/LazyVim/starter as nvchad's starter was inspired by Lazyvim's . It made a lot of things easier!
