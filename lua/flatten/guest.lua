local M = {}

M.init = function()
	local args = vim.call("argv")

	local sock = vim.fn.sockconnect("pipe", require('flatten').pipe_path, { rpc = true })
	local response_pipe = vim.call("serverstart")

	local call =
		"return require('flatten.core').edit_files("
		.. vim.inspect(args) .. ','
		.. vim.inspect(response_pipe) .. ','
		.. "'" .. vim.fn.getcwd() .. "'" ..
		")"

	if #args < 1 then return end

	local block = vim.fn.rpcrequest(sock, "nvim_exec_lua", call, {})
	if not block then
		vim.cmd("qa!")
	end
	vim.fn.chanclose(sock)
	while block do
		vim.cmd("sleep 1")
	end
end

return M
