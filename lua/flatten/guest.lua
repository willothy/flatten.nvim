local M = {}

local config = require("flatten").config

local waiting = false
local host

local function is_windows()
  return string.sub(package["config"], 1, 1) == "\\"
end

local function sanitize(path)
  return path:gsub("\\", "/")
end

function M.exec_on_host(call, opts)
  return vim.rpcrequest(host, "nvim_exec_lua", call, opts or {})
end

function M.unblock()
  waiting = false
end

function M.maybe_block(block)
  if not block then
    vim.cmd.qa({ bang = true })
  end
  waiting = true
  vim.wait(math.huge, function()
    return waiting == false
      or vim.api.nvim_get_chan_info(host) == vim.empty_dict()
  end, 1000)
  vim.cmd.qa({ bang = true })
end

function M.send_files(files, stdin)
  if #files < 1 and #stdin < 1 then
    return
  end

  local force_block = vim.g.flatten_wait ~= nil
    or config.callbacks.should_block(vim.v.argv)

  local server = vim.fn.fnameescape(vim.v.servername)
  local cwd = vim.fn.fnameescape(vim.fn.getcwd(-1, -1))
  if is_windows() then
    server = sanitize(server)
    cwd = sanitize(cwd)
  end

  local args = {
    files = files,
    response_pipe = server,
    guest_cwd = cwd,
    stdin = stdin,
    argv = vim.v.argv,
    force_block = force_block,
  }

  if config.callbacks.guest_data then
    args.data = config.callbacks.guest_data()
  end

  local call = string.format(
    [[return require('flatten.core').edit_files(%s)]],
    vim.inspect(args)
  )

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  local block = M.exec_on_host(call) or force_block
  M.maybe_block(block)
end

function M.send_commands()
  local server = vim.fn.fnameescape(vim.v.servername)
  local cwd = vim.fn.fnameescape(vim.fn.getcwd(-1, -1))
  if is_windows() then
    server = sanitize(server)
    cwd = sanitize(cwd)
  end

  local args = {
    response_pipe = server,
    guest_cwd = cwd,
    argv = vim.v.argv,
  }

  local call = string.format(
    [[return require('flatten.core').run_commands(%s)]],
    vim.inspect(args)
  )

  M.exec_on_host(call)
end

function M.sockconnect(host_pipe)
  return pcall(vim.fn.sockconnect, "pipe", host_pipe, { rpc = true })
end

function M.init(host_pipe)
  -- Connect to host process
  if type(host_pipe) == "number" then
    host = host_pipe
  else
    local ok
    ok, host = M.sockconnect(host_pipe)
    -- Return on connection error
    if not ok then
      return
    end
  end

  if config.callbacks.should_nest and config.callbacks.should_nest(host) then
    return
  end

  -- Get new files
  local files = vim.fn.argv()
  local nfiles = #files

  vim.api.nvim_create_autocmd("StdinReadPost", {
    pattern = "*",
    callback = function()
      local readlines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
      M.send_files(files, readlines)
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    once = true,
    callback = function()
      local function filter_map(tbl, f)
        local result = {}
        for _, v in ipairs(tbl) do
          local r = f(v)
          if r ~= nil then
            table.insert(result, r)
          end
        end
        return result
      end
      files = filter_map(vim.api.nvim_list_bufs(), function(buffer)
        if not vim.api.nvim_buf_is_valid(buffer) then
          return
        end
        ---@diagnostic disable-next-line: deprecated
        local buftype = vim.api.nvim_buf_get_option(buffer, "buftype")
        if buftype ~= "" and buftype ~= "acwrite" then
          return
        end
        local name = vim.api.nvim_buf_get_name(buffer)
        ---@diagnostic disable-next-line: deprecated
        if name ~= "" and vim.api.nvim_buf_get_option(buffer, "buflisted") then
          return name
        end
      end)
      nfiles = #files

      -- No arguments, user is probably opening a nested session intentionally
      -- Or only piping input from stdin
      if nfiles < 1 then
        local should_nest, should_block = config.nest_if_no_args, false

        if config.callbacks.no_files then
          local result = M.exec_on_host(
            ("return require'flatten'.config.callbacks.no_files(%s)"):format(
              vim.inspect({
                argv = vim.v.argv,
              })
            )
          )
          if type(result) == "boolean" then
            should_nest = result
          elseif type(result) == "table" then
            should_nest = result.nest
            should_block = result.block
          end
        end
        if should_nest == true then
          return
        end
        M.send_commands()
        M.maybe_block(should_block)
      end

      M.send_files(files, {})
    end,
  })
end

return M
