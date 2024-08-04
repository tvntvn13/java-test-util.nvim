# java-test-util.nvim

![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
<img src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white">

[![stylua](https://github.com/tvntvn13/java-test-util.nvim/actions/workflows/stylua.yml/badge.svg)](https://github.com/tvntvn13/java-test-util.nvim/actions/workflows/stylua.yml)

Plugin to run Java tests in a toggleterm, on the background or on a floating terminal.
Currently only supports Maven projects.

> \[!WARNING\]
>
> - plugin is in beta stage and not stable
> - changes will happen

## Installation

### Lazy

```lua
  {
    "tvntvn13/java-test-util.nvim",
    ft = { "java" },
    config = function()
      require("java_test_util").setup({})
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "akinsho/toggleterm.nvim",
    },
  },
```

### Default config

> \[!NOTE\]
>
> - plugin currently only supports floating terminal

```lua
local config = {
  use_maven_wrapper = false, 
  hide_terminal = true, 
  terminal_height = 25,
  terminal_width = 90,
  terminal_border = "curved", 
  display_name = "mvn test", 
  title_pos = "center",
  direction = "float",
  auto_scroll = true,
  close_on_exit = false,
  timeout_len = 5000,
  toggle_key = "<leader>Mm",
  close_key = "q",
}
```

### Commands

Plugin exposes 4 commands to run maven tests:

- **MvnRunMethod** -- _run test for current method_
- **MvnRunClass** -- _run tests for current class_
- **MvnRunPackage** -- _run tests for current package_
- **MvnRunAll** -- _run all tests_

#### Keymaps

You can set keymaps to these commands for example:

```lua
vim.api.nvim_set_keymap("n", "<leader>Mt", "<cmd>MvnRunMethod<cr>", { desc = "Run tests for current method", noremap = true, silent = true})
```
