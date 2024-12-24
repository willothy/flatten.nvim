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

---@param chan integer
---@param fn fun(...:any): ...:any # must not depend on upvalues
---@param args any[]
---@param blocking boolean
---@return any ...
function M.exec_on_host(chan, fn, args, blocking)
  local req = vim.fn.rpcnotify
  if blocking then
    req = vim.fn.rpcrequest
  end

  local code = vim.base64.encode(string.dump(fn, true))

  local res = req(
    chan,
    "nvim_exec_lua",
    string.format(
      [[
      return loadstring(vim.base64.decode('%s'))(...)
    ]],
      code
    ),
    args
  )

  if blocking then
    return res
  end
end

---@param pipe_addr string
---@return boolean, integer
function M.connect(pipe_addr)
  return pcall(vim.fn.sockconnect, "pipe", pipe_addr, { rpc = true })
end

return M
