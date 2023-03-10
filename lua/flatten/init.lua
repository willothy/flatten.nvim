local M = {}

M.config = {
	callbacks = {
		pre_open = function()
		end,
		post_open = function(bufnr, winnr, filetype)
		end,
		block_end = function(filetype)
		end
	},
	block_for = {
		["gitcommit"] = true,
	}
}

M.pipe_var = "NVIM_FLATTEN_PIPE_PATH"
M.pipe_path = nil

local function flatten_init()
	M.pipe_path = os.getenv(M.pipe_var)
	if M.pipe_path ~= nil then
		require('flatten.guest').init()
	else
		require('flatten.host').init()
	end
end

M.setup = function(opt)
	M.config = vim.tbl_deep_extend("keep", opt, M.config)

	flatten_init()
end

return M
