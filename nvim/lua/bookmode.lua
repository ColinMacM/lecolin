-- Book mode: N vertical columns onto the same buffer, each starting exactly
-- where the previous column ends, so the screen reads like newspaper columns.
--
-- Plain 'scrollbind' (:h scroll-binding) is not enough on its own:
--   * :syncbind forces a ZERO offset, which is the opposite of what we want.
--   * scrollbind scrolls the other window by the same number of *buffer* lines,
--     so with 'wrap' on the columns drift apart as soon as a line wraps.
-- We therefore keep 'scrollbind' only so that scrolling any column moves the
-- others (mouse, <C-f>, etc. all keep working), and re-derive each column's
-- topline from the previous column's last *visible* line after every scroll.

local M = {}

local WIN_VAR = "bookmode"
local busy = false -- re-entrancy guard: our own scrolling fires WinScrolled

local function is_book(win)
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return false -- floats (which-key, lazy, telescope, ...)
  end
  local ok = pcall(vim.api.nvim_win_get_var, win, WIN_VAR)
  return ok
end

-- Book columns in the current tab, in reading order. Sorted left-to-right, then
-- top-to-bottom, so the cascade still works after <C-w>K stacks the windows
-- into rows (where every window shares an x position and only y separates them).
local function columns()
  local out = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_book(win) then
      out[#out + 1] = win
    end
  end
  table.sort(out, function(a, b)
    local ay, ax = unpack(vim.api.nvim_win_get_position(a))
    local by, bx = unpack(vim.api.nvim_win_get_position(b))
    if ax ~= bx then
      return ax < bx
    end
    return ay < by
  end)
  return out
end

-- Scroll `win` so that `lnum` is the first line displayed.
local function set_topline(win, lnum)
  vim.api.nvim_win_call(win, function()
    local so = vim.wo[win].scrolloff
    vim.wo[win].scrolloff = 0 -- otherwise zt leaves 'scrolloff' lines above
    local last = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win))
    vim.api.nvim_win_set_cursor(win, { math.min(lnum, last), 0 })
    vim.cmd "normal! zt"
    vim.wo[win].scrolloff = so
  end)
end

-- First line that `win` does NOT already show, i.e. where the next column
-- should start. line("w$") would be the obvious source, but it reads a cached
-- bottom line that is not revalidated until a redraw, so it is stale exactly
-- when we need it (inside a scroll handler). nvim_win_text_height() measures
-- the wrapped height on demand instead, which is always current.
local function next_start(win)
  local top = vim.fn.line("w0", win)
  local height = vim.api.nvim_win_get_height(win)
  local ok, res = pcall(vim.api.nvim_win_text_height, win, { start_row = top - 1, max_height = height })
  if not ok or not res.end_row then
    return vim.fn.line("w$", win) + 1
  end
  local last = res.end_row + 1 -- end_row is 0-indexed
  local ok2, full = pcall(vim.api.nvim_win_text_height, win, { start_row = top - 1, end_row = res.end_row })
  if ok2 and full.all > height then
    -- That last line is clipped by the window bottom; repeat it in the next
    -- column rather than dropping the part that was never shown.
    return last
  end
  return last + 1
end

-- Re-derive every column's start from the column to its left.
function M.align()
  if busy then
    return
  end
  local wins = columns()
  if #wins < 2 then
    return
  end
  busy = true
  -- 'scrollbind' must be off while we reposition, or scrolling column i would
  -- drag column i-1 along with it and collapse the offset back to zero.
  local bound = {}
  for _, win in ipairs(wins) do
    bound[win] = vim.wo[win].scrollbind
    vim.wo[win].scrollbind = false
  end
  local ok, err = pcall(function()
    for i = 2, #wins do
      local prev, cur = wins[i - 1], wins[i]
      if vim.api.nvim_win_get_buf(prev) == vim.api.nvim_win_get_buf(cur) then
        local target = next_start(prev)
        if vim.fn.line("w0", cur) ~= target then
          set_topline(cur, target)
        end
      end
    end
  end)
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      vim.wo[win].scrollbind = bound[win]
    end
  end
  busy = false
  if not ok then
    error(err)
  end
