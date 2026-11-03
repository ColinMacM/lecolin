return {
  {
    "wojciech-kulik/xcodebuild.nvim",
    enabled = vim.fn.has "macunix" == 1,
    dependencies = { "nvim-telescope/telescope.nvim", "MunifTanjim/nui.nvim" },
    ft = { "swift", "objc" },
    cmd = { "XcodebuildSetup", "XcodebuildPicker" },
    opts = {},
    keys = {
      { "<leader>Xp", "<cmd>XcodebuildPicker<cr>", desc = "Xcode actions" },
      { "<leader>Xs", "<cmd>XcodebuildSetup<cr>", desc = "Xcode project setup" },
      { "<leader>Xb", "<cmd>XcodebuildBuild<cr>", desc = "Xcode build" },
      { "<leader>Xr", "<cmd>XcodebuildBuildRun<cr>", desc = "Xcode build & run" },
      { "<leader>Xd", "<cmd>XcodebuildSelectDevice<cr>", desc = "Xcode select device" },
      { "<leader>Xl", "<cmd>XcodebuildToggleLogs<cr>", desc = "Xcode toggle logs" },
      { "<leader>Xx", "<cmd>XcodebuildCancel<cr>", desc = "Xcode cancel build" },
    },
  },
}
