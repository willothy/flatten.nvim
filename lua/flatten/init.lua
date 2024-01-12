---@diagnostic disable: unused-local
---@class Flatten
local Flatten = {}

---Top-level config table
---@class Flatten.Config
---@field callbacks Flatten.Callbacks
---@field window Flatten.WindowConfig
---@field integrations Flatten.Integrations
---@field block_for Flatten.BlockFor
---@field allow_cmd_passthrough Flatten.AllowCmdPassthrough
---@field nest_if_no_args Flatten.NestIfNoArgs

---@class Flatten.PartialConfig :Flatten.Config
---@field callbacks Flatten.Callbacks
---@field window Flatten.WindowConfig?
---@field integrations Flatten.Integrations?
---@field block_for Flatten.BlockFor?
---@field allow_cmd_passthrough Flatten.AllowCmdPassthrough?
---@field nest_if_no_args Flatten.NestIfNoArgs?

---@class Flatten.EditFilesOptions
---@field files table          list of files passed into nested instance
---@field response_pipe string guest default socket
---@field guest_cwd string     guest global cwd
---@field argv table           full list of options passed to the nested instance, see v:argv
---@field stdin table          stdin lines or {}
---@field force_block boolean  enable blocking
---@field data any?            arbitrary data passed to the host

---Specify blocking by filetype
---@alias Flatten.BlockFor table<string, boolean>

---Specify whether to allow commands to be passed to nvim remotely via +... or --cmd ...
---@alias Flatten.AllowCmdPassthrough boolean?

---Specify whether to allow a nested session to open when nvim is executed without any args
---@alias Flatten.NestIfNoArgs boolean?

-- The first argument is a list of BufInfo tables representing the newly opened files.
-- The third argument is a single BufInfo table, only provided when a buffer is created from stdin.
--
-- IMPORTANT: For `block_for` to work, you need to return a buffer number OR a buffer number and a window number.
--            The `winnr` return value is not required, `vim.fn.bufwinid(bufnr)` is used if it is not provided.
--            The `filetype` of this buffer will determine whether block should happen or not.
--
---@alias Flatten.OpenHandler fun(opts: Flatten.OpenContext):window, buffer

---Determines what window(s) to open files in.
---@alias Flatten.OpenConfig "'current'" | "'alternate'" | "'split'" | "'vsplit'" | "'tab'" | "'smart'" | Flatten.OpenHandler

---Determines what window(s) to open diffs (nvim -d) in.
---@alias Flatten.DiffConfig "'split'" | "'vsplit'" | "'tab_split'" | "'tab_vsplit'" | Flatten.OpenHandler

---Deterimines which buffer to focus, if opening more than one remotely.
---@alias Flatten.FocusConfig "'first'" | "'last'"

---Determines what to do when there are no files to open.
---@alias Flatten.NoFilesBehavior boolean | { nest: boolean, block: boolean }

---Configure window / opening behavior
---@class Flatten.WindowConfig
---@field open? Flatten.OpenConfig
---@field diff? Flatten.DiffConfig
---@field focus? Flatten.FocusConfig

---Configure integrations with other programs / terminal emulators
---@class Flatten.Integrations
---@field kitty? boolean
---@field wezterm? boolean

---Passed to callbacks that handle opening files
---@class Flatten.BufInfo
---@field fname string
---@field bufnr buffer

---Passed into custom open handlers
---@class Flatten.OpenContext
---@field files string[]
---@field argv string[]
---@field stdin_buf? Flatten.BufInfo
---@field guest_cwd string
---@field data any

---Passed into the pre_open callback
---@class Flatten.PreOpenContext
---@field data any

---Passed into the post_open callback
---@class Flatten.PostOpenContext
---@field bufnr buffer
---@field winnr window
---@field filetype string
---@field is_blocking boolean
---@field is_diff boolean
---@field data any

---Passed into the block_end callback
---@class Flatten.BlockEndContext
---@field filetype string
---@field data any

