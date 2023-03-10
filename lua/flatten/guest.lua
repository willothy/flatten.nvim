local M = {}

M.init = function()
	local args = vim.call("argv")

	local block = false

	local sock = vim.fn.sockconnect("pipe", require('flatten').pipe_path, { rpc = true })
	local response_pipe = ""
	if block then
		if (#args ~= 1) then
			local err = "Cannot block when opening more than one file"
			vim.fn.rpcrequest(sock, "nvim_exec_lua", "vim.api.nvim_err_writeln('" .. err .. "')", {})
			vim.fn.chanclose(sock)
			vim.cmd("qall!")
			return
		end
		response_pipe = ", " .. vim.inspect(vim.call("serverstart"))
	end

	local call =
		"require('flatten.core').edit_files(" ..
		vim.inspect(args) ..
		response_pipe ..
		")"
	vim.fn.rpcnotify(sock, "nvim_exec_lua", call, {})

	if not block then
		vim.fn.chanclose(sock)
		vim.cmd("qa!")
		return
	end

	while true do
		vim.cmd("sleep 1")
	end
end

return M
