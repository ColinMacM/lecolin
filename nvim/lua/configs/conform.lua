local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    markdown = { "prettier" },
    python = { "trim_whitespace" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  -- Auto-format markdown and python (trailing whitespace only) on save; others stay manual (:lua require("conform").format()).
  format_on_save = function(bufnr)
    local ft = vim.bo[bufnr].filetype
    if ft == "markdown" or ft == "python" then
      return { timeout_ms = 1000, lsp_fallback = true }
    end
  end,
}

return options
