-- Jupyter notebooks in Neovim.
--
--   molten-nvim           : runs cells against a live Jupyter kernel, shows output inline
--   jupytext.nvim         : opens/saves .ipynb as a plain `# %%`-delimited python buffer
--   image.nvim            : renders plots inline (kitty backend) — already configured in
--                           markdown.lua; molten pulls it in as a dependency so it loads here too.
--   NotebookNavigator.nvim: VSCode-style cell UX on top of molten — `]h`/`[h` to jump between
--                           `# %%` cells, <leader>jc/<leader>jC to run them without manually
--                           selecting cell bounds. mini.hipatterns highlights the `# %%` marker
--                           lines themselves so cells are visually separated even before running.
--
-- Prereqs (already set up): the python host at ~/.virtualenvs/neovim has pynvim +
-- jupyter_client (see options.lua -> g.python3_host_prog), and a "neovim" kernel
-- is registered. Run a cell with <leader>je after :MoltenInit.
return {
  {
    "benlubas/molten-nvim",
    version = "^1", -- pin to the 1.x line; later majors may change the plugin host API
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    ft = { "python", "markdown", "julia", "r", "quarto" },
    -- No `cmd = {...}` here: Molten's commands (MoltenInit, etc.) are remote-plugin
    -- commands defined once, globally, by Neovim's rplugin.vim manifest at startup —
    -- not by anything lazy.nvim sources. If `cmd` is set, lazy.nvim creates its own
    -- placeholder stubs for those names, then deletes them (thinking they're its own
    -- stubs) the moment the `ft` trigger fires and "loads" the plugin, permanently
    -- wiping the real commands. `ft` alone is enough to run init()/config() on time.
    init = function()
      -- Render images/plots through image.nvim (kitty graphics protocol).
      vim.g.molten_image_provider = "image.nvim"
      -- Show output as virtual text under the cell rather than only in a float.
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_output_win_max_height = 20
    end,
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Molten: init kernel" },
      { "<leader>je", "<cmd>MoltenEvaluateOperator<cr>", desc = "Molten: evaluate operator" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Molten: evaluate line" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten: re-evaluate cell" },
      { "<leader>jv", "<cmd>MoltenEvaluateVisual<cr>", mode = "v", desc = "Molten: evaluate selection" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Molten: show output" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Molten: hide output" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Molten: delete cell" },
      { "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Molten: interrupt kernel" },
      { "<leader>jR", "<cmd>MoltenRestart<cr>", desc = "Molten: restart kernel" },
    },
  },

  {
    "GCBallesteros/jupytext.nvim",
    lazy = false, -- must register its BufReadCmd before any .ipynb is opened
    opts = {
      style = "percent", -- edit notebooks as python with `# %%` cell markers
      output_extension = "auto",
      force_ft = nil,
    },
  },

  {
    "GCBallesteros/NotebookNavigator.nvim",
    ft = { "python", "quarto", "markdown" },
    dependencies = {
      "echasnovski/mini.comment", -- cell commenting; molten already covers execution
    },
    opts = {
      repl_provider = "molten", -- use molten-nvim, not iron/toggleterm
    },
    keys = {
      { "]h", function() require("notebook-navigator").move_cell "d" end, desc = "Notebook: next cell" },
      { "[h", function() require("notebook-navigator").move_cell "u" end, desc = "Notebook: prev cell" },
      { "<leader>jc", function() require("notebook-navigator").run_cell() end, desc = "Notebook: run cell" },
      { "<leader>jC", function() require("notebook-navigator").run_and_move() end, desc = "Notebook: run cell + move" },
    },
  },

  {
    "echasnovski/mini.hipatterns",
    ft = { "python", "quarto", "markdown" },
    opts = function()
      local nn = require "notebook-navigator"
      return { highlighters = { cells = nn.minihipatterns_spec } }
    end,
  },
}
