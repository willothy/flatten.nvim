local M = {}

M.init = function()
	local args = vim.call("argv")

	local sock = vim.fn.sockconnect("pipe", require('flatten').pipe_path, { rpc = true })
	local response_pipe = vim.call("serverstart")

	local call =
		"require('flatten.core').edit_files("
		.. vim.inspect(args) .. ','
		.. vim.inspect(response_pipe) ..
		")"

	vim.fn.rpcrequest(sock, "nvim_exec_lua", call, {})
	vim.fn.chanclose(sock)
	while (true)
	do
		vim.cmd("sleep 10")
	end
end

return M
