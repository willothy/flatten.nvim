local M = {}

---@param addr string
---@param startserver boolean
function M.try_address(addr, startserver)
  if not addr:find("/") then
    addr = ("%s/%s"):format(vim.fn.stdpath("run"), addr)
  end
  if vim.loop.fs_stat(addr) then
    local ok, sock = require("flatten.guest").sockconnect(addr)
    if ok then
      return sock
    end
  elseif startserver then
    local ok = pcall(vim.fn.serverstart, addr)
    if ok then
      return addr
    end
  end
end

---@return string | nil
function M.default_pipe_path()
  -- If running in a terminal inside Neovim:
  if vim.env.NVIM then
    return vim.env.NVIM
  end
  -- If running in a Kitty terminal,
  -- all tabs/windows/os-windows in the same instance of kitty will open in the first neovim instance
  if M.config.one_per.kitty and vim.env.KITTY_PID then
    local ret = M.try_address("kitty.nvim-" .. vim.env.KITTY_PID, true)
    if ret ~= nil then
      return ret
    end
  end
  -- If running in a Wezterm,
  -- all tabs/windows/windows in the same instance of wezterm will open in the first neovim instance
  if M.config.one_per.wezterm and vim.env.WEZTERM_UNIX_SOCKET then
    local pid = vim.env.WEZTERM_UNIX_SOCKET:match("gui%-sock%-(%d+)")
    local ret = M.try_address("wezterm.nvim-" .. pid, true)
    if ret ~= nil then
      return ret
    end
  end
end

---@param host channel
---@return boolean
function M.default_should_nest(host)
  -- don't nest in a neovim terminal (unless nest_if_no_args is set)
  if vim.env.NVIM ~= nil then
    return false
  end

  -- if we're not using kitty or wezterm,
  -- early return and allow the nested session to open
  if not M.config.one_per.kitty and not M.config.one_per.wezterm then
    return true
  end

  -- If in a wezterm or kitty split, only open files in the first neovim instance
  -- if their working directories are the same.
  -- This allows you to open a new instance in a different cwd, but open files from the active cwd in your current session.
  local call = "return vim.fn.getcwd(-1)"
  local ok, host_cwd = pcall(vim.rpcrequest, host, "nvim_exec_lua", call, {})

  -- Yield to default behavior if RPC call fails
  if not ok then
    return false
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  return not vim.startswith(vim.fn.getcwd(-1), host_cwd)
end

-- selene: allow(unused_variable)

---@param argv table
---@return boolean
function M.default_should_block(argv)
  return false
end

local is_guest
---@return boolean | nil
---Returns true if in guest, false if in host, and nil if flatten has not yet been initialized.
function M.is_guest()
  return is_guest
end

-- Types:
--
-- Passed to callbacks that handle opening files
---@alias Flatten.BufInfo { fname: string, bufnr: buffer }
--
-- The first argument is a list of BufInfo tables representing the newly opened files.
-- The third argument is a single BufInfo table, only provided when a buffer is created from stdin.
--
-- IMPORTANT: For `block_for` to work, you need to return a buffer number OR a buffer number and a window number.
--            The `winnr` return value is not required, `vim.fn.bufwinid(bufnr)` is used if it is not provided.
--            The `filetype` of this buffer will determine whether block should happen or not.
--
---@alias Flatten.OpenHandler fun(files: Flatten.BufInfo[], argv: string[], stdin_buf: Flatten.BufInfo, guest_cwd: string):window, buffer

-- selene: allow(unused_variable)
M.config = {
  callbacks = {
    ---Called to determine if a nested session should wait for the host to close the file.
    ---@param argv table a list of all the arguments in the nested session
    ---@return boolean
    should_block = M.default_should_block,
    ---If this returns true, the nested session will be opened.
    ---If false, default behavior is used, and
    ---config.nest_if_no_args is respected.
    ---@type fun(host: channel):boolean
    should_nest = M.default_should_nest,
    ---Called before a nested session is opened.
    pre_open = function() end,
    ---Called after a nested session is opened.
    ---@param bufnr buffer
    ---@param winnr window
    ---@param filetype string
    ---@param is_blocking boolean
    ---@param is_diff boolean
    post_open = function(bufnr, winnr, filetype, is_blocking, is_diff) end,
    ---Called when a nested session is done waiting for the host.
    ---@param filetype string
    block_end = function(filetype) end,
  },
  ---Specify blocking by filetype
  ---@type table<string, boolean>
  block_for = {
    gitcommit = true,
    gitrebase = true,
  },
  window = {
    ---@type "current" | "alternate" | "split" | "vsplit" | "tab" | "smart" | Flatten.OpenHandler
    open = "current",
    ---@type "split" | "vsplit" | "tab_split" | "tab_vsplit" | Flatten.OpenHandler
    diff = "tab_vsplit",
    ---@type "first" | "last"
    focus = "first",
  },
  one_per = { kitty = false, wezterm = false },
  ---@type string | fun():(string|nil)
  pipe_path = M.default_pipe_path,
  ---Allow commands to be passed to nvim remotely via +... or --cmd ...
  ---@type boolean
  allow_cmd_passthrough = true,
  ---Allow a nested session to open when nvim is
  ---executed without any args
  ---@type boolean
  nest_if_no_args = false,
}

M.setup = function(opt)
  M.config = vim.tbl_deep_extend("keep", opt or {}, M.config)

  local pipe_path = M.config.pipe_path
  if type(pipe_path) == "function" then
    ---@diagnostic disable-next-line: cast-local-type
    pipe_path = pipe_path()
  end

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
