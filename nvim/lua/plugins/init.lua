return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    opts = {},
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    lazy = true,
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        split_width_percentage = 0.15,
      },
    },
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSend",
      "ClaudeCodeStatus",
      "ClaudeCodeSelectModel",
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude Code Toggle" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude Code Focus" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude Code Send Selection" },
    },
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- Keep NvChad's base parsers alongside the Mac's language additions.
      ensure_installed = {
        "lua", "luadoc", "printf", "vim", "vimdoc",
        "swift", "rust", "toml",
      },
    },
  },
}
