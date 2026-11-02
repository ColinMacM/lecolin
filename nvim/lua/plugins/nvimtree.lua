return {
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      filters = {
        git_ignored = false, -- show git-ignored files (.env, etc.) in the tree
      },
      on_attach = function(bufnr)
        local api = require "nvim-tree.api"
        -- Keep every default tree mapping, then override the open keys below.
        api.config.mappings.default_on_attach(bufnr)

        -- In book mode the columns all show the same file, so "pick a window"
        -- is a meaningless question -- skip the picker and let bookmode mirror
        -- the file into every column.
        local function open()
          if require("bookmode").active() then
            api.node.open.no_window_picker()
          else
            api.node.open.edit()
          end
        end

        local opts = { buffer = bufnr, nowait = true, desc = "Open (no picker in book mode)" }
        vim.keymap.set("n", "<CR>", open, opts)
        vim.keymap.set("n", "o", open, opts)
        vim.keymap.set("n", "<2-LeftMouse>", open, opts)
      end,
    },
  },
}
