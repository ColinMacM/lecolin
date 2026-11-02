vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- nvm is lazy-loaded in .zshrc, so node's bin dir is NOT on PATH when nvim is
-- launched from a fresh shell. Prepend nvm's default-node bin so conform
-- formatters (prettier) and node-based LSP servers resolve reliably.
do
  local alias = vim.fn.expand "~/.nvm/alias/default"
  if vim.fn.filereadable(alias) == 1 then
    local ver = vim.trim(vim.fn.readfile(alias)[1] or "")
    local nodebin = vim.fn.expand("~/.nvm/versions/node/" .. ver .. "/bin")
    if ver ~= "" and vim.fn.isdirectory(nodebin) == 1 then
      vim.env.PATH = nodebin .. (vim.fn.has "win32" == 1 and ";" or ":") .. vim.env.PATH
    end
  end
end

-- Same for rustup: rust-analyzer (LSP) and rustc/cargo (rustdocs.nvim's run
-- command) live in ~/.cargo/bin, which desktop launchers don't put on PATH.
do
  local cargobin = vim.fn.expand "~/.cargo/bin"
  if vim.fn.isdirectory(cargobin) == 1 and not vim.env.PATH:find(cargobin, 1, true) then
    vim.env.PATH = cargobin .. (vim.fn.has "win32" == 1 and ";" or ":") .. vim.env.PATH
  end
end

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"
require("bookmode").setup()
require("spanbottom").setup()
require("workspace").setup()

vim.schedule(function()
  require "mappings"
end)
