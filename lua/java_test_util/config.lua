---@class TerminalConfig
---@field newline_chr string?
---@field direction string? the layout style for the terminal
---@field hidden boolean? whether or not to include this terminal in the terminals list
---@field close_on_exit boolean? whether or not to close the terminal window when the process exits
---@field auto_scroll boolean? whether or not to scroll down on terminal output
---@field float_opts table<string, any>?
---@field display_name string?
---@field env table<string, string>? environmental variables passed to jobstart()
---@field clear_env boolean? use clean job environment, passed to jobstart()
---@field on_stdout fun(t: Terminal, job: number, data: string[]?, name: string?)?
---@field on_stderr fun(t: Terminal, job: number, data: string[], name: string)?
---@field on_exit fun(t: Terminal, job: number, exit_code: number?, name: string?)?
---@field on_create fun(term:Terminal)?
---@field on_open fun(term:Terminal)?
---@field on_close fun(term:Terminal)?
---@field dir string? the directory for the terminal
---@field name string? the name of the terminal
---@field count number? the count that triggers that specific terminal
---@field highlights table<string, table<string, string>>?

---@class PopupBorderConfig
---@field style string? border style: "single", "double", "rounded", "solid", "shadow", "none", or table
---@field padding table<number>? padding around content [top, right, bottom, left] or [vertical, horizontal]
---@field text table? border text configuration
---@field highlight string? border highlight group

---@class PopupSizeConfig
---@field width number|string? width as number or percentage string
---@field height number|string? height as number or percentage string

---@class PopupPositionConfig
---@field row number|string? row position
---@field col number|string? column position

---@class MenuConfig
---@field auto_close boolean? whether to auto-close menu after selection
---@field enter boolean? whether to enter the popup window on mount
---@field focusable boolean? whether the popup window is focusable
---@field border PopupBorderConfig? border configuration
---@field position string|PopupPositionConfig? position: "50%" or table with row/col
---@field size PopupSizeConfig? size configuration
---@field relative string? what the popup is relative to: "editor", "win", "cursor"
---@field anchor string? anchor point: "NW", "NE", "SW", "SE"
---@field buf_options table<string, any>? buffer options
---@field win_options table<string, any>? window options
---@field zindex number? z-index for layering
---@field noautocmd boolean? disable autocmds during mount/unmount

---@class java_test_util.Config
---@field use_wrapper boolean whether to use the wrapper script for running tests
---@field timeout_len number how long to show messages in milliseconds
---@field toggle_key string the key to toggle the test terminal
---@field close_key string the key to close the test terminal
---@field max_history_size number the maximum number of test commands to keep in history
---@field auto_open boolean whether to open the terminal automatically or run in the background
---@field terminal TerminalConfig
---@field menu MenuConfig

---@type java_test_util.Config
local config = {
  use_wrapper = true,
  timeout_len = 2000,
  toggle_key = "<leader>Mm",
  close_key = "q",
  max_history_size = 12,
  auto_open = false,
  terminal = {
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
  },
  menu = {
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
  },
}

return config
