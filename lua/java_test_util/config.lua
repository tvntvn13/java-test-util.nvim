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

---@class Config
---@field use_wrapper boolean
---@field timeout_len number
---@field toggle_key string
---@field close_key string
---@field max_history_size number
---@field terminal TerminalConfig

---@type Config
local config = {
  use_wrapper = false,
  timeout_len = 2000,
  toggle_key = "<leader>Mm",
  close_key = "q",
  max_history_size = 12,
  terminal = {
    -- Default terminal configuration based on current usage
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
}

return config
