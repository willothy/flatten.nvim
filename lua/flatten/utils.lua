local exec
if vim.api.nvim_exec2 then
  -- nvim_exec2 only exists in nvim 0.9+
  exec = vim.api.nvim_exec2
else
  exec = function(arg)
    vim.api.nvim_exec(arg, false)
  end
end
return {
  exec_cmd = function(cmd)
    cmd = cmd:gsub("\n", "\n\\")
    exec(cmd, {})
  end,
}
