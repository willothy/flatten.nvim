local M = {}

M.init = function(host_pipe)
	local args = vim.fn.argv()
	local force_block = vim.g.flatten_wait ~= nil
	local host = vim.fn.sockconnect("pipe", host_pipe, { rpc = true })

	local call = string.format([[
		return require('flatten.core').edit_files(
			%s,   -- `args` passed into nested instance.
			'%s', -- guest default socket.
			'%s', -- guest global cwd.
			%s    -- force block from guest using vim.g.flatten_wait
		)]],
		vim.inspect(args),
		vim.v.servername,
		vim.fn.getcwd(),
		force_block
	)

	if #args < 1 then return end

	local block = vim.fn.rpcrequest(host, "nvim_exec_lua", call, {}) or force_block
	if not block then
		vim.cmd("qa!")
	end
	vim.fn.chanclose(host)
	while true do
		vim.cmd("sleep 1")
	end
end

return M
