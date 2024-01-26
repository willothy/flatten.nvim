local M = {}

function M.unblock_guest(guest_pipe)
  local response_sock = vim.fn.sockconnect("pipe", guest_pipe, { rpc = true })
  vim.rpcnotify(
    response_sock,
    "nvim_exec_lua",
    ---@diagnostic disable-next-line: param-type-mismatch
    "vim.cmd.qa({ bang = true })",
    {}
  )
  vim.fn.chanclose(response_sock)
end

function M.notify_when_done(pipe, bufnr, callback, ft)
  vim.api.nvim_create_autocmd({ "QuitPre", "BufUnload", "BufDelete" }, {
    buffer = bufnr,
    once = true,
    group = M.augroup,
    callback = function()
      vim.api.nvim_del_augroup_by_id(M.augroup)
      M.unblock_guest(pipe)
      callback(ft)
    end,
  })
end

---@param focus Flatten.BufInfo?
---@return integer?
function M.smart_open(focus)
  -- set of valid target windows
  local valid_targets = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local win_buf = vim.api.nvim_win_get_buf(win)
    if
      vim.api.nvim_win_get_config(win).zindex == nil
      and vim.bo[win_buf].buftype == ""
    then
      valid_targets[win] = true
    end
  end

  local layout = vim.fn.winlayout()

  -- traverse the window tree to find the first available window
  local stack = { layout }
  local win_alt = vim.fn.win_getid(vim.fn.winnr("#"))
  local win

  -- prefer the alternative window if it's valid
  if valid_targets[win_alt] and win_alt ~= vim.api.nvim_get_current_win() then
    win = win_alt
  else
    while #stack > 0 do
      local node = table.remove(stack)
      if node[1] == "leaf" then
        if valid_targets[node[2]] then
          win = node[2]
          break
        end
      else
        for i = #node[2], 1, -1 do
          table.insert(stack, node[2][i])
        end
      end
    end
  end

  -- allows using this function as a utility to get a window to open something in
  if not focus then
    return win
  end

  if win then
    vim.api.nvim_win_set_buf(win, focus.bufnr)
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd("split")
    vim.api.nvim_win_set_buf(0, focus.bufnr)
  end
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
function M.edit_files(opts)
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
      local is_absolute
      if vim.fn.has("win32") == 1 then
        is_absolute = string.find(fname, "^%a:") ~= nil
      else
        is_absolute = string.find(fname, "^/") ~= nil
      end

      local fpath = is_absolute and fname or (guest_cwd .. "/" .. fname)
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
        ---@diagnostic disable-next-line: deprecated
        vim.api.nvim_buf_set_option(file.bufnr, "buflisted", true)
      end

      files[i] = file
    end
  end

  -- Create buffer for stdin pipe input
  ---@type Flatten.BufInfo
  local stdin_buf = nil
  if stdin_lines > 0 then
    -- Create buffer for stdin
    local bufnr = vim.api.nvim_create_buf(true, false)
    -- Add text to buffer
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, true, stdin)

    stdin_buf = {
      fname = "",
      bufnr = bufnr,
    }
  end

  ---@type window
  local winnr
  ---@type buffer
  local bufnr

  local is_diff = vim.tbl_contains(argv, "-d")

  if is_diff then
    local diff_open = config.window.diff
    if type(diff_open) == "function" then
      winnr, bufnr = config.window.diff(files, argv, stdin_buf, guest_cwd)
    else
      winnr = M.smart_open() --[[@as integer]] -- this will never return nil
      vim.api.nvim_set_current_win(winnr)

      if stdin_buf then
        files = vim.list_extend({ stdin_buf }, files)
      end
      local tab = false
      local vert = false

      if diff_open == "tab_split" or diff_open == "tab_vsplit" then
        tab = true
      end
      if diff_open == "vsplit" or diff_open == "tab_vsplit" then
        vert = true
      end

      for i, file in ipairs(files) do
        if i == 1 then
          if tab then
            vim.cmd.tabedit(file.fname)
          else
            vim.api.nvim_set_current_buf(file.bufnr)
          end
        else
          if vert then
            vim.cmd.vsplit(file.fname)
          else
            vim.cmd.split(file.fname)
          end
        end
        vim.cmd.diffthis()
      end
    end

    winnr = winnr or vim.api.nvim_get_current_win()
    bufnr = bufnr or vim.api.nvim_get_current_buf()
  elseif type(open) == "function" then
    bufnr, winnr = open(files, argv, stdin_buf, guest_cwd)
    if winnr == nil and bufnr ~= nil then
      ---@diagnostic disable-next-line: cast-local-type
      winnr = vim.fn.bufwinid(bufnr)
    end
  elseif type(open) == "string" then
    local focus = focus_first and files[1] or files[#files]
    -- If there's an stdin buf, focus that
    if stdin_buf then
      focus = stdin_buf
    end
    if open == "smart" then
      M.smart_open(focus)
    elseif open == "alternate" then
      winnr = vim.fn.win_getid(vim.fn.winnr("#")) --[[@as integer]]
      vim.api.nvim_set_current_win(winnr --[[@as integer]])
    elseif open == "split" then
      vim.cmd.split()
    elseif open == "vsplit" then
      vim.cmd.vsplit()
    elseif open == "tab" then
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
  if bufnr ~= nil then
    ---@diagnostic disable-next-line: deprecated
    ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  end

  local block = config.block_for[ft] or force_block

  for _, cmd in ipairs(postcmds) do
    if vim.api.nvim_exec2 then
      vim.api.nvim_exec2(cmd, {})
    else
      vim.api.nvim_exec(cmd, false)
    end
  end

  callbacks.post_open(
    bufnr --[[@as integer]],
    winnr --[[@as integer]],
    ft,
    block,
    is_diff
  )

  if block then
    M.augroup = vim.api.nvim_create_augroup("flatten_notify", { clear = true })
    M.notify_when_done(response_pipe, bufnr, callbacks.block_end, ft)
  end
  return block
end

return M
