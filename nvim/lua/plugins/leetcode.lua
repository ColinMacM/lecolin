return {
  {
    "kawre/leetcode.nvim",
    -- The description pane is rendered from HTML. Upstream suggests
    -- ":TSUpdate html", but nvim-treesitter's main branch (what NvChad ships)
    -- only *updates* installed parsers there -- TSInstall is what adds one.
    build = ":TSInstall! html",
    -- Loading on :Leet rules out the `nvim leetcode.nvim` launch arg -- the two
    -- lazy-loading styles are mutually exclusive upstream.
    cmd = "Leet",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      -- Listed here, not left to `ft = "markdown"`, because the description split
      -- resolves image.nvim once at module load (`pcall(require, "image")` in
      -- leetcode-ui/split/description.lua) and image.nvim's API hard-errors via
      -- guard_setup() if setup() hasn't run. Depending on it makes lazy.nvim load
      -- and configure it before leetcode.nvim, so that probe always succeeds.
      "3rd/image.nvim",
    },
    keys = {
      { "<leader>lc", "<cmd>Leet<cr>", desc = "LeetCode dashboard" },
    },
    opts = {
      lang = "rust",
      picker = { provider = "telescope" },
      -- Render the description pane's diagrams inline through image.nvim's kitty
      -- backend instead of leaving bare URLs in the text.
      image_support = true,

      hooks = {
        -- Until the dashboard starts, :Leet is a no-argument bootstrap command,
        -- so subcommand mappings would error from a cold start. Bind them once
        -- we're actually inside a leetcode session.
        ["enter"] = {
          function()
            local map = vim.keymap.set
            map("n", "<leader>ll", "<cmd>Leet list<cr>", { desc = "LeetCode problem list" })
            map("n", "<leader>ld", "<cmd>Leet daily<cr>", { desc = "LeetCode daily problem" })
            map("n", "<leader>lr", "<cmd>Leet run<cr>", { desc = "LeetCode run tests" })
            map("n", "<leader>ls", "<cmd>Leet submit<cr>", { desc = "LeetCode submit" })
            map("n", "<leader>li", "<cmd>Leet info<cr>", { desc = "LeetCode question info" })
            map("n", "<leader>lq", "<cmd>Leet exit<cr>", { desc = "LeetCode exit" })
          end,
        },
      },
    },
  },
}
