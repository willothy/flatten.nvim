local M = {}

M.try_address = function(addr, startserver)
  if not addr:find("/") then
    addr = ("%s/%s"):format(vim.fn.stdpath("run"), addr)
  end
  if vim.loop.fs_stat(addr) then
    local ok, sock = require("flatten.guest").sockconnect(addr)
    if ok then return sock end
  elseif startserver then
    local ok = pcall(vim.fn.serverstart, addr)
    if ok then return addr end
  end
end

M.default_pipe_path = function()
  -- If running in a terminal inside Neovim:
  if vim.env.NVIM then return vim.env.NVIM end
  -- If running in a Kitty terminal,
  -- all tabs/windows/os-windows in the same instance of kitty will open in the first neovim instance
  if M.config.one_per.kitty and vim.env.KITTY_PID then
    local ret = M.try_address("kitty.nvim-" .. vim.env.KITTY_PID, true)
    if ret ~= nil then return ret end
  end
  -- If running in a Wezterm,
  -- all tabs/windows/windows in the same instance of wezterm will open in the first neovim instance
  if M.config.one_per.wezterm and vim.env.WEZTERM_UNIX_SOCKET then
    local pid = vim.env.WEZTERM_UNIX_SOCKET:match("gui%-sock%-(%d+)")
    local ret = M.try_address("wezterm.nvim-" .. pid, true)
    if ret ~= nil then return ret end
  end
end

-- selene: allow(unused_variable)
M.config = {
  callbacks = {
    ---@param argv table a list of all the arguments in the nested session
    ---@return boolean
    should_block = function(argv)
      return false
    end,
    pre_open = function() end,
    ---@param bufnr buffer
    ---@param winnr window
    ---@param filetype string
    ---@param is_blocking boolean
    post_open = function(bufnr, winnr, filetype, is_blocking) end,
    ---@param filetype string
    block_end = function(filetype) end,
  },
  allow_cmd_passthrough = true,
  ---Allow a nested session to open when nvim is
  ---executed without any args
  nest_if_no_args = false,
  ---@type table<string, boolean>
  block_for = {
    gitcommit = true,
  },
  window = {
    ---@alias BufInfo { fname: string, bufnr: buffer }
    ---@type "current" | "alternate" | "split" | "vsplit" | "tab" | fun(files: BufInfo[], arv: string[], stdin_buf: BufInfo, guest_cwd: string):window, buffer
    open = "current",
    ---@type "first" | "last"
    focus = "first",
  },
  one_per = { kitty = true, wezterm = true },
  ---@type string | fun():(string|nil)
  ---Return nil to allow nesting
  pipe_path = M.default_pipe_path,
}

local is_guest
---@return boolean | nil
---Returns true if in guest, false if in host, and nil if flatten has not yet been initialized.
function M.is_guest()
  return is_guest
end

M.setup = function(opt)
  M.config = vim.tbl_deep_extend("keep", opt or {}, M.config)

  local pipe_path = M.config.pipe_path
  if type(pipe_path) == "function" then pipe_path = pipe_path() end

  if
    pipe_path == nil or vim.tbl_contains(vim.fn.serverlist(), pipe_path, {})
  then
    is_guest = false
    return
  end

  is_guest = true
  require("flatten.guest").init(pipe_path)
end

return M
