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
}

M.setup = function(opt)
	M.config = vim.tbl_deep_extend("keep", opt, M.config)

	local pipe_path = os.getenv("NVIM")
	if pipe_path ~= nil then
		require("flatten.guest").init(pipe_path)
	end
end

return M
