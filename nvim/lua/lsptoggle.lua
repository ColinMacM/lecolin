-- One switch for "IDE help": language servers (diagnostics, hover, go-to-def,
-- rename) and the completion popup while typing.
--
--   :lsp              toggle on/off (also :LspToggle)
--   :lsp enable NAME  built-in subcommands still work (enable/disable/restart/stop)
--
-- Starts OFF. Set vim.g.lsp_on_start = true (before setup) to start ON.

local M = {}

-- config name -> executable. Only servers whose binary exists are started.
local servers = {
  rust_analyzer = "rust-analyzer",
  clangd = "clangd",
  basedpyright = "basedpyright-langserver",
  ruff = "ruff",
  lua_ls = "lua-language-server",
  html = "vscode-html-language-server",
  cssls = "vscode-css-language-server",
}
if vim.fn.has "macunix" == 1 then
  servers.sourcekit = "sourcekit-lsp"
end

M.on = false
local defaults_done = false

local function set_autocomplete(enabled)
  local ok, cmp = pcall(require, "cmp")
  if not ok then return end
  cmp.setup {
    completion = {
      autocomplete = enabled and { require("cmp.types").cmp.TriggerEvent.TextChanged } or false,
    },
  }
end

function M.enable()
  -- nvim-lspconfig supplies the server definitions; load it if not yet loaded.
  require("lazy").load { plugins = { "nvim-lspconfig" } }
  if not defaults_done then
    require("nvchad.configs.lspconfig").defaults() -- keymaps + diagnostic style
    defaults_done = true
  end
  local names = {}
  for name, bin in pairs(servers) do
    if vim.fn.executable(bin) == 1 then
      table.insert(names, name)
    end
  end
  table.sort(names)
  vim.lsp.enable(names, true)
  -- Attach to files that are already open, not just ones opened later.
  pcall(vim.cmd.doautoall, "nvim.lsp.enable FileType")
  set_autocomplete(true)
  M.on = true
  vim.notify("LSP on: " .. (#names > 0 and table.concat(names, ", ") or "no servers installed"))
end

function M.disable()
  vim.lsp.enable(vim.tbl_keys(servers), false)
  for _, client in ipairs(vim.lsp.get_clients()) do
    client:stop()
  end
  vim.diagnostic.reset()
  set_autocomplete(false)
  M.on = false
  vim.notify "LSP off"
end

function M.toggle()
  if M.on then M.disable() else M.enable() end
end

function M.setup()
  vim.api.nvim_create_user_command("LspToggle", function(opts)
    if opts.args ~= "" then
      vim.cmd("lsp " .. opts.args) -- pass subcommands through to the built-in :lsp
    else
      M.toggle()
    end
  end, {
    nargs = "*",
    desc = "Toggle LSP + completion popup",
    complete = function(arglead, cmdline)
      return vim.fn.getcompletion("lsp " .. cmdline:gsub("^%S+%s*", ""), "cmdline")
    end,
  })

  -- Make plain `:lsp` the toggle. The abbreviation only fires while the command
  -- line is exactly "lsp", so `:lsp enable x` becomes `:LspToggle enable x`,
  -- which forwards to the built-in command above.
  vim.cmd [[cnoreabbrev <expr> lsp (getcmdtype() ==# ':' && getcmdline() ==# 'lsp') ? 'LspToggle' : 'lsp']]

  -- The completion popup starts off via the nvim-cmp spec in plugins/ide.lua.
  if vim.g.lsp_on_start then
    vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = M.enable })
  end
end

return M
