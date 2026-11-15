local M = {}

---@return boolean
function M.enabled()
  return require("flatten").config.integrations.rex == true
    and vim.env.REX_SESSION ~= nil
    and vim.env.REX_BLOCK ~= nil
end

---All blocks in the same Rex session open files in the first Neovim instance.
---@return string | integer | nil
function M.pipe_path()
  if not M.enabled() then
    return
  end
  -- hashed, since socket paths are limited to ~100 bytes
  local session = vim.fn.sha256(vim.env.REX_SESSION):sub(1, 12)
  return require("flatten.rpc").try_address("rex.nvim-" .. session, true)
end

---The Rex block this instance runs in.
---@return string?
function M.current_block()
  return vim.env.REX_BLOCK
end

---@param block string
function M.focus(block)
  local function warn(err)
    vim.schedule(function()
      vim.notify(
        string.format("Failed to focus Rex block %s: %s", block, err),
        vim.log.levels.WARN,
        { title = "flatten.nvim" }
      )
    end)
  end
  local ok, err = pcall(
    vim.system,
    { "rex", "block", "focus", block },
    { text = true },
    function(res)
      if res.code ~= 0 then
        warn(vim.trim(res.stderr or ""))
      end
    end
  )
  if not ok then
    warn(tostring(err))
  end
end

return M
