-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "everforest",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

M.ui = {
	statusline = {
		modules = {
			-- stock module shows only the filename tail; show the full path instead
			file = function()
				local utils = require "nvchad.stl.utils"
				local sep_style = require("nvconfig").ui.statusline.separator_style
				local sep_r = (type(sep_style) == "table" and sep_style or utils.separators[sep_style]).right
				local x = utils.file()
				local path = vim.api.nvim_buf_get_name(utils.stbufnr())
				local name = (path == "" and "Empty") or vim.fn.fnamemodify(path, ":~"):gsub("%%", "%%%%")
				return "%#St_file# " .. x[1] .. " " .. name .. (sep_style == "default" and " " or "") .. "%#St_file_sep#" .. sep_r
			end,
		},
	},
}

return M
