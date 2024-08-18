---@class Config
---@field use_wrapper boolean
---@field hide_terminal boolean
---@field terminal_height number
---@field terminal_width number
---@field terminal_border string
---@field display_name string
---@field title_pos string
---@field direction string
---@field auto_scroll boolean
---@field close_on_exit boolean
---@field timeout_len number
---@field toggle_key string
---@field close_key string
---@field max_history_size number

---@type Config
local config = {
  use_wrapper = false,
  hide_terminal = true,
  terminal_height = 25,
  terminal_width = 90,
  terminal_border = "curved",
  display_name = "mvn test",
  title_pos = "center",
  direction = "float",
  auto_scroll = true,
  close_on_exit = false,
  timeout_len = 2000,
  toggle_key = "<leader>Mm",
  close_key = "q",
  max_history_size = 12,
}

return config
