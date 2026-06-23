<!-- panvimdoc-ignore-start -->

[![LuaRocks](https://img.shields.io/luarocks/v/willothy/flatten.nvim?logo=lua&color=blue)](https://luarocks.org/modules/willothy/flatten.nvim)

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
> Flatten is undergoing some breaking changes on the road to the release of a stable 1.0.0.<br>
> See [#87](https://github.com/willothy/flatten.nvim/issues/87) for more info.

## Features

- [x] Open files from terminal buffers without creating a nested session
- [x] Allow blocking for git commits
- [x] Configuration
  - [x] Hooks for user-specific workflows
  - [x] Open in vsplit, split, tab, current window, or alternate window
- [x] Pipe from terminal into a new Neovim buffer<!-- panvimdoc-ignore-start --> ([demo](https://user-images.githubusercontent.com/38540736/225779817-ed7efea8-9108-4f28-983f-1a889d32826f.mp4)) <!-- panvimdoc-ignore-end -->
- [x] Setting to force blocking from the commandline, regardless of filetype
- [x] Command passthrough from guest to host
- [x] Flatten instances from wezterm and kitty tabs/panes based on working directory

## Installation[^1]

> Requires nvim >=0.10.

### [`folke/lazy.nvim`](https://github.com/folke/lazy.nvim)

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

### [`nvim-neorocks/rocks.nvim`](https://github.com/nvim-neorocks/rocks.nvim) (via [LuaRocks](https://luarocks.org/modules/willothy/flatten.nvim))

```vim
:Rocks install flatten.nvim
```

Then, in `plugins/flatten.lua`:

```lua
require("flatten").setup({
  -- your config
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
local flatten = require("flatten")

local config = {
  hooks = {
    should_block = flatten.hooks.should_block,
    should_nest = flatten.hooks.should_nest,
    pre_open = flatten.hooks.pre_open,
    post_open = flatten.hooks.post_open,
    block_end = flatten.hooks.block_end,
    no_files = flatten.hooks.no_files,
    guest_data = flatten.hooks.guest_data,
    pipe_path = flatten.hooks.pipe_path,
  },
  block_for = {
    gitcommit = true,
    gitrebase = true,
  },
  disable_cmd_passthrough = false,
  nest_if_no_args = false,
  nest_if_cmds = false,
  window = {
    open = "current",
    diff = "tab_vsplit",
    focus = "first",
  },
  integrations = {
    kitty = false,
    wezterm = false,
  },
}
```

### General

- `block_for`: `table<string, boolean>`:
  - Default includes `gitcommit` and `gitrebase` only.
  - Add a filetype to always block the guest when opening a file of that type.

- `nest_if_no_args`: `boolean` (default: `false`)
  - If true, will nest if no arguments are passed to `nvim`.

- `nest_if_cmds`: `boolean` (default: `false`)
  - If true, will nest with no args even if a command is passed to `nvim`.

- `disable_cmd_passthrough`: `boolean` (default: `false`)
  - If true, will not pass commands to the host instance.

### Integrations

- `integrations.wezterm`: `boolean` (default: `false`)
  - If true, [Wezterm] tabs running in the same working directory will be flattened into the same Neovim instance.

- `integrations.kitty`: `boolean` (default: `false`)
  - If true, [Kitty] tabs will be flattened into the same Neovim instance.
  - Flatten-by-cwd not supported on Kitty yet, PRs welcome.

### Window

- `window.open`: `"current"` | `"alternate"` | `"split"` | `"vsplit"` | `"tab"` | `"smart"` | `Flatten.OpenHandler`
  - The default is `"alternate"`.
  - `"alternate"`: Opens the file in the alternate (`<C-w>p`, `:h winnr()`) window.
  - `"current"`: Opens the file in the current window.
  - `"vsplit"`: Opens the file in a vertical split.
  - `"split"`: Opens the file in a horizontal split.
  - `"tab"`: Opens the file in a new tabpage.
  - `"smart"`: Automatically chooses between the alternate window, available other windows, and opening a new split.
  - `Flatten.OpenHandler`: `fun(opts: Flatten.OpenContext): window, buffer?`
    - A custom function that returns a window number and optionally a buffer.

- `window.diff`: `"split"` | `"vsplit"` | `"tab_split"` | `"tab_vsplit"` | `Flatten.OpenHandler`
  - The default is `"tab_vsplit"`.
  - `"split"`: Opens the file in a horizontal split.
  - `"vsplit"`: Opens the file in a vertical split.
  - `"tab_split"`: Opens the file in a new tabpage.
  - `"tab_vsplit"`: Opens the file in a new tabpage.
  - `Flatten.OpenHandler`: `fun(opts: Flatten.OpenContext): window, buffer?`
    - A custom function that returns a window number and optionally a buffer.

  - `Flatten.OpenContext`:
    - `files`: `string[]`
      - The list of files passed to the host.
    - `argv`: `string[]`
      - The full argv list from the *guest* instance.
    - `stdin_buf`: `Flatten.BufInfo?`
      - Info about the stdin buffer, if one was created.
    - `guest_cwd`: `string`
      - The current working directory of the guest instance.
    - `data`: `any`
      - The data passed to the host from the `guest_data` hook.

  - `Flatten.BufInfo`:
    - `fname`: `string`
    - `bufnr`: `integer`

- `window.focus`: `"first"` | `"last"`
  - The default is `"first"`.

### Hooks

Defaults are in `flatten.hooks`.

- `hooks.should_block`: `fun(argv: string[]): boolean`
  - Should return `true` if the guest should wait for the host to close the file.

- `hooks.should_nest`: `fun(host: channel): boolean`
  - Should return `true` if the guest should *not* be flattened into the same Neovim instance as the host.
    This is useful for customizing when files should be sent to a host instance and when they should be opened
    in a new one.

- `hooks.pre_open`: `fun(opts: Flatten.PreOpenContext): Flatten.Config?`
  - Called before opening files.
  - Returned config, if any, will be merged with the global config (for this file only).

  - `Flatten.PreOpenContext`:
    - `data`: `any`
      - The data passed to the host from the `guest_data` hook.

- `hooks.post_open`: `fun(opts: Flatten.PostOpenContext)`
  - Called after opening files.

  - `Flatten.PostOpenContext`:
    - `bufnr`: `integer`
      - The buffer number of the file that was opened.
    - `winnr`: `integer`
      - The window that the file was opened in.
    - `filetype`: `string`
      - The filetype of the file that was opened.
    - `is_blocking`: `boolean`
      - Whether the guest will be blocked while the host edits.
    - `is_diff`: `boolean`
      - Whether the files were opened in diff mode.
    - `data`: `any`
      - The data passed to the host from the `guest_data` hook.

- `hooks.block_end`: `fun(opts: Flatten.BlockEndContext)`
  - Called when the host closes the file.

  - `Flatten.BlockEndContext`:
    - `filetype`: `string`
      - The filetype of the file that was opened.
    - `data`: `any`
      - The data passed to the host from the `guest_data` hook.

- `hooks.no_files`: `fun(opts: Flatten.NoFilesArgs): Flatten.NoFilesBehavior`
  - Called when no files are passed to a guest instance, to determine what to do.

  - `Flatten.NoFilesArgs`:
    - `argv`: `string[]`

  - `Flatten.NoFilesBehavior`: `boolean` | `{ nest: boolean, block: boolean }`

- `hooks.guest_data`: `fun(): any`
  - Called when the guest sends data to the host, to allow custom data to be passed to the host.

- `hooks.pipe_path`: `fun(): string`
  - Called to determine whether an instance is a host or is a guest and should connect to a host.

## Advanced configuration examples

### Toggleterm

If you use a toggleable terminal and don't want the new buffer(s) to be opened in your current window, you can use the `alternate` mode instead of `current` to open in your last window. With this method, the terminal doesn't need to be closed and re-opened as it did with the [old example config](https://github.com/willothy/flatten.nvim/blob/c986f98bc1d1e2365dfb2e97dda58ca5d0ae24ae/README.md).

The only reason 'alternate' isn't the default is to avoid breaking people's configs. It may become the default at some point if that's something that people ask for (e.g., open an issue if you want that, or comment on one if it exists).

Note that when opening a file in blocking mode, such as a git commit, the terminal will be inaccessible. You can get the filetype from the bufnr or filetype arguments of the `post_open` hook to only close the terminal for blocking files, and the `block_end` hook to reopen it afterwards.

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
      hooks = {
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

### Pipe path

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
    if not vim.uv.fs_stat(addr) then
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
