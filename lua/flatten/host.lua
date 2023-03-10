local M = {}

M.init = function()
	local server_pipe = vim.call("serverstart")
	vim.call("setenv", require("flatten").pipe_var, server_pipe)
end

return M
