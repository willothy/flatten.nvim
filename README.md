# Flatten

Flatten allows you to open files from a neovim terminal buffer in your current neovim instance instead of a nested one in the terminal.

The name is inspired by the flatten function in Rust (and maybe other languages?), which flattens nested types (`Option<Option<T>>` -> `Option<T>`, etc).

The plugin itself is heavily inspired by `nvim-unception`, which I think is great but found somewhat frustrating to work with. Flatten uses modules and doesn't add any globals, which I think makes the codebase more convenient to work with and by extension less bug-prone. It also offers lua configuration, and can be lazy loaded.

## Installation

With `lazy.nvim`:

```lua

  {
    'willothy/flatten.nvim',
    config = true
    -- or pass configuration with
    -- opts = {  }
  }

```


## Configuration

Flatten comes with the following defaults:

```lua
{
    callbacks = {-- Called by when a request is received
        pre_open = function() end,
        -- Called after a file is opened
        post_open = function(bufnr, winnr, filetype) end,
        -- Called when a file is open in blocking mode, after it's done blocking
        -- (after bufdelete, bufunload, or quitpre for the blocking buffer)
        block_end = function() end,
    },
    -- <String, Bool> dictionary of filetypes that should be blocking
    block_for = {
        gitcommit = true
    }
}
```

Similarly to `nvim-unception`, if you use a toggleable terminal and don't want the opened file(s) to be opened in the same window as your terminal buffer, you may want to use the `pre_open` callback to close the terminal. You can even reopen it immediately after the file is opened using the `post_open` callback for a truly seamless experience. 

Note that when opening a file in blocking mode, such as a git commit, the terminal will be inaccessible. You can get the filetype from the bufnr or filetype arguments of the `post_open` callback to only reopen the terminal for non-blocking files.

Here's my setup for toggleterm, including an autocmd to automatically close a git commit buffer on write:

```lua

opts = {
    callbacks = {
        pre_open = function()
            -- Close toggleterm when an external open request is received
            require("toggleterm").toggle(0)
        end,
        post_open = function(bufnr, winnr, ft)
            if ft == "gitcommit" then
                -- If the file is a git commit, create one-shot autocmd to delete it on write
                -- If you just want the toggleable terminal integration, ignore this bit and only use the
                -- code in the else block
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
            else
                -- If it's a normal file, then reopen the terminal, then switch back to the newly opened window
                -- This gives the appearance of the window opening independently of the terminal
                require("toggleterm").toggle(0)
                vim.api.nvim_set_current_win(winnr)
            end
        end,
        block_end = function()
            -- After blocking ends (for a git commit, etc), reopen the terminal
            require("toggleterm").toggle(0)
        end
    }
}

```
