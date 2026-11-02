-- Span a window across the bottom of the *code* area only.
--
-- <C-w>J always spans the full screen width, so it ends up running underneath
-- the file tree and any side terminal (Claude Code, a server log, ...) too.
-- There is no window command that stops at a panel, because the panel is a
-- sibling in the layout tree rather than a boundary.
--
-- The fix is to rebuild the layout: lift the side panels out, <C-w>J the target
-- so it spans what remains (the code windows), then re-create the panels with
-- topleft/botright splits, which wrap the whole layout again. Result:
--   row[ tree, col[ row[code1, code2], target ], terminal ]

local M = {}

-- A window is a "side panel" if it should keep its full height: the file tree,
-- or any terminal other than the one being moved.
local function panel_kind(win, target)
  if win == target or vim.api.nvim_win_get_config(win).relative ~= "" then
    return nil
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype
  if ft == "NvimTree" then
    return "tree"
  end
  if vim.bo[buf].buftype == "terminal" then
    return "terminal"
  end
  return nil
end

function M.span()
  local target = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(target).relative ~= "" then
    vim.notify("SpanBottom: not valid in a floating window", vim.log.levels.WARN)
    return
  end

  local tx = vim.api.nvim_win_get_position(target)[2]
  local tree = false
  local panels = {} -- terminals to lift out and restore

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local kind = panel_kind(win, target)
    if kind == "tree" then
      tree = true
    elseif kind == "terminal" then
      local x = vim.api.nvim_win_get_position(win)[2]
      panels[#panels + 1] = {
        buf = vim.api.nvim_win_get_buf(win),
        width = vim.api.nvim_win_get_width(win),
        x = x,
        left = x < tx,
        win = win,
      }
    end
  end

  if tree then
    vim.cmd "NvimTreeClose"
  end
  for _, p in ipairs(panels) do
    if vim.api.nvim_win_is_valid(p.win) then
      -- The window goes away; the terminal buffer (and its job) stays loaded.
      vim.api.nvim_win_close(p.win, false)
    end
  end

  if not vim.api.nvim_win_is_valid(target) then
    return
  end
  vim.api.nvim_set_current_win(target)
  vim.cmd "wincmd J"

  -- Restore panels outside the rebuilt layout. topleft/botright always span the
  -- full height, so each restored panel wraps everything created before it --
  -- hence left panels are restored right-to-left and right panels left-to-right.
  local left, right = {}, {}
  for _, p in ipairs(panels) do
    table.insert(p.left and left or right, p)
  end
  table.sort(left, function(a, b)
    return a.x > b.x
  end)
  table.sort(right, function(a, b)
    return a.x < b.x
  end)

  local function restore(list, cmd)
    for _, p in ipairs(list) do
      if vim.api.nvim_buf_is_valid(p.buf) then
        vim.cmd(cmd .. " vsplit")
        vim.api.nvim_win_set_buf(0, p.buf)
        vim.cmd("vertical resize " .. p.width)
      end
    end
  end
  restore(right, "botright")
  restore(left, "topleft")

  -- The tree goes last so it ends up outermost on the left. NvChad registers
  -- only NvimTreeToggle/NvimTreeFocus as lazy-load triggers, so :NvimTreeOpen
  -- does not exist until the plugin is loaded -- load it and use the API.
  if tree then
    pcall(function()
      require("lazy").load { plugins = { "nvim-tree.lua" } }
      require("nvim-tree.api").tree.open()
    end)
  end

  if vim.api.nvim_win_is_valid(target) then
    vim.api.nvim_set_current_win(target)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("SpanBottom", M.span, {
    desc = "Span window across the bottom of the code area, keeping side panels full height",
  })
end

return M
