# java-test-util.nvim

![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
<img src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white" alt="neovim logo">

[![build](https://github.com/tvntvn13/java-test-util.nvim/actions/workflows/tests.yml/badge.svg)](https://github.com/tvntvn13/java-test-util.nvim/actions/workflows/tests.yml)

Plugin to run Java tests in a toggleterm, on the background or on a floating terminal.
Currently only supports Maven projects.

> [!WARNING]
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

> [!NOTE]
>
> - plugin currently only supports floating terminal

```lua
local config = {
  use_wrapper = false,
  timeout_len = 2000,
  toggle_key = "<leader>Mm",
  close_key = "q",
  max_history_size = 12,
  terminal = {
    -- Default terminal configuration
    hidden = true,
    direction = "float",
    auto_scroll = true,
    close_on_exit = false,
    float_opts = {
      border = "curved",
      height = 25,
      width = 90,
      title_pos = "center",
      highlights = {
        Normal = { link = "Normal" },
        FloatBorder = { link = "FloatBorder" },
      },
    },
    -- You can override any terminal option here
    -- env = { MY_VAR = "value" },
    -- clear_env = false,
    -- on_create = function(term) end,
    -- etc.
  },
  menu = {
    -- Default menu/popup configuration
    auto_close = true,
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      padding = { 1, 0 },
      text = {
        top = " 󰂓 Test history ",
        top_align = "left",
        bottom_align = "right",
      },
    },
    position = "50%",
    size = {
      width = "40%",
      height = "25%",
    },
    buf_options = {
      filetype = "java-test",
    },
    win_options = {
      winhighlight = "Normal:CursorLineNr,FloatBorder:FloatBorder",
      cursorline = true,
      number = true,
    },
    -- You can override any nui.nvim Popup option here
    -- relative = "editor",
    -- anchor = "NW",
    -- zindex = 50,
    -- etc.
  },
}
```

### Commands

Plugin exposes 4 commands to run maven tests:

- **MvnRunMethod** -- _run test for current method_
- **MvnRunClass** -- _run tests for current class_
- **MvnRunPackage** -- _run tests for current package_
- **MvnRunPrev** -- _re-run previous tests_
- **MvnRunAll** -- _run all tests_

#### Keymaps

You can set keymaps to these commands for example:

```lua
vim.api.nvim_set_keymap("n", "<leader>Mt", "<cmd>MvnRunMethod<cr>", { desc = "Run tests for current method", noremap = true, silent = true})
```
