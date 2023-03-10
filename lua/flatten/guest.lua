local M = {}

M.init = function()
	local args = vim.call("argv")

	local sock = vim.fn.sockconnect("pipe", require('flatten').pipe_path, { rpc = true })
	local response_pipe = vim.call("serverstart")

	local call =
		"return require('flatten.core').edit_files("
		.. vim.inspect(args) .. ','
		.. vim.inspect(response_pipe) ..
		")"

	local block = vim.fn.rpcrequest(sock, "nvim_exec_lua", call, {})
	vim.fn.chanclose(sock)
	if block == false then
		vim.cmd('qa!')
	end
	while block do
		vim.cmd("sleep 5")
	end
end

return M
