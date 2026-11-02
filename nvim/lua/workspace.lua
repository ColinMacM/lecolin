-- Open a file straight into the working layout:
--
--   ┌──────┬───────────┬───────────┐
--   │ tree │ col 1     │ col 2     │   two scroll-linked book-mode columns
--   │      ├───────────┴───────────┤
--   │      │ terminal              │   spans the code area, not the tree
--   └──────┴───────────────────────┘
--
-- Build order matters: the columns are made first, then the terminal is spanned
-- across them, and the tree opens last so it wraps the whole thing at full
-- height. Opening the tree first would leave the terminal running underneath it.

local M = {}

M.term_height = 12


function M.open()
  local file_win = vim.api.nvim_get_current_win()

  require("bookmode").open(2)

  -- Terminal below column 1, then spanned across the whole code area.
  vim.api.nvim_set_current_win(file_win)
  vim.cmd "belowright split"
  vim.cmd "terminal"
  local term_win = vim.api.nvim_get_current_win()
  require("spanbottom").span()
  if vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_set_height(term_win, M.term_height)
  end

  -- Tree last, so it wraps the layout at full height. NvChad lazy-loads
  -- nvim-tree on NvimTreeToggle/NvimTreeFocus only, so :NvimTreeOpen does not
  -- exist yet on a cold start -- load the plugin and use its API directly.
  local ok = pcall(function()
    require("lazy").load { plugins = { "nvim-tree.lua" } }
    require("nvim-tree.api").tree.open()
  end)
  if not ok then
    vim.notify("Workspace: could not open nvim-tree", vim.log.levels.WARN)
  end

  if vim.api.nvim_win_is_valid(file_win) then
    vim.api.nvim_set_current_win(file_win)
  end
  -- Every split and resize above changed the column widths, so re-derive the
  -- book-mode offsets from the final geometry.
  require("bookmode").align()
end

-- Every file gets the layout. There is no filetype filter -- the checks below
-- only establish that you opened a single real file, which is what the layout
-- needs to make sense at all. Set vim.g.workspace_auto = false to opt out.
local function should_auto(buf)
  if vim.g.workspace_auto == false then
    return false
  end
  -- Exactly one file argument: `nvim foo.py`, not `nvim`, `nvim .`, `nvim a b`.
  if vim.fn.argc() ~= 1 then
    return false
  end
  -- Not piped input, and not an already-special buffer.
  if vim.b[buf].workspace_stdin or vim.bo[buf].buftype ~= "" then
    return false
  end
  -- A named file, not a directory (`nvim src/` should just show the tree).
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" or vim.fn.isdirectory(name) == 1 then
    return false
  end
  return true
end

function M.setup()
  vim.api.nvim_create_user_command("Workspace", M.open, {
    desc = "Open the tree + book columns + terminal layout",
  })

  local group = vim.api.nvim_create_augroup("Workspace", { clear = true })

  -- Piped input (`cat x | nvim -`) must never trigger the layout.
  vim.api.nvim_create_autocmd("StdinReadPre", {
    group = group,
    callback = function(args)
      vim.b[args.buf].workspace_stdin = true
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    nested = true, -- let NvimTreeOpen and friends fire their own autocmds
    callback = function(args)
      if should_auto(args.buf) then
        vim.schedule(M.open) -- after the UI and lazy-loaded plugins settle
      end
    end,
  })
end

return M
