return {
  {
    -- Local plugin: ~/code/rustdocs.nvim. The Rust Book and the Rustonomicon
    -- rendered inside nvim, leetcode.nvim style (chapter tree + reading pane).
    dir = "~/code/rustdocs.nvim",
    name = "rustdocs.nvim",
    -- This local-only plugin is not present on every machine.
    enabled = vim.fn.isdirectory(vim.fn.expand "~/code/rustdocs.nvim") == 1,
    -- html is what the page parser needs; rust/toml give code blocks real
    -- syntax highlighting. TSInstall (not TSUpdate) is what adds parsers on
    -- nvim-treesitter's main branch.
    build = ":TSInstall! html rust toml",
    cmd = { "RustDocs", "RustBook", "RustDarkArts" },
    -- Loaded first so its highlight queries are on the runtimepath when code
    -- blocks are rendered (the parsers alone don't ship queries).
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<leader>rb", "<cmd>RustDocs book<cr>", desc = "The Rust Book" },
      { "<leader>rn", "<cmd>RustDocs nomicon<cr>", desc = "The Rustonomicon (dark arts)" },
    },
    opts = {
      -- Scratch files live in ~/.local/share/nvim/rustdocs/playground/<book>/src/bin/<chapter>.rs,
      -- never in the repo nvim was opened from. Not /tmp: that's wiped on reboot.
      editor = { dir = vim.fn.stdpath("data") .. "/rustdocs/playground" },
      -- Ctrl+N shows the chapter tree inside the book tab (the tab's cwd is the
      -- playground, so nvim-tree there would only list Cargo files).
      -- Buffer-local, so Ctrl+N is still nvim-tree everywhere else.
      keys = { toggle_tree = { "<C-b>", "<C-n>" } },
    },
  },
}
