local M = {}

M.config = {
	callbacks = {
		---@param argv table a list of all the arguments in the nested session
		should_block = function(argv)
			return false
		end,
		pre_open = function() end,
		post_open = function(bufnr, winnr, filetype, is_blocking) end,
		block_end = function(filetype) end,
	},
	allow_cmd_passthrough = true,
	---Allow a nested session to open when nvim is
	---executed without any args
	nest_if_no_args = false,
	block_for = {
		gitcommit = true,
	},
	window = {
		open = "current",
		focus = "first",
	},
	pipe_path = function()
		return os.getenv("NVIM")
	end,
}

M.setup = function(opt)
	M.config = vim.tbl_deep_extend("keep", opt or {}, M.config)

	local pipe_path = M.config.pipe_path
	if type(pipe_path) == "function" then
		pipe_path = pipe_path()
	end
	if pipe_path ~= nil and not vim.tbl_contains(vim.fn.serverlist(), pipe_path, {}) then
		require("flatten.guest").init(pipe_path)
	end
end

return M
