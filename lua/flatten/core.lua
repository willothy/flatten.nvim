local M = {}

local function unblock_client(sock, othercmds)
	vim.fn.rpcnotify(sock, "nvim_exec_lua", "vim.cmd('qa!')", {})
	vim.fn.chanclose(sock)

	for _, cmd in othercmds do
		vim.api.nvim_del_autocmd(cmd)
	end
end

local function notify_when_done(sock, bufnr)
	local quitpre
	local bufunload
	quitpre = vim.api.nvim_create_autocmd("QuitPre", {
		buffer = bufnr,
		once = true,
		callback = function()
			unblock_client(sock, { bufunload })
		end
	})
	bufunload = vim.api.nvim_create_autocmd("BufUnload", {
		buffer = bufnr,
		once = true,
		callback = function()
			unblock_client(sock, { quitpre })
		end
	})
end

M.edit_files = function(args, response_pipe)
	local config = require("flatten").config
	local callbacks = config.callbacks

	callbacks.pre_open()
	if #args > 0 then
		local argstr = ""
		for _, arg in pairs(args) do
			local p = vim.loop.fs_realpath(arg) or arg
			if argstr == "" or argstr == nil then
				argstr = p
			else
				argstr = argstr .. " " .. p
			end
		end
		vim.cmd("0argadd " .. argstr)

		vim.cmd("tab argument 1")

		vim.cmd("edit")
	else
		vim.cmd("tabnew")
	end
	local ft = vim.bo.filetype

	local winnr = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_get_current_buf()
	callbacks.post_open(bufnr, winnr, ft)

	local response_sock = vim.fn.sockconnect("pipe", response_pipe, { rpc = true })
	local block = config.block_for[ft]
	if block then
		notify_when_done(response_sock, bufnr)
		callbacks.block_end(ft)
	else
		unblock_client(response_sock, nil)
	end
end

return M
