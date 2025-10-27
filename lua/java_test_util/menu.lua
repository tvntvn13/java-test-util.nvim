local M = {}

local event = require("nui.utils.autocmd").event
local history = require("java_test_util.history")
local terminal = require("java_test_util.terminal")
local util = require("java_test_util.util")
local Popup = require("nui.popup")
local shared = require("java_test_util.shared")

local build_tool_icons = {
  mvn = "  ",
  gradle = "  ",
}

---returns popup table, more info and options on:
---[nui.nvim - Popup](https://github.com/MunifTanjim/nui.nvim/blob/main/lua/nui/popup/README.md)
---@return table Popup
function M.create_popup()
  local build_icon = build_tool_icons[util.build_tool]

  local popup_config = vim.tbl_deep_extend("force", {
    border = {
      text = {
        bottom = build_icon,
      },
    },
  }, shared.config.menu or {})

  local popup = Popup(popup_config)
  return popup
end

---@param bufnr number
---@param readonly boolean
local function set_readonly_buffer_option_value(bufnr, readonly)
  vim.api.nvim_set_option_value("readonly", readonly, { buf = bufnr })
  vim.api.nvim_set_option_value("modified", not readonly, { buf = bufnr })
  vim.api.nvim_set_option_value("modifiable", not readonly, { buf = bufnr })
end

function M.delete_menu_item()
  history.load_cached_history()

  local description = vim.api.nvim_get_current_line()
  history.remove_from_history(description)
  local current_line = vim.fn.line(".")

  set_readonly_buffer_option_value(M.popup.bufnr, false)
  vim.api.nvim_buf_set_lines(M.popup.bufnr, current_line - 1, current_line, false, {})

  local total_lines = vim.api.nvim_buf_line_count(M.popup.bufnr)
  if current_line > total_lines then
    vim.api.nvim_win_set_cursor(0, { total_lines, 0 })
  end

  set_readonly_buffer_option_value(M.popup.bufnr, true)
end

function M.select_menu_item(_)
  local component = vim.api.nvim_get_current_line()
  local command = history.get_command_by_component(component)
  local type = history.get_type_by_component(component)

  if command then
    util.notify_tests_running(component, type)
    terminal.run_command_in_terminal(command, component, type)
  end
  if shared.config.menu.auto_close ~= false then
    M.popup:unmount()
  end
end

function M.create_history_menu()
  M.popup = M.create_popup()
  local descriptions = history.get_all_descriptions()

  M.popup:mount()

  vim.api.nvim_buf_set_lines(M.popup.bufnr, 0, -1, false, descriptions)
  set_readonly_buffer_option_value(M.popup.bufnr, true)

  M.popup:map("n", "<cr>", function(_)
    M.select_menu_item()
  end, { noremap = true, silent = true })

  M.popup:map("n", "d", function()
    M.delete_menu_item()
  end)

  M.popup:map("n", "q", function(_)
    M.popup:unmount()
  end)

  M.popup:map("n", "<esc>", function(_)
    M.popup:unmount()
  end)

  M.popup:map("n", "<c-c>", function(_)
    M.popup:unmount()
  end)

  M.popup:on(event.BufLeave, function()
    M.popup:unmount()
  end)
end

return M
