require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "rust_analyzer" }

-- SourceKit ships with Apple's toolchain; do not start it on Linux or on
-- Macs without the toolchain installed. rust-analyzer remains cross-platform.
if vim.fn.has "macunix" == 1 and vim.fn.executable "sourcekit-lsp" == 1 then
  table.insert(servers, "sourcekit")
end

-- C / C++. clangd needs compile_commands.json to know include paths and flags:
-- CMake: -DCMAKE_EXPORT_COMPILE_COMMANDS=ON (then symlink it to the project root);
-- Make or anything else: `bear -- make`.
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders=true",
  },
})

-- Python. basedpyright resolves imports from the python on PATH, so start nvim
-- inside the env you are working in (`conda activate lerobot312 && nvim`).
-- "standard" checking: the default "recommended" mode flags most untyped ML code.
vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})

-- ruff: fast lint + quick fixes; leave hover to basedpyright.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
})

-- Installed by mason-tool-installer (plugins/ide.lua). Only enable what exists,
-- so a fresh machine doesn't error before Mason finishes; restart once after.
for name, bin in pairs { clangd = "clangd", basedpyright = "basedpyright-langserver", ruff = "ruff" } do
  if vim.fn.executable(bin) == 1 then
    table.insert(servers, name)
  end
end

vim.lsp.enable(servers)

-- Inlay hints (parameter names, inferred types), like an IDE. Toggle per buffer.
vim.keymap.set("n", "<leader>ih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 }, { bufnr = 0 })
end, { desc = "LSP toggle inlay hints" })
