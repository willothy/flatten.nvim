local M = {}

M.config = {
	callbacks = {
		pre_open = function()
		end,
		post_open = function(bufnr, winnr)
		end,
		block_end = function()
		end
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
	M.config = vim.tbl_deep_extend("force", M.config, opt)

	flatten_init()
end

return M
