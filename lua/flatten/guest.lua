local M = {}

local waiting = false
local host

local function sanitize(path)
  return path:gsub("\\", "/")
end

local function maybe_block(block)
  if not block then
    vim.cmd.qa({ bang = true })
  end
  waiting = true
  local res, ctx = vim.wait(0X7FFFFFFF, function()
    return waiting == false
      or vim.api.nvim_get_chan_info(host) == vim.empty_dict()
  end, 200, false)
  if res then
    vim.cmd.qa({ bang = true })
  elseif ctx == -2 then
    vim.notify(
      "Waiting interrupted by user",
      vim.log.levels.WARN,
      { title = "flatten.nvim" }
    )
  end
end

local function send_files(files, stdin, quickfix)
  if #files < 1 and #stdin < 1 and #quickfix < 1 then
    return
  end
  local config = require("flatten").config

  local force_block = vim.g.flatten_wait ~= nil
    or config.hooks.should_block(vim.v.argv)

  local server = vim.fn.fnameescape(vim.v.servername)
  local cwd = vim.fn.fnameescape(vim.fn.getcwd(-1, -1))
  if jit.os == "Windows" then
    server = sanitize(server)
    cwd = sanitize(cwd)
  end

  local args = {
    files = files,
    response_pipe = server,
    guest_cwd = cwd,
    stdin = stdin,
    quickfix = quickfix,
    argv = vim.v.argv,
    force_block = force_block,
  }

  if config.hooks.guest_data then
    args.data = config.hooks.guest_data()
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_delete(buf, { force = true })
  end

  local block = require("flatten.rpc").exec_on_host(host, function(opts)
    return require("flatten.core").edit_files(opts)
  end, { args }, true) or force_block

  maybe_block(block)
end

local function send_commands()
  local server = vim.fn.fnameescape(vim.v.servername)
  local cwd = vim.fn.fnameescape(vim.fn.getcwd(-1, -1))
  if jit.os == "Windows" then
    server = sanitize(server)
    cwd = sanitize(cwd)
  end

  require("flatten.rpc").exec_on_host(host, function(args)
    return require("flatten.core").run_commands(args)
  end, {
    {
      response_pipe = server,
      guest_cwd = cwd,
      argv = vim.v.argv,
    },
  }, true)
end

function M.unblock()
  waiting = false
end

function M.init(host_pipe)
  -- Connect to host process
  if type(host_pipe) == "number" then
    host = host_pipe
  else
    local ok, chan = require("flatten.rpc").connect(host_pipe)
    if not ok then
      return
    end
    host = chan
  end

  local config = require("flatten").config

  if config.hooks.should_nest and config.hooks.should_nest(host) then
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

  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    once = true,
    callback = function()
      files = vim
        .iter(vim.api.nvim_list_bufs())
        :filter(function(buf)
          local buftype = vim.bo[buf].buftype
          if buftype ~= "" then
            return false
          end

          return true
        end)
        :map(function(buf)
          return vim.api.nvim_buf_get_name(buf)
        end)
        :filter(function(name)
          return name ~= ""
        end)
        :totable()
      nfiles = #files

      local quickfix = vim.iter(vim.api.nvim_list_bufs()):find(function(buf)
        return vim.bo[buf].filetype == "quickfix"
      end)

      -- No arguments, user is probably opening a nested session intentionally
      -- Or only piping input from stdin
      if nfiles < 1 and not quickfix then
        local should_nest, should_block = config.nest_if_no_args, false

        if config.hooks.no_files then
          local result = require("flatten.rpc").exec_on_host(
            host,
            function(argv)
              return require("flatten").config.hooks.no_files({
                argv = argv,
              })
            end,
            { vim.v.argv },
            true
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
        send_commands()
        maybe_block(should_block)
      end

      quickfix = vim
        .iter(vim.fn.getqflist())
        :map(function(old)
          return {
            filename = vim.api.nvim_buf_get_name(old.bufnr),
            module = old.module,
            lnum = old.lnum,
            end_lnum = old.end_lnum,
            col = old.col,
            end_col = old.end_col,
            vcol = old.vcol,
            nr = old.nr,
            text = old.text,
            pattern = old.pattern,
            type = old.type,
            valid = old.valid,
            user_data = old.user_data,
          }
        end)
        :totable()

      send_files(files, {}, quickfix)
    end,
  })
end

return M
