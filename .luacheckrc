ignore = {
  "631",  -- max_line_length
  --"212/_.*",  -- unused argument, for vars with "_" prefix
  "212", -- Unused argument, In the case of callback function, _arg_name is easier to understand than _, so this option is set to off.
  "121", -- setting read-only global variable 'vim'
  "122", -- setting read-only field of global variable 'vim'
}

-- Global objects defined by the C code
read_globals = {
  "vim",
}

globals = {
  "vim.g",
  "vim.b",
  "vim.w",
  "vim.o",
  "vim.bo",
  "vim.wo",
  "vim.go",
  "vim.env"
}
