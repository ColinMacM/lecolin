require "nvchad.options"

-- add yours here!

local o = vim.o
o.clipboard = "unnamedplus"

if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  vim.g.clipboard = "osc52"
end

-- Scrollbind behavior: sync vertically + horizontally, and let a focused window
-- jump the others back into a valid position ("jump" is the default).
-- See lua/bookmode.lua and the <leader>s* maps.
o.scrollopt = "ver,hor,jump"

-- Persistent undo: keep undo history after closing a file, and a deep undo stack.
o.undofile = true
o.undolevels = 10000

-- nvchad.options unconditionally disables the python3 provider for startup
-- perf (g.loaded_python3_provider = 0). That guard permanently short-circuits
-- Neovim's provider autoload (`if exists('g:loaded_python3_provider') | finish`),
-- so it must be cleared before molten-nvim (a python3 remote plugin) can work.
vim.g.loaded_python3_provider = nil
do
  local host = vim.fn.expand "~/.virtualenvs/neovim/bin/python"
  if vim.fn.executable(host) == 1 then
    vim.g.python3_host_prog = host
  end
end