end

-- Open `n` columns onto the current buffer (default 2).
function M.open(n)
  n = math.max(2, n or 2)
  local start = vim.api.nvim_get_current_win()
  local top = vim.fn.line("w0", start)

  -- Nothing else in this tab should be scroll-bound to us.
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      vim.wo[win].scrollbind = false
      vim.wo[win].cursorbind = false
    end
  end

  vim.api.nvim_win_set_var(start, WIN_VAR, true)
  for _ = 2, n do
    -- "rightbelow", not "botright": botright pins the new window to the far
    -- right of the whole screen, which strands unrelated windows (a terminal,
    -- a log split) in between. rightbelow splits the current window in place,
    -- so the columns always end up adjacent.
    vim.cmd "rightbelow vsplit"
    vim.api.nvim_win_set_var(vim.api.nvim_get_current_win(), WIN_VAR, true)
  end

  -- Widths are final only now, so park every column at the same line first and
  -- then cascade; doing it during the splits would use stale wrapping.
  local wins = columns()
  for _, win in ipairs(wins) do
    set_topline(win, top)
  end
  M.align()
  for _, win in ipairs(wins) do
    -- 'cursorbind' would drag the other columns' cursors into view and undo the
    -- offset, so it stays off.
    vim.wo[win].scrollbind = true
    vim.wo[win].cursorbind = false
  end
  vim.api.nvim_set_current_win(wins[1])
end

-- True when at least two columns are currently bound.
function M.active()
  return #columns() >= 2
end

-- Point every column at `buf`. The cascade only works while the columns share a
-- buffer, so opening a different file into one of them would otherwise leave
-- book mode half-broken: still bound, but no longer continuous.
function M.retarget(buf)
  local wins = columns()
  if #wins < 2 then
    return false
  end
  local changed = false
  busy = true
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_buf(win) ~= buf then
      vim.api.nvim_win_set_buf(win, buf)
      changed = true
    end
  end
  busy = false
  return changed
end

-- Leave book mode; windows stay open, they just stop being bound.
function M.close()
  for _, win in ipairs(columns()) do
    vim.wo[win].scrollbind = false
    pcall(vim.api.nvim_win_del_var, win, WIN_VAR)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("BookMode", function(opts)
    M.open(tonumber(opts.args))
  end, { nargs = "?", desc = "Open N scroll-linked columns onto this buffer" })

  vim.api.nvim_create_user_command("BookModeOff", M.close, { desc = "Leave book mode" })
  vim.api.nvim_create_user_command("BookAlign", M.align, { desc = "Re-align book columns" })

  -- Re-align after the scroll has actually been drawn, and coalesce bursts of
  -- WinScrolled into a single pass.
  local pending = false
  local group = vim.api.nvim_create_augroup("BookMode", { clear = true })
  vim.api.nvim_create_autocmd({ "WinScrolled", "WinResized", "VimResized" }, {
    group = group,
    callback = function()
      if pending or busy then
        return
      end
      pending = true
      vim.schedule(function()
        pending = false
        M.align()
      end)
    end,
  })

  -- Opening a file into one column (from the tree, telescope, :e -- anything)
  -- propagates it to the others, so book mode follows you to the new file
  -- instead of breaking.
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(args)
      if busy then
        return
      end
      local win = vim.api.nvim_get_current_win()
      if not is_book(win) or vim.api.nvim_win_get_buf(win) ~= args.buf then
        return
      end
      -- Only real file buffers; never mirror a terminal or the tree.
      if vim.bo[args.buf].buftype ~= "" or vim.bo[args.buf].filetype == "NvimTree" then
        return
      end
      if M.retarget(args.buf) then
        vim.schedule(M.align)
      end
    end,
  })
end

return M
