local M = {}

local host

local function is_windows()
	return string.sub(package["config"], 1, 1) == "\\"
end

local function sanitize(path)
	return path:gsub("\\", "/")
end

function M.exec_on_host(call, opts)
	return vim.fn.rpcrequest(host, "nvim_exec_lua", call, opts or {})
end

function M.maybe_block(block)
	if not block then
		vim.cmd("qa!")
	end
	vim.fn.chanclose(host)
	while true do
		vim.cmd("sleep 1")
	end
end

local function send_files(files, stdin)
	if #files < 1 and #stdin < 1 then
		return
	end

	local config = require("flatten").config
	local force_block = vim.g.flatten_wait ~= nil or config.callbacks.should_block(vim.v.argv)

	local server = vim.fn.fnameescape(vim.v.servername)
	local cwd = vim.fn.fnameescape(vim.fn.getcwd(-1, -1))
	if is_windows() then
		server = sanitize(server)
		cwd = sanitize(cwd)
	end

	local call = string.format(
		[[return require('flatten.core').edit_files(%s)]],
		vim.inspect({
			files = files,
			response_pipe = server,
			guest_cwd = cwd,
			stdin = stdin,
			argv = vim.v.argv,
			force_block = force_block,
		})
	)

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		vim.api.nvim_buf_delete(buf, { force = true })
	end
	local block = M.exec_on_host(call) or force_block
	M.maybe_block(block)
end

M.init = function(host_pipe)
	-- Connect to host process
	host = vim.fn.sockconnect("pipe", host_pipe, { rpc = true })
	-- Return on connection error
	if host == 0 then
		return
	end

	-- Get new files
	local files = vim.fn.argv()
	local nfiles = #files

	vim.api.nvim_create_autocmd("StdinReadPost", {
		pattern = "*",
		callback = function()
			local readlines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
			send_files(files, readlines)
		end,
	})

	-- No arguments, user is probably opening a nested session intentionally
	-- Or only piping input from stdin
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*",
		callback = function()
			if nfiles < 1 then
				local result = M.exec_on_host("return require'flatten'.config.callbacks.no_files()")

				local should_nest, should_block
				if result == nil then
					local config = require("flatten").config
					should_nest = config.nest_if_no_args
				elseif type(result) == "boolean" then
					should_nest = result
				elseif type(result) == "table" then
					should_nest = result.nest_if_no_args
					should_block = result.should_block
				end
				if should_nest == true then
					return
				end
				M.maybe_block(should_block)
			end

			send_files(files, {})
		end,
	})
end

return M
