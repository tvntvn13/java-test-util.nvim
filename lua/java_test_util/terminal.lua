---Terminal from toggleterm
---[toggleterm.nvim - Terminal](https://github.com/akinsho/toggleterm.nvim/blob/main/lua/toggleterm/terminal.lua#L76-L103)
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

---@type java_test_util.Config
local shared = require("java_test_util.shared")

---@type string|nil
M.last_test_command = nil

---@type string|nil
M.last_test_component = nil

---@type TestType|nil
M.last_test_type = nil

---@type Terminal
local terminal = require("toggleterm.terminal").Terminal

---@param command string
---@param component string
---@param type string
---@return Terminal
function M.run_command_in_terminal(command, component, type)
  local timeoutlen = shared.config.timeout_len or 2000
  M.last_test_command = command
  M.last_test_component = component
  M.last_test_type = type

  if not history.check_for_duplicate(command, component, type) then
    history.save_to_history(command, component, type)
  end

  -- Create terminal configuration by merging user config with defaults
  local terminal_config = vim.tbl_deep_extend("force", {
    cmd = command,
    float_opts = {},
    on_open = function(term)
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "n",
        shared.config.close_key,
        "<cmd>close<cr>",
        { noremap = true, silent = true }
      )
      vim.cmd("stopinsert")
    end,
    on_close = function(_)
      vim.cmd("startinsert!")
    end,
    on_stderr = function(_, _, _, _)
      vim.notify(" Test failed")
    end,
    on_exit = function(_, _, exit_code, _)
      if exit_code == 0 then
        utils.show_message_until(" Tests passed", timeoutlen)
      elseif exit_code == 1 then
        utils.show_message_until(" Tests failed", timeoutlen, vim.log.levels.ERROR)
      end
    end,
  }, shared.config.terminal or {})

  local float_term = terminal:new(terminal_config)

  if shared.config.terminal.hidden == true then
    float_term:spawn()
  else
    float_term:toggle()
  end

  function _Toggle_term()
    float_term:toggle()
  end

  vim.api.nvim_set_keymap(
    "n",
    shared.config.toggle_key,
    "<cmd>lua _Toggle_term()<cr>",
    { desc = "Toggle terminal", noremap = true, silent = true }
  )

  return float_term
end

return M
