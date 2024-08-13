local M = {}

---@type string|nil
M.last_test_command = nil

---@type string|nil
M.last_test_component = nil

local terminal = require("toggleterm.terminal").Terminal
local utils = require("java_test_util.util")

---@param command string
---@param component string
function M.run_command_in_terminal(command, component)
  local config = M.config
  local timeoutlen = config.timeoutlen or 5000
  M.last_test_command = command
  M.last_test_component = component

  local float_term = terminal:new({
    cmd = command,
    hidden = config.hide_terminal,
    display_name = config.display_name,
    direction = config.direction,
    auto_scroll = config.auto_scroll,
    close_on_exit = config.close_on_exit,
    float_opts = {
      border = config.terminal_border,
      height = config.terminal_height,
      width = config.terminal_width,
      title_pos = config.title_pos,
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
        utils.show_message_until(" Tests failed", timeoutlen)
      end
    end,
  })

  if config.hide_terminal == true then
    float_term:spawn()
  else
    float_term:toggle()
  end

  --HACK: maybe fix this later
  function Toggle_term()
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
