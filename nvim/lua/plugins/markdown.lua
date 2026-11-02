return {
  -- Pretty in-buffer rendering: headings, bullets, checkboxes, code blocks, tables.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown", "markdown_inline" },
    opts = {
      -- Toggle rendering off in insert mode so raw markdown is editable as text.
      render_modes = { "n", "c", "t" },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
      },
    },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Markdown: toggle render" },
    },
  },

  -- Inline images via kitty graphics protocol. Uses ImageMagick `convert` (IM6)
  -- through the magick_cli processor, so no luarocks/magick rock is required.
  {
    "3rd/image.nvim",
    ft = { "markdown" },
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = true,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown" },
        },
      },
      max_width = 100,
      max_height = 12,
      max_width_window_percentage = math.huge,
      max_height_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = true,
    },
  },
}
