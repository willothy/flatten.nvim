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
	-- vim.fn.rpcnotify(sock, "nvim_exec_lua", call, {})

	vim.fn.rpcrequest(sock, "nvim_exec_lua", call, {})
	-- while true do
	-- 	-- sleep for 1000ms
	-- 	vim.fn.sleep(1000)
	-- end
end

return M
