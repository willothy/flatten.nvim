<!-- panvimdoc-ignore-start -->

<h1 align='center'>
  flatten.nvim
</h1>

<p align='center'>
  <b>Open files and command output from `:term`, <a href="https://github.com/wez/wezterm">Wezterm</a> and <a href="https://github.com/kovidgoyal/kitty">Kitty</a> in your current neovim instance</b>
</p>

<https://github.com/willothy/flatten.nvim/assets/38540736/b4e4e75a-9be2-478d-9098-7e421dd6d1d9>

Config for demo [here](#advanced-configuration-examples) (autodelete gitcommit on write and toggling terminal are not defaults)

<!-- panvimdoc-ignore-end -->

> **NOTE**<br>
> There will soon be breaking changes on main with the release of 1.0.0.<br>
> See [#87](https://github.com/willothy/flatten.nvim/issues/87) for more info.

## Features

- [x] Open files from terminal buffers without creating a nested session
- [x] Allow blocking for git commits
- [x] Configuration
  - [x] Callbacks/hooks for user-specific workflows
  - [x] Open in vsplit, split, tab, current window, or alternate window
- [x] Pipe from terminal into a new Neovim buffer<!-- panvimdoc-ignore-start --> ([demo](https://user-images.githubusercontent.com/38540736/225779817-ed7efea8-9108-4f28-983f-1a889d32826f.mp4)) <!-- panvimdoc-ignore-end -->
- [x] Setting to force blocking from the commandline, regardless of filetype
- [x] Command passthrough from guest to host
- [x] Flatten instances from wezterm and kitty tabs/panes based on working directory

## Installation[^1]

With `lazy.nvim`:

```lua
require("lazy").setup({
  {
    "willothy/flatten.nvim",
    config = true,
    -- or pass configuration with
    -- opts = {  }
    -- Ensure that it runs first to minimize delay when opening file from terminal
    lazy = false,
    priority = 1001,
  },
  --- ...
})

```

## Usage

Open files normally:

```bash
nvim file1 file2
```

Force blocking for a file:

```bash
# with a custom block handler, you can use `nvim -b file1 file2`
nvim --cmd 'let g:flatten_wait=1' file1
```

Open files in diff mode:

```bash
nvim -d file1 file2
```

Enable blocking for `$VISUAL`:

```bash
# with a custom block handler, you can use `export VISUAL="nvim -b"`
export VISUAL="nvim --cmd 'let g:flatten_wait=1'" # allows edit-exec <C-x><C-e>
```

Enable manpage formatting:

```bash
export MANPAGER="nvim +Man!"
```

Execute a command in the host instance, before opening files:

```bash
nvim --cmd <cmd>
```

Execute a command in the host instance, after opening files:

```bash
nvim +<cmd>
```

## Configuration

### Defaults

Flatten comes with the following defaults:

```lua
---Types:
--
-- Passed to callbacks that handle opening files
---@alias BufInfo { fname: string, bufnr: buffer }
--
-- The first argument is a list of BufInfo tables representing the newly opened files.
-- The third argument is a single BufInfo table, only provided when a buffer is created from stdin.
--
-- IMPORTANT: For `block_for` to work, you need to return a buffer number OR a buffer number and a window number.
--            The `winnr` return value is not required, `vim.fn.bufwinid(bufnr)` is used if it is not provided.
--            The `filetype` of this buffer will determine whether block should happen or not.
--
---@alias OpenHandler fun(files: BufInfo[], argv: string[], stdin_buf: BufInfo, guest_cwd: string):window, buffer
--
local config = {
  callbacks = {
    ---Called to determine if a nested session should wait for the host to close the file.
    ---@param argv table a list of all the arguments in the nested session
    ---@return boolean
    should_block = require("flatten").default_should_block,
    ---If this returns true, the nested session will be opened.
    ---If false, default behavior is used, and
    ---config.nest_if_no_args is respected.
    ---@type fun(host: channel):boolean
    should_nest = require("flatten").default_should_nest,
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
  -- <String, Bool> dictionary of filetypes that should be blocking
  block_for = {
    gitcommit = true,
    gitrebase = true,
  },
  -- Command passthrough
  allow_cmd_passthrough = true,
  -- Allow a nested session to open if Neovim is opened without arguments
  nest_if_no_args = false,
  -- Window options
  window = {
    -- Options:
    -- current        -> open in current window (default)
    -- alternate      -> open in alternate window (recommended)
    -- tab            -> open in new tab
    -- split          -> open in split
    -- vsplit         -> open in vsplit
    -- smart          -> smart open (avoids special buffers)
    -- OpenHandler    -> allows you to handle file opening yourself (see Types)
    --
    open = "current",
    -- Options:
    -- vsplit         -> opens files in diff vsplits
    -- split          -> opens files in diff splits
    -- tab_vsplit     -> creates a new tabpage, and opens diff vsplits
    -- tab_split      -> creates a new tabpage, and opens diff splits
    -- OpenHandler    -> allows you to handle file opening yourself (see Types)
    diff = "tab_vsplit",
    -- Affects which file gets focused when opening multiple at once
    -- Options:
    -- "first"        -> open first file of new files (default)
    -- "last"         -> open last file of new files
    focus = "first",
  },
  -- Override this function to use a different socket to connect to the host
  -- On the host side this can return nil or the socket address.
  -- On the guest side this should return the socket address
  -- or a non-zero channel id from `sockconnect`
  -- flatten.nvim will detect if the address refers to this instance of nvim, to determine if this is a host or a guest
  pipe_path = require("flatten").default_pipe_path,
  -- The `default_pipe_path` will treat the first nvim instance within a single kitty/wezterm session as the host
  -- You can configure this behaviour using the following opt-in integrations:
  one_per = {
    kitty = false, -- Flatten all instance in the current Kitty session
    wezterm = false, -- Flatten all instance in the current Wezterm session
  },
}

```

### Advanced configuration examples

#### Toggleterm

If you use a toggleable terminal and don't want the new buffer(s) to be opened in your current window, you can use the `alternate` mode instead of `current` to open in your last window. With this method, the terminal doesn't need to be closed and re-opened as it did with the [old example config](https://github.com/willothy/flatten.nvim/blob/c986f98bc1d1e2365dfb2e97dda58ca5d0ae24ae/README.md).

The only reason 'alternate' isn't the default is to avoid breaking people's configs. It may become the default at some point if that's something that people ask for (e.g., open an issue if you want that, or comment on one if it exists).

Note that when opening a file in blocking mode, such as a git commit, the terminal will be inaccessible. You can get the filetype from the bufnr or filetype arguments of the `post_open` callback to only close the terminal for blocking files, and the `block_end` callback to reopen it afterwards.

Here's my setup for toggleterm, including an autocmd to automatically close a git commit buffer on write:

```lua
local flatten = {
  "willothy/flatten.nvim",
  opts = function()
    ---@type Terminal?
    local saved_terminal

    return {
      window = {
        open = "alternate",
      },
      callbacks = {
        should_block = function(argv)
          -- Note that argv contains all the parts of the CLI command, including
          -- Neovim's path, commands, options and files.
          -- See: :help v:argv

          -- In this case, we would block if we find the `-b` flag
          -- This allows you to use `nvim -b file1` instead of
          -- `nvim --cmd 'let g:flatten_wait=1' file1`
          return vim.tbl_contains(argv, "-b")

          -- Alternatively, we can block if we find the diff-mode option
          -- return vim.tbl_contains(argv, "-d")
        end,
        pre_open = function()
          local term = require("toggleterm.terminal")
          local termid = term.get_focused_id()
          saved_terminal = term.get(termid)
        end,
        post_open = function(bufnr, winnr, ft, is_blocking)
          if is_blocking and saved_terminal then
            -- Hide the terminal while it's blocking
            saved_terminal:close()
          else
            -- If it's a normal file, just switch to its window
            vim.api.nvim_set_current_win(winnr)

            -- If we're in a different wezterm pane/tab, switch to the current one
            -- Requires willothy/wezterm.nvim
            require("wezterm").switch_pane.id(
              tonumber(os.getenv("WEZTERM_PANE"))
            )
          end

          -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
          -- If you just want the toggleable terminal integration, ignore this bit
          if ft == "gitcommit" or ft == "gitrebase" then
            vim.api.nvim_create_autocmd("BufWritePost", {
              buffer = bufnr,
              once = true,
              callback = vim.schedule_wrap(function()
                vim.api.nvim_buf_delete(bufnr, {})
              end),
            })
          end
        end,
        block_end = function()
          -- After blocking ends (for a git commit, etc), reopen the terminal
          vim.schedule(function()
            if saved_terminal then
              saved_terminal:open()
              saved_terminal = nil
            end
          end)
        end,
      },
    }
  end,
}
```

#### Pipe path

Flatten now checks for kitty and wezterm by default, but this is how it works.
If you use another terminal emulator or multiplexer, you can implement
your `pipe_path` function based on this.

```lua
local pipe_path = function()
  -- If running in a terminal inside Neovim:
  if vim.env.NVIM then
    return vim.env.NVIM
  end
  -- If running in a Kitty terminal,
  -- all tabs/windows/os-windows in the same instance of kitty
  -- will open in the first neovim instance
  if vim.env.KITTY_PID then
    local addr = ("%s/%s"):format(
      vim.fn.stdpath("run"),
      "kitty.nvim-" .. vim.env.KITTY_PID
    )
    if not vim.loop.fs_stat(addr) then
      vim.fn.serverstart(addr)
    end
    return addr
  end
end

```

## About

The name is inspired by the flatten function in Rust (and maybe other languages?), which flattens nested types (`Option<Option<T>>` -> `Option<T>`, etc).

The plugin itself is inspired by [`nvim-unception`](https://github.com/samjwill/nvim-unception), which accomplishes the same goal but functions a bit differently and doesn't allow as much configuration.

[^1]: Lazy loading this plugin is not recommended - flatten should always be loaded as early as possible. Starting the host is essentially overhead-free other than the setup() function as it leverages the RPC server started on init by Neovim, and loading plugins before this in a guest session will only result in poor performance.
