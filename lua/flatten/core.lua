local M = {}

local function unblock_guest(guest_pipe)
  local response_sock = vim.fn.sockconnect("pipe", guest_pipe, { rpc = true })
  vim.fn.rpcnotify(
    response_sock,
    "nvim_exec_lua",
    "vim.cmd.qa({ bang = true })",
    {}
  )
  vim.fn.chanclose(response_sock)
end

local function notify_when_done(pipe, bufnr, callback, ft)
  vim.api.nvim_create_autocmd({ "QuitPre", "BufUnload", "BufDelete" }, {
    buffer = bufnr,
    once = true,
    group = M.augroup,
    callback = function()
      vim.api.nvim_del_augroup_by_id(M.augroup)
      unblock_guest(pipe)
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
  if config.allow_cmd_passthrough then
    for _, arg in ipairs(argv) do
      if is_cmd then
        is_cmd = false
        -- execute --cmd <cmd> commands
        if vim.api.nvim_exec2 then
          -- nvim_exec2 only exists in nvim 0.9+
          vim.api.nvim_exec2(arg, {})
        else
          vim.api.nvim_exec(arg, false)
        end
      elseif arg:sub(1, 1) == "+" then
        local cmd = string.sub(arg, 2, -1)
        table.insert(postcmds, cmd)
      elseif arg == "--cmd" then
        -- next arg is the actual command
        is_cmd = true
      end
    end
  end

  callbacks.pre_open()

  -- Open files
  if nfiles > 0 then
    for i, fname in ipairs(files) do
      local is_absolute = string.find(fname, "^/")
      local fpath =
        vim.fn.fnameescape(is_absolute and fname or (guest_cwd .. "/" .. fname))
      local file = {
        fname = fpath,
        bufnr = vim.fn.bufadd(fpath),
      }

      -- set buf options
      if vim.api.nvim_set_option_value then
        vim.api.nvim_set_option_value("buflisted", true, {
          buf = file.bufnr,
        })
      else
        vim.api.nvim_buf_set_option(file.bufnr, "buflisted", true)
      end

      files[i] = file
    end
  end

  -- Create buffer for stdin pipe input
  local stdin_buf = nil
  if stdin_lines > 0 then
    -- Create buffer for stdin
    stdin_buf = vim.api.nvim_create_buf(true, false)
    -- Add text to buffer
    vim.api.nvim_buf_set_lines(stdin_buf, 0, 0, true, stdin)

    stdin_buf = {
      fname = "",
      bufnr = stdin_buf,
    }
  end

  local winnr
  local bufnr

  -- Open window
  if type(open) == "function" then
    bufnr, winnr = open(files, argv, stdin_buf, guest_cwd)
    if winnr == nil and bufnr ~= nil then winnr = vim.fn.bufwinid(bufnr) end
  elseif type(open) == "string" then
    local focus = focus_first and files[1] or files[#files]
    -- If there's an stdin buf, focus that
    if stdin_buf then focus = stdin_buf end
    if open == "alternate" then
      winnr = vim.fn.win_getid(vim.fn.winnr("#"))
      vim.api.nvim_set_current_win(winnr)
    elseif open == "split" then
      vim.cmd.split()
    elseif open == "vsplit" then
      vim.cmd.vsplit()
    else
      vim.cmd.tabnew()
    end
    vim.api.nvim_set_current_buf(focus.bufnr)
    winnr = vim.api.nvim_get_current_win()
    bufnr = focus.bufnr
  else
    vim.api.nvim_err_writeln(
      "Flatten: 'config.open.focus' expects a function or string, got "
        .. type(open)
    )
    return false
  end

  local ft
  if bufnr ~= nil then ft = vim.api.nvim_buf_get_option(bufnr, "filetype") end

  local block = config.block_for[ft] or force_block

  for _, cmd in ipairs(postcmds) do
    if vim.api.nvim_exec2 then
      vim.api.nvim_exec2(cmd, {})
    else
      vim.api.nvim_exec(cmd, false)
    end
  end

  callbacks.post_open(bufnr, winnr, ft, block)

  if block then
    M.augroup = vim.api.nvim_create_augroup("flatten_notify", { clear = true })
    notify_when_done(response_pipe, bufnr, callbacks.block_end, ft)
  end
  return block
end

return M
