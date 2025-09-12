-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "rosepine",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },

  hl_override = {
		-- Make the Normal and Float backgrounds transparent
		Normal = { bg = "NONE" },
		NormalFloat = { bg = "NONE" },
		FloatBorder = { bg = "NONE" },
		LineNr = { bg = "NONE" },
		SignColumn = { bg = "NONE" },
		-- You can add more groups to customize as needed

		-- Optional: Keep comments italicized
		Comment = { italic = true },
		["@comment"] = { italic = true },
	},
}

return M