---Callbacks to define custom behavior
---@class Flatten.Callbacks
---Called to determine if a nested session should wait for the host to close the file.
---@field should_block? fun(argv: string[]):boolean
---If this returns true, the nested session will be opened.
---If false, default behavior is used, and
---config.nest_if_no_args is respected.
---@field should_nest? fun(host: integer):boolean
---Called before a nested session is opened.
---@field pre_open? fun(opts: Flatten.PreOpenContext)
---Called after a nested session is opened.
---@field post_open? fun(opts: Flatten.PostOpenContext)
---Called when a nested session is done waiting for the host.
---@field block_end? fun(opts: Flatten.BlockEndContext)
---Executed when there are no files to open, to determine whether
---to nest or not. The default implementation returns config.nest_if_no_args.
---@field no_files? fun():Flatten.NoFilesBehavior
---Only executed on the guest, used to pass arbitrary data to the host.
---@field guest_data? fun():any
---Executed on init on both host and guest. Used to determine the pipe path
---for communication between the host and guest, and to determine whether
---an nvim instance is a host or guest in the first place.
---@field pipe_path? fun():string?
local Callbacks = {}

---Called to determine if a nested session should wait for the host to close the file.
---@param argv string[]
---@return boolean
function Callbacks.should_block(argv)
  return false
end

---If this returns true, the nested session will be opened.
---If false, default behavior is used, and
---config.nest_if_no_args is respected.
---@param host integer channel id
---@return boolean
function Callbacks.should_nest(host)
  -- don't nest in a neovim terminal (unless nest_if_no_args is set)
  if vim.env.NVIM ~= nil then
    return false
  end

  -- if we're not using kitty or wezterm,
  -- early return and allow the nested session to open
  if
    not Flatten.config.integrations.kitty
    and not Flatten.config.integrations.wezterm
  then
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

---Called before a nested session is opened.
---@param opts Flatten.PreOpenContext
function Callbacks.pre_open(opts)
  return nil
end

---Called after a nested session is opened.
---@param opts Flatten.PostOpenContext
function Callbacks.post_open(opts)
  return nil
end

---Called when a nested session is done waiting for the host.
---@param opts Flatten.BlockEndContext
function Callbacks.block_end(opts)
  return nil
end

---Executed when there are no files to open, to determine whether
---to nest or not. The default implementation returns config.nest_if_no_args.
---@return Flatten.NoFilesBehavior
function Callbacks.no_files()
  return Flatten.config.nest_if_no_args
end

---Only executed on the guest, used to pass arbitrary data to the host.
---@return any
function Callbacks.guest_data()
  return nil
end

---Executed on init on both host and guest. Used to determine the pipe path
---for communication between the host and guest, and to determine whether
---an nvim instance is a host or guest in the first place.
---@return string?
function Callbacks.pipe_path()
  -- If running in a terminal inside Neovim:
  if vim.env.NVIM then
    return vim.env.NVIM
  end

  local core = require("flatten.core")

  -- If running in a Kitty terminal,
  -- all tabs/windows/os-windows in the same instance of kitty will open in the first neovim instance
  if Flatten.config.integrations.kitty and vim.env.KITTY_PID then
    local ret = core.try_address("kitty.nvim-" .. vim.env.KITTY_PID, true)
    if ret ~= nil then
      return ret
    end
  end

  -- If running in Wezterm, all tabs/windows/windows in the same instance
  -- of wezterm will open in the first neovim instance.
  if Flatten.config.integrations.wezterm and vim.env.WEZTERM_UNIX_SOCKET then
    local pid = vim.env.WEZTERM_UNIX_SOCKET:match("gui%-sock%-(%d+)")
    local ret = core.try_address("wezterm.nvim-" .. pid, true)
    if ret ~= nil then
      return ret
    end
  end
end

---@type Flatten.Config
Flatten.config = {
  callbacks = Callbacks,
  block_for = {
    gitcommit = true,
    gitrebase = true,
  },
  window = {
    open = "current",
    diff = "tab_vsplit",
    focus = "first",
  },
  integrations = {
    kitty = false,
    wezterm = false,
  },
  allow_cmd_passthrough = true,
  nest_if_no_args = false,
}

local is_guest
---@return boolean | nil
---Returns true if in guest, false if in host, and nil if flatten has not yet been initialized.
function Flatten.is_guest()
  return is_guest
end

---@param opts Flatten.PartialConfig?
Flatten.setup = function(opts)
  Flatten.config = vim.tbl_deep_extend("keep", opts or {}, Flatten.config)

  local pipe_path = Flatten.config.callbacks.pipe_path()

  if
    pipe_path == nil or vim.tbl_contains(vim.fn.serverlist(), pipe_path, {})
  then
    is_guest = false
    return
  end

  is_guest = true
  require("flatten.guest").init(pipe_path)
end

return Flatten
