return {
  {
    "johnseth97/codex.nvim",
    lazy = true,
    cmd = { "Codex", "CodexToggle" },
    keys = {
      {
        "<leader>cc",
        function()
          require("codex").toggle()
        end,
        desc = "Toggle Codex popup or side-panel",
        mode = { "n" },
      },
      {
        "<leader>cr",
        function()
          -- codex.nvim has no resume command (single-instance toggle plugin),
          -- so open `codex resume` in a right split sized like the Codex panel.
          local width = math.floor(vim.o.columns * 0.15)
          vim.cmd("botright vsplit")
          vim.api.nvim_win_set_width(0, width)
          vim.cmd("terminal codex resume")
          vim.cmd("startinsert")
        end,
        desc = "Resume a Codex conversation",
        mode = { "n" },
      },
    },
    opts = {
      keymaps = {
        toggle = nil, -- handled by the `keys` spec above
        quit = "<C-q>",
      },
      border = "rounded",
      width = 0.15, -- match claudecode's split_width_percentage (0.15)
      height = 0.8,
      model = nil, -- nil = use Codex CLI default
      autoinstall = true, -- auto `npm i -g @openai/codex` if missing
      panel = true, -- false = floating popup, true = side panel
      use_buffer = false,
    },
  },
}
