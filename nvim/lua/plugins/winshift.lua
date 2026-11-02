return {
  {
    "sindrets/winshift.nvim",
    cmd = "WinShift",
    keys = {
      -- <leader>wk / <leader>wK are NvChad's whichkey maps, so this uses ww/wx.
      { "<leader>ww", "<cmd>WinShift<cr>", desc = "Win-Move mode (hjkl to move, HJKL to far edge)" },
      { "<leader>wx", "<cmd>WinShift swap<cr>", desc = "Swap two windows" },
    },
    opts = {
      highlight_moving_win = true, -- highlight the window being moved
      focused_hl_group = "Visual",
      moving_win_options = {
        -- Turned off while moving so the moving window is visually plain.
        wrap = false,
        cursorline = false,
        cursorcolumn = false,
        colorcolumn = "",
      },
      keymaps = {
        disable_defaults = false,
        win_move_mode = {
          -- hjkl: step the window one position through the layout.
          ["h"] = "left",
          ["j"] = "down",
          ["k"] = "up",
          ["l"] = "right",
          -- Arrows: throw the window to that edge spanning the FULL width or
          -- height, collapsing it out of whatever column/row it was nested in.
          -- <down> is the one that tiles a terminal across the entire bottom.
          ["<left>"] = "far_left",
          ["<down>"] = "far_down",
          ["<up>"] = "far_up",
          ["<right>"] = "far_right",
          -- Capitals do the same as the arrows (winshift's own convention).
          ["H"] = "far_left",
          ["J"] = "far_down",
          ["K"] = "far_up",
          ["L"] = "far_right",
        },
      },
    },
  },
}
