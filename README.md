# flatten.nvim

Flatten allows you to open files from a neovim terminal buffer in your current neovim instance instead of a nested one.

## Features

- [x] Open files from terminal buffers without creating a nested session
- [x] Allow blocking for git commits
- [x] Configuration
  - [x] Callbacks/hooks for user-specific workflows
  - [x] Open in vsplit, split, tab, current window, or alternate window
- [x] Pipe from terminal into a new Neovim buffer ([demo](https://user-images.githubusercontent.com/38540736/225779817-ed7efea8-9108-4f28-983f-1a889d32826f.mp4))
- [x] Setting to force blocking from the commandline, regardless of filetype
- [x] Command passthrough from guest to host

## Plans and Ideas

Ideas:

- [ ] Multi-screen support
  - [ ] Move buffers between Neovim instances in separate windows
  - [ ] Single cursor between Neovim instances in separate windows
- [ ] Flatten instances based on working directory

If you have an idea or feature request, open an issue with the `enhancement` tag!

## Demo

https://user-images.githubusercontent.com/38540736/224443095-91450818-f298-4e08-a951-ee3fcc607330.mp4

Config for demo [here](#advanced-configuration) (autodelete gitcommit on write and toggling terminal are not defaults)

## Installation[^1]

With `lazy.nvim`:

```lua

{
    'willothy/flatten.nvim',
    config = true,
    -- or pass configuration with
    -- opts = {  }
    -- Ensure that it runs first to minimize delay when opening file from terminal
    lazy = false, priority = 1001,
}

```

To avoid loading plugins in guest sessions you can use the following in your config:

```lua
-- If opening from inside neovim terminal then do not load all the other plugins
if os.getenv("NVIM") ~= nil then
    require('lazy').setup {
        {'willothy/flatten.nvim', config = true },
    }
    return
end

-- Otherwise proceed as normal
require('lazy').setup( --[[ your normal config ]] )
```

## Usage

```zsh
# open files normally
nvim file1 file2

# force blocking for a file
nvim --cmd 'let g:flatten_wait=1' file1

# enable blocking for $VISUAL
# allows edit-exec
# in your .bashrc, .zshrc, etc.
export VISUAL="nvim --cmd 'let g:flatten_wait=1'"

# enable manpage formatting
export MANPAGER="nvim +Man!"

# execute a command in the **host**, *before* opening files
nvim --cmd <cmd>

# execute a command on the **host**, *after* opening files
nvim +<cmd>
```

## Configuration

### Defaults

Flatten comes with the following defaults:

```lua
{
    callbacks = {
        ---@param argv table a list of all the arguments in the nested session
        should_block = function(argv)
          return false
        end,
        -- Called when a request to edit file(s) is received
        pre_open = function() end,
        -- Called after a file is opened
        -- Passed the buf id, win id, and filetype of the new window
        post_open = function(bufnr, winnr, filetype) end,
        -- Called when a file is open in blocking mode, after it's done blocking
        -- (after bufdelete, bufunload, or quitpre for the blocking buffer)
        block_end = function() end,
    },
    -- <String, Bool> dictionary of filetypes that should be blocking
    block_for = {
        gitcommit = true
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
        -- function(new_file_names, argv, stdin_buf_id, guest_cwd) -> bufnr, winnr?
        -- Only open the files, allowing you to handle window opening yourself.
        -- The first argument is an array of file names representing the newly opened files.
        -- The third argument is only provided when a buffer is created from stdin.
        -- IMPORTANT: For `block_for` to work, you need to return a buffer number OR a buffer number and a window number.
        --            The `winnr` return value is not required, `vim.fn.bufwinid(bufnr)` is used if it is not provided.
        --            The `filetype` of this buffer will determine whether block should happen or not.
        open = "current",
        -- Affects which file gets focused when opening multiple at once
        -- Options:
        -- "first"        -> open first file of new files (default)
        -- "last"         -> open last file of new files
        focus = "first"
    },
	-- Override this function to use a different socket to connect to the host
	-- On the host side this can return nil or the socket address.
	-- On the guest side this should return the socket address
        -- or a non-zero channel id from `sockconnect`
	-- flatten.nvim will detect if the address refers to this instance of nvim, to determine if this is a host or a guest
	pipe_path = require'flatten'.default_pipe_path,
    -- The `default_pipe_path` will treat the first nvim instance within a single kitty/wezterm session as the host
    -- You can configure this behaviour using the following:
	one_per = {
        kitty = true, -- Flatten all instance in the current Kitty session
        wezterm = true, -- Flatten all instance in the current Wezterm session
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
{
    'willothy/flatten.nvim',
    opts = {
        window = {
            open = "alternate"
        },
        callbacks = {
            should_block = function(argv)
                -- Note that argv contains all the parts of the CLI command, including
                -- Neovim's path, commands, options and files.
                -- See: :help v:argv

                -- In this case, we would block if we find the `-b` flag
                -- This allows you to use `nvim -b file1` instead of `nvim --cmd 'let g:flatten_wait=1' file1`
                return vim.tbl_contains(argv, "-b")

                -- Alternatively, we can block if we find the diff-mode option
                -- return vim.tbl_contains(argv, "-d")
            end,
            post_open = function(bufnr, winnr, ft, is_blocking)
                if is_blocking then
                    -- Hide the terminal while it's blocking
                    require("toggleterm").toggle(0)
                else
                    -- If it's a normal file, just switch to its window
                    vim.api.nvim_set_current_win(winnr)
                end

                -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
                -- If you just want the toggleable terminal integration, ignore this bit
                if ft == "gitcommit" then
                    vim.api.nvim_create_autocmd(
                        "BufWritePost",
                        {
                            buffer = bufnr,
                            once = true,
                            callback = function()
                                -- This is a bit of a hack, but if you run bufdelete immediately
                                -- the shell can occasionally freeze
                                vim.defer_fn(
                                    function()
                                        vim.api.nvim_buf_delete(bufnr, {})
                                    end,
                                    50
                                )
                            end
                        }
                    )
                end
            end,
            block_end = function()
                -- After blocking ends (for a git commit, etc), reopen the terminal
                require("toggleterm").toggle(0)
            end
        }
    }
}

```

#### `pipe_path`

## About

The name is inspired by the flatten function in Rust (and maybe other languages?), which flattens nested types (`Option<Option<T>>` -> `Option<T>`, etc).

The plugin itself is inspired by [`nvim-unception`](https://github.com/samjwill/nvim-unception), which accomplishes the same goal but functions a bit differently and doesn't allow as much configuration.

[^1]: Lazy loading this plugin is not recommended - flatten should always be loaded as early as possible. Starting the host is essentially overhead-free other than the setup() function as it leverages the RPC server started on init by Neovim, and loading plugins before this in a guest session will only result in poor performance.
