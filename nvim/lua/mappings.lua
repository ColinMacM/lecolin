require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Ctrl+Z = undo, Ctrl+Y = redo (overrides Ctrl+Z's default "suspend nvim").
-- Native u / <C-r> still work too.
map({ "n", "v" }, "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map({ "n", "v" }, "<C-y>", "<C-r>", { desc = "Redo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Tab *pages* (whole window layouts), not the tabufline entries at the top --
-- those are buffers, closed with <leader>x. Neovim binds gt/gT/{n}gt and
-- <C-w>T by default but leaves :tabnew and :tabclose unmapped.
map("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "Tab new" })
map("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Tab close" })
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Tab close all others" })
map("n", "<leader>tt", "<C-w>T", { desc = "Tab move window to new tab" })
map("n", "<leader>t]", "<cmd>tabnext<cr>", { desc = "Tab next" })
map("n", "<leader>t[", "<cmd>tabprevious<cr>", { desc = "Tab previous" })

-- Span a window across the bottom of the code area only (logic in
-- lua/spanbottom.lua -- side panels are lifted out and restored around it).
map("n", "<leader>wj", "<cmd>SpanBottom<cr>", { desc = "Span window across bottom of code area" })

-- Book mode: columns onto the same buffer, each starting where the last ends.
-- Logic lives in lua/bookmode.lua; :BookMode / :BookModeOff / :BookAlign too.
local book = require "bookmode"

map("n", "<leader>sb", function()
  book.open(2)
end, { desc = "Book mode (2 columns)" })

map("n", "<leader>s3", function()
  book.open(3)
end, { desc = "Book mode (3 columns)" })

map("n", "<leader>sa", book.align, { desc = "Book mode re-align columns" })
map("n", "<leader>sq", book.close, { desc = "Book mode off" })

-- Plain scrollbind for the unrelated case: two *different* files side by side.
map("n", "<leader>sB", function()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      vim.wo[win].scrollbind = not vim.wo[win].scrollbind
      vim.wo[win].cursorbind = vim.wo[win].scrollbind
    end
  end
  vim.cmd "syncbind"
end, { desc = "Scrollbind toggle (all windows, zero offset)" })
