local M = {}

M.config = {
	callbacks = {
		pre_open = function()
		end,
		post_open = function(bufnr, winnr, filetype, is_blocking)
		end,
		block_end = function(filetype)
		end
	},
	block_for = {
		gitcommit = true,
	},
	window = {
		open = "current",
		focus = "first"
	}
}

local function flatten_init()
	local pipe_path = os.getenv("NVIM")
	if pipe_path ~= nil then
		require('flatten.guest').init(pipe_path)
	end
end

M.setup = function(opt)
	M.config = vim.tbl_deep_extend("keep", opt, M.config)

	flatten_init()
end

return M
