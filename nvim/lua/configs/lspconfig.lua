-- Server settings only. Nothing is started here: LSP is switched on and off
-- with `:lsp` (see lua/lsptoggle.lua), and starts OFF.

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
