---https://github.com/akinsho/toggleterm.nvim/blob/main/lua/toggleterm/terminal.lua
---@class Terminal
---@field newline_chr string
---@field cmd string
---@field direction string the layout style for the terminal
---@field id number
---@field bufnr number
---@field window number
---@field job_id number
---@field highlights table<string, table<string, string>>
---@field dir string the directory for the terminal
---@field name string the name of the terminal
---@field count number the count that triggers that specific terminal
---@field hidden boolean whether or not to include this terminal in the terminals list
---@field close_on_exit boolean? whether or not to close the terminal window when the process exits
---@field auto_scroll boolean? whether or not to scroll down on terminal output
---@field float_opts table<string, any>?
---@field display_name string?
---@field env table<string, string> environmental variables passed to jobstart()
---@field clear_env boolean use clean job environment, passed to jobstart()
---@field on_stdout fun(t: Terminal, job: number, data: string[]?, name: string?)?
---@field on_stderr fun(t: Terminal, job: number, data: string[], name: string)?
---@field on_exit fun(t: Terminal, job: number, exit_code: number?, name: string?)?
---@field on_create fun(term:Terminal)?
---@field on_open fun(term:Terminal)?
---@field on_close fun(term:Terminal)?
---@field _display_name fun(term: Terminal): string
---@field __state TerminalState

---@class TerminalState
---@field mode Mode

---@alias Mode "n" | "i" | "?"

local M = {}

local history = require("java_test_util.history")
local utils = require("java_test_util.util")

---@type string|nil
M.last_test_command = nil

---@type string|nil
M.last_test_component = nil

---@type T_Type|nil
M.last_test_type = nil

---@type Terminal
local terminal = require("toggleterm.terminal").Terminal

---@param command string
---@param component string
---@param type string
---@return Terminal
function M.run_command_in_terminal(command, component, type)
  ---@type Config
  local config = M.config
  local timeoutlen = config.timeout_len or 2000
  M.last_test_command = command
  M.last_test_component = component
  M.last_test_type = type

  if not history.check_for_duplicate(command, component, type) then
    history.save_to_history(command, component, type)
  end

  local float_term = terminal:new({
    cmd = command,
    hidden = config.hide_terminal,
    _display_name = function(_)
      return " 󰂓 " .. component .. ":" .. type:upper()
    end,

    display_name = function(_)
      return " 󰂓 " .. component .. ":" .. type:upper()
    end,
    direction = config.direction,
    auto_scroll = config.auto_scroll,
    close_on_exit = config.close_on_exit,
    -- title = " 󰂓 " .. component .. type:upper(),
    float_opts = {
      border = config.terminal_border,
      height = config.terminal_height,
      width = config.terminal_width,
      title_pos = config.title_pos,
      title = " 󰂓 " .. component .. ":" .. type:upper(),
      display_name = " 󰂓 " .. component .. ":" .. type:upper(),
      float_name = " 󰂓 " .. component .. ":" .. type:upper(),
      float_title = " 󰂓 " .. component .. ":" .. type:upper(),
      highlights = {
        Normal = { link = "Normal" },
        FloatBorder = { link = "FloatBorder" },
      },
    },
    on_open = function(term)
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "n",
        config.close_key,
        "<cmd>close<cr>",
        { noremap = true, silent = true }
      )
      vim.cmd("stopinsert")
    end,
    on_close = function(_)
      vim.cmd("startinsert!")
    end,
    on_stderr = function(_, _, _, _)
      vim.notify(" Test failed")
    end,
    on_exit = function(_, _, exit_code, _)
      if exit_code == 0 then
        utils.show_message_until(" Tests passed", timeoutlen)
      elseif exit_code == 1 then
        utils.show_message_until(" Tests failed", timeoutlen, vim.log.levels.ERROR)
      end
    end,
  })

  if config.hide_terminal == true then
    float_term:spawn()
  else
    float_term:toggle()
  end

  --HACK: maybe fix this later
  function _Toggle_term()
    float_term:toggle()
  end

  vim.api.nvim_set_keymap(
    "n",
    config.toggle_key,
    "<cmd>lua Toggle_term()<cr>",
    { desc = "Toggle terminal", noremap = true, silent = true }
  )

  return float_term
end

return M
