-- Language servers are OFF on purpose: no diagnostics, hover hints or
-- language-aware completion while learning. Compiler/interpreter errors still
-- show when you build or run.
--
-- To turn them back on, list servers here, e.g.
--   { "rust_analyzer", "clangd", "basedpyright", "ruff" }
-- and add their names to mason-tool-installer in plugins/ide.lua.
local servers = {}

if #servers > 0 then
  require("nvchad.configs.lspconfig").defaults()
  vim.lsp.enable(servers)
end
