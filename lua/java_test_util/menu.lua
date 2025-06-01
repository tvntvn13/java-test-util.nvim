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

function M.create_popup()
  local build_icon = build_tool_icons[util.build_tool]

  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      padding = { 1, 0 },
      text = {
        top = " 󰂓 Test history ",
        top_align = "left",
        bottom = build_icon,
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
  })
  return popup
end

function M.delete_menu_item(_)
  history.load_cached_history()
  local description = vim.api.nvim_get_current_line()

  history.remove_from_history(description)

  local current_line = vim.fn.line(".")
  vim.api.nvim_buf_set_lines(M.popup.bufnr, current_line - 1, current_line, false, {})

  local total_lines = vim.api.nvim_buf_line_count(M.popup.bufnr)

  if current_line > total_lines then
    vim.api.nvim_win_set_cursor(0, { total_lines, 0 })
  end
end

function M.select_menu_item(_)
  local component = vim.api.nvim_get_current_line()
  local command = history.get_command_by_component(component)
  local type = history.get_type_by_component(component)

  if command then
    util.notify_tests_running(component, type)
    terminal.run_command_in_terminal(command, component, type)
  end
  if shared.config.auto_close_menu ~= false then
    M.popup:unmount()
  end
end

function M.create_history_menu()
  M.popup = M.create_popup()
  local descriptions = history.get_all_descriptions()

  M.popup:mount()

  vim.api.nvim_buf_set_lines(M.popup.bufnr, 0, -1, false, descriptions)
  vim.api.nvim_set_option_value("readonly", true, { buf = M.popup.bufnr })
  vim.api.nvim_set_option_value("modified", false, { buf = M.popup.bufnr })
  vim.api.nvim_set_option_value("modifiable", false, { buf = M.popup.bufnr })

  M.popup:map("n", "<cr>", function(_)
    M.select_menu_item(_)
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
