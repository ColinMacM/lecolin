require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "rust_analyzer" }

-- SourceKit ships with Apple's toolchain; do not start it on Linux or on
-- Macs without the toolchain installed. rust-analyzer remains cross-platform.
if vim.fn.has "macunix" == 1 and vim.fn.executable "sourcekit-lsp" == 1 then
  table.insert(servers, "sourcekit")
end

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
