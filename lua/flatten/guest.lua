local M = {}

M.init = function(host_pipe)
	local args = vim.call("argv")

	local host = vim.fn.sockconnect("pipe", host_pipe, { rpc = true })

	local call =
		"return require('flatten.core').edit_files("
		.. vim.inspect(args) .. ','
		.. "'" .. vim.v.servername .. "',"
		.. "'" .. vim.fn.getcwd() .. "'" ..
		")"

	if #args < 1 then return end

	local block = vim.fn.rpcrequest(host, "nvim_exec_lua", call, {})
	if not block then
		vim.cmd("qa!")
	end
	vim.fn.chanclose(host)
	while true do
		vim.cmd("sleep 1")
	end
end

return M
