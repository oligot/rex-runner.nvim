# rex-runner.nvim

A [Rex](https://www.superlogical.com/rex/docs) port of
[vim-tmux-runner](https://github.com/christoomey/vim-tmux-runner): open a
scratch pane next to neovim and send it lines, commands or the current file
path. Talks to Rex through the `rex` CLI, so it only does something when neovim
runs inside a Rex pane (`$REX_BLOCK` is set).

## Install

```lua
-- lazy.nvim
{
  "oligot/rex-runner.nvim",
  cond = vim.env.REX_BLOCK ~= nil,
  opts = { default_maps = true },
}
```

## Options

```lua
require("rex-runner").setup {
  split = "below",   -- right, left, above, below
  ratio = 25,        -- percent of the split given to the runner
  label = "runner",  -- Rex block label
  default_maps = false,
}
```

## Commands and default maps

| Command | Map | Does |
|---|---|---|
| `:RexOpenRunner` | `<leader>or` | open the runner pane (reused if alive) |
| `:RexSendCommandToRunner` | `<leader>sc` | prompt for a command and run it |
| `:RexSendLinesToRunner` | `<leader>sl` | send the current line or visual selection |
| `:RexSendFile` | `<leader>sf` | send the current file's path |
| `:RexClearRunner` | `<leader>cr` | `clear` the runner |
| `:RexFocusRunner` | `<leader>fr` | focus the runner pane |
| `:RexKillRunner` | `<leader>kr` | close the runner pane |
| `:RexDetachRunner` | `<leader>dr` | forget the runner, keep the pane |
| `:RexAttachToPane` | `<leader>va` | pick an existing pane as the runner |

Everything is also available as functions on `require("rex-runner")` for
custom maps.

## License

MIT
