-- Kitty scrollback pager (see scrollback_pager in kitty.conf).
-- Kitty pipes the window's scrollback, ANSI colors included, to `nvim -`.
-- It is rendered in a terminal buffer so colors survive. Lines are numbered
-- bottom-up: 1 is the line nearest the prompt box. `:30` and `30G` use those numbers.

vim.o.termguicolors = true
vim.o.number = true
vim.o.numberwidth = 5
vim.o.signcolumn = "no"
vim.o.laststatus = 0
vim.o.ruler = false
vim.o.showmode = false
vim.o.shortmess = vim.o.shortmess .. "IF"
vim.o.clipboard = "unnamedplus"
vim.o.mousescroll = "ver:6,hor:6"
vim.o.scrolloff = 4

-- Match kitty's palette, including when using a non-default config directory.
local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
local theme = io.open(config_dir .. "/current-theme.conf")
if theme then
  for line in theme:lines() do
    local n, hex = line:match("^color(%d+)%s+(#%x+)")
    if n and tonumber(n) < 16 then
      vim.g["terminal_color_" .. n] = hex
    end
  end
  theme:close()
end
vim.api.nvim_set_hl(0, "Normal", {})
vim.api.nvim_set_hl(0, "LineNr", { fg = "#565f89" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#e0af68", bold = true })

-- Last non-blank line: kitty's screen and the terminal grid can leave empty rows.
local bottom = 1
local function find_bottom()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i = #lines, 1, -1 do
    if lines[i]:find("%S") then
      bottom = i
      return true
    end
  end
  bottom = 1
  return false
end

function _G.ScrollbackNr()
  if vim.v.virtnum ~= 0 then
    return ""
  end
  local n = bottom - vim.v.lnum + 1
  return n >= 1 and tostring(n) or ""
end
local function line_for(n)
  return math.min(bottom, math.max(1, bottom - n + 1))
end

local function setup_keys(buf)
  local o = { buffer = buf, silent = true }
  vim.keymap.set("n", "q", "<Cmd>qa!<CR>", o)
  for _, k in ipairs({ "i", "I", "a", "A" }) do
    vim.keymap.set("n", k, "<Nop>", o)
  end
  -- {count}G counts from the bottom; bare G goes to the bottom.
  vim.keymap.set({ "n", "x" }, "G", function()
    local line = line_for(math.max(vim.v.count, 1)) -- read before :normal resets v:count
    vim.cmd("normal! m'")
    vim.api.nvim_win_set_cursor(0, { line, 0 })
  end, o)
  -- `:N` counts from the bottom; everything else on the command line is untouched.
  vim.keymap.set("c", "<CR>", function()
    local n = vim.fn.getcmdtype() == ":" and vim.fn.getcmdline():match("^%s*(%d+)%s*$")
    if n then
      return "<C-e><C-u>" .. line_for(tonumber(n)) .. "<CR>"
    end
    return "<CR>"
  end, { buffer = buf, expr = true })
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local src = vim.api.nvim_get_current_buf()
    local text = table.concat(vim.api.nvim_buf_get_lines(src, 0, -1, false), "\r\n")
    text = text:gsub("[%s\r\n]+$", "")

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_buf_delete(src, { force = true })
    local chan = vim.api.nvim_open_term(buf, {})
    vim.api.nvim_chan_send(chan, text)

    vim.wo.statuscolumn = "%=%{v:lua.ScrollbackNr()} "
    setup_keys(buf)
    -- The terminal renders asynchronously: wait until the buffer stops changing.
    vim.schedule(function()
      local tick, stable = -1, 0
      vim.wait(2000, function()
        local t = vim.api.nvim_buf_get_changedtick(buf)
        stable = (t == tick and find_bottom()) and stable + 1 or 0
        tick = t
        return stable >= 3 or text == ""
      end, 20)
      find_bottom()
      vim.api.nvim_win_set_cursor(0, { bottom, 0 })
      vim.cmd("normal! zb")
    end)
  end,
})
