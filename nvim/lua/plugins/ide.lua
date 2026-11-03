-- Debugger, language-server binaries, and the "LSP off by default" settings.
--
-- Mason installs the tools below into stdpath("data")/mason on Linux, macOS and
-- Windows; NvChad already puts mason/bin on nvim's PATH.
--
-- Debugging (nvim-dap):
--   Python      debugpy; the program runs with the active conda env / venv
--               (dap-python reads CONDA_PREFIX / VIRTUAL_ENV).
--   C, C++, Rust codelldb; build with debug info first (cmake -DCMAKE_BUILD_TYPE=Debug,
--               cargo build).
--   Remote      run `python -m debugpy --listen 0.0.0.0:5678 --wait-for-client x.py`
--               on the robot, then F5 -> "Attach remote" with its tailscale name.

local function mason_path(...)
  return table.concat({ vim.fn.stdpath "data", "mason", ... }, "/")
end

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      -- Language servers are installed but only start after `:lsp` (lua/lsptoggle.lua).
      ensure_installed = {
        "clangd", "clang-format", -- C / C++
        "basedpyright", "ruff",   -- Python
        "debugpy",      -- Python debugger
        "codelldb",     -- C / C++ / Rust debugger
      },
      run_on_start = true,
    },
  },

  -- No completion popup while typing until `:lsp` turns it on.
  -- Ctrl+Space opens it on demand either way.
  {
    "hrsh7th/nvim-cmp",
    opts = { completion = { autocomplete = false } },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: start / continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input "Condition: ") end,
        desc = "Debug: conditional breakpoint",
      },
      {
        "<leader>dl",
        function() require("dap").set_breakpoint(nil, nil, vim.fn.input "Log message: ") end,
        desc = "Debug: log point",
      },
      { "<leader>dc", function() require("dap").run_to_cursor() end, desc = "Debug: run to cursor" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: REPL" },
      { "<leader>dL", function() require("dap").run_last() end, desc = "Debug: run last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Debug: terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Debug: evaluate" },
      {
        "<leader>dm",
        function() require("dap-python").test_method() end,
        ft = "python",
        desc = "Debug: python test under cursor",
      },
    },
    config = function()
      local dap, dapui = require "dap", require "dapui"

      dapui.setup()
      require("nvim-dap-virtual-text").setup {}
      dap.listeners.after.event_initialized.dapui = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui = function() dapui.close() end
      dap.listeners.before.event_exited.dapui = function() dapui.close() end

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

      -- Python: debugpy runs from Mason's venv; the debuggee uses the active env.
      local win = vim.fn.has "win32" == 1
      local debugpy = mason_path("packages", "debugpy", "venv", win and "Scripts/python.exe" or "bin/python")
      require("dap-python").setup(vim.fn.executable(debugpy) == 1 and debugpy or "python3")
      table.insert(dap.configurations.python, {
        type = "python",
        request = "attach",
        name = "Attach remote (debugpy --listen)",
        connect = function()
          return {
            host = vim.fn.input("Host: ", "127.0.0.1"),
            port = tonumber(vim.fn.input("Port: ", "5678")),
          }
        end,
        pathMappings = function()
          return { {
            localRoot = vim.fn.getcwd(),
            remoteRoot = vim.fn.input("Remote project dir: ", vim.fn.getcwd()),
          } }
        end,
      })

      -- C / C++ / Rust: codelldb.
      dap.adapters.codelldb = {
        type = "executable",
        command = vim.fn.exepath "codelldb" ~= "" and vim.fn.exepath "codelldb" or "codelldb",
      }
      local function pick_program(default_dir)
        return function()
          return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/" .. default_dir, "file")
        end
      end
      local function args()
        local a = vim.fn.input "Args: "
        return a == "" and {} or vim.split(a, " ", { trimempty = true })
      end
      for _, lang in ipairs { "c", "cpp" } do
        dap.configurations[lang] = {
          {
            name = "Launch executable",
            type = "codelldb",
            request = "launch",
            program = pick_program "build/",
            args = args,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
          {
            name = "Attach to process",
            type = "codelldb",
            request = "attach",
            pid = require("dap.utils").pick_process,
          },
        }
      end
      dap.configurations.rust = {
        {
          name = "Launch cargo binary",
          type = "codelldb",
          request = "launch",
          program = pick_program "target/debug/",
          args = args,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
        },
      }
    end,
  },
}
