# simple-session.nvim

A simple and easy to use Neovim plugin to manage sessions:

1. Load a session `:SLoad`
2. Create a new session `:SCreate`
3. Delete a session `:SDelete`

Each of the 3 commands will prompt you for a session name. Auto completion for
saved sessions is supported. Just make sure `config.session_dir =
{your-saved-sessions-directory}` so it is set to your prefered directory to
store your sessions.

Install with [lazy.nvim](https://github.com/folke/lazy.nvim):

Add this in your init.lua or plugins.lua:

```lua
{
  "joao-lobao/simple-session",
  config = function()
    require("simple-session").setup()
  end
}
```

Below are the plugin properties defaults `config`. You can override the
configuration by changing the properties inside the setup function.

```lua
{
  "joao-lobao/simple-session",
  config = function()
    require("simple-session").setup({
        -- default configurations
        session_dir = vim.fn.stdpath("config") .. "/session/",
        save_session_on_exit = true,
        keymaps = {
            load = "",
            create = "",
            delete = "",
        },
    })
  end
}
```

Keymaps are set to empty strings by default. You can override them by changing
it on the config properties above or create your own keyamps for each of the 3
commands.
