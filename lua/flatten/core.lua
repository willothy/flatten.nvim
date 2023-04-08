local M = {}

local function unblock_guest(guest_pipe, othercmds)
	local response_sock = vim.fn.sockconnect("pipe", guest_pipe, { rpc = true })
	vim.fn.rpcnotify(response_sock, "nvim_exec_lua", "vim.cmd('qa!')", {})
	vim.fn.chanclose(response_sock)

	for _, cmd in ipairs(othercmds) do
		vim.api.nvim_del_autocmd(cmd)
	end
end

local function notify_when_done(pipe, bufnr, callback, ft)
	local quitpre
	local bufunload
	local bufdelete

	quitpre = vim.api.nvim_create_autocmd("QuitPre", {
		buffer = bufnr,
		once = true,
		callback = function()
			unblock_guest(pipe, { bufunload, bufdelete })
			callback(ft)
		end,
	})
	bufunload = vim.api.nvim_create_autocmd("BufUnload", {
		buffer = bufnr,
		once = true,
		callback = function()
			unblock_guest(pipe, { quitpre, bufdelete })
			callback(ft)
		end,
	})
	bufdelete = vim.api.nvim_create_autocmd("BufDelete", {
		buffer = bufnr,
		once = true,
		callback = function()
			unblock_guest(pipe, { quitpre, bufunload })
			callback(ft)
		end,
	})
end

---@class EditFilesOptions
---@field files table          list of files passed into nested instance
---@field response_pipe string guest default socket
---@field guest_cwd string     guest global cwd
---@field argv table           full list of options passed to the nested instance, see v:argv
---@field stdin table          stdin lines or {}
---@field force_block boolean  enable blocking

---@param opts EditFilesOptions
---@return boolean
M.edit_files = function(opts)
	local files = opts.files
	local response_pipe = opts.response_pipe
	local guest_cwd = opts.guest_cwd
	local stdin = opts.stdin
	local force_block = opts.force_block
	local argv = opts.argv
	local config = require("flatten").config
	local callbacks = config.callbacks
	local focus_first = config.window.focus == "first"
	local open = config.window.open

	local nfiles = #files
	local stdin_lines = #stdin

	--- commands passed through with +<cmd>, to be executed after opening files
	local postcmds = {}

	if nfiles == 0 and stdin_lines == 0 then
		-- If there are no new bufs, don't open anything
		-- and tell the guest not to block
		return false
	end

	local is_cmd = false
	for _, arg in ipairs(argv) do
		if is_cmd then
			is_cmd = false
			-- execute --cmd <cmd> commands
			vim.api.nvim_exec2(arg, {})
		elseif arg:sub(1, 1) == "+" then
			local cmd = string.sub(arg, 2, -1)
			table.insert(postcmds, cmd)
		elseif arg == "--cmd" then
			-- next arg is the actual command
			is_cmd = true
		end
	end

	callbacks.pre_open()

	-- Open files
	if nfiles > 0 then
		local argstr = ""
		for i, fname in ipairs(files) do
			local is_absolute = string.find(fname, "^/")
			local fpath = vim.fn.fnameescape(is_absolute and fname or (guest_cwd .. "/" .. fname))
			files[i] = fpath
			if argstr == "" or argstr == nil then
				argstr = fpath
			else
				argstr = argstr .. " " .. fpath
			end
		end
		-- Hack to work around https://github.com/vim/vim/issues/4610
		local wildignore = vim.o.wildignore
		vim.o.wildignore = ""
		vim.cmd("0argadd " .. argstr)
		vim.o.wildignore = wildignore
	end

	-- Create buffer for stdin pipe input
	local stdin_buf = nil
	if stdin_lines > 0 then
		-- Create buffer for stdin
		stdin_buf = vim.api.nvim_create_buf(true, false)
		-- Add text to buffer
		vim.api.nvim_buf_set_lines(stdin_buf, 0, 0, true, stdin)
		-- Set buffer name based on the first line of stdin
		local name = stdin[1]:sub(1, 12):gsub("[^%w%.]", "")
		-- Ensure the name isn't empty or a duplicate
		if vim.fn.bufname(name) ~= "" or name == "" then
			local i = 1
			local newname = name .. i
			while vim.fn.bufname(newname) ~= "" do
				i = i + 1
				newname = name .. i
			end
			name = newname
		end
		vim.api.nvim_buf_set_name(stdin_buf, name)
	end

	-- Open window
	if type(open) == "function" then
		-- Pass list of new buffer IDs
		local bufs = vim.api.nvim_list_bufs()
		local start = #bufs - #files
		-- Add buffer for stdin
		local newbufs = {}
		-- If there's an stdin buf, push it to the table
		if stdin_buf then
			start = start - 1
			table.insert(newbufs, stdin_buf)
		end
		for i, buf in ipairs(bufs) do
			if i > start then
				table.insert(newbufs, buf)
			end
		end
		open(newbufs, argv)
	elseif type(open) == "string" then
		local focus = vim.fn.argv(focus_first and 0 or (#files - 1))
		-- If there's an stdin buf, focus that
		if stdin_buf then
			focus = vim.api.nvim_buf_get_name(stdin_buf)
		end
		if open == "current" then
			vim.cmd("edit " .. focus)
		elseif open == "alternate" then
			local winnr = vim.fn.win_getid(vim.fn.winnr("#"))
			vim.api.nvim_win_set_buf(winnr, vim.fn.bufnr(focus))
			vim.api.nvim_set_current_win(winnr)
		elseif open == "split" then
			vim.cmd("split " .. focus)
		elseif open == "vsplit" then
			vim.cmd("vsplit " .. focus)
		else
			vim.cmd("tabedit " .. focus)
		end
	else
		vim.api.nvim_err_writeln("Flatten: 'config.open.focus' expects a function or string, got " .. type(open))
		return false
	end

	local ft = vim.bo.filetype

	local winnr = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_get_current_buf()

	local block = config.block_for[ft] or force_block

	for _, cmd in ipairs(postcmds) do
		vim.api.nvim_exec2(cmd, {})
	end

	callbacks.post_open(bufnr, winnr, ft, block)

	if block then
		notify_when_done(response_pipe, bufnr, callbacks.block_end, ft)
	end
	return block
end

return M
