# Flatten

Flatten allows you to open files from a neovim terminal buffer in your current neovim instance instead of a nested one in the terminal.

The name is inspired by the flatten function in Rust (and maybe other languages?), which flattens nested types (Option<Option<T>> -> Option<T>, etc).

It's heavily inspired by `nvim-unception`, but it's written in a different way. It uses modules and doesn't add any globals, which I think makes the codebase more convenient to work with and by extension less bug-prone.
