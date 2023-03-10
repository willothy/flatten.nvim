local M = {}

local function unblock_client(sock, othercmd1, othercmd2)
	local sock = vim.fn.sockconnect("pipe", sock, { rpc = true })
	vim.fn.rpcnotify(sock, "nvim_exec_lua", "vim.cmd('qa!')", {})
	vim.fn.chanclose(sock)

	if othercmd1 ~= nil then
		vim.api.nvim_del_autocmd(othercmd1)
	end
	if othercmd2 ~= nil then
		vim.api.nvim_del_autocmd(othercmd2)
	end
end

local function notify_when_done(sock, bufnr)
	local quitpre
	local bufunload
	local bufdelete
	quitpre = vim.api.nvim_create_autocmd("QuitPre", {
		buffer = bufnr,
		callback = function()
			unblock_client(sock, bufunload, bufdelete)
		end
	})
	bufunload = vim.api.nvim_create_autocmd("BufUnload", {
		buffer = bufnr,
		callback = function()
			unblock_client(sock, quitpre, bufdelete)
		end
	})
	bufdelete = vim.api.nvim_create_autocmd("BufDelete", {
		buffer = bufnr,
		callback = function()
			unblock_client(sock, quitpre, bufunload)
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
	callbacks.post_open(bufnr, winnr)

	local block = config.block_for[ft]
	if block then
		notify_when_done(response_pipe, bufnr)
		callbacks.block_end()
	else
		unblock_client(response_pipe, nil, nil)
	end
end

return M
