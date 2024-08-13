local M = {}

local term = require("java_test_util.terminal")
local util = require("java_test_util.util")

function M.run_mvn_test_for_current_method()
  local class_name, method_name = util.get_method_name_from_cursor_position()

  if class_name == "" or method_name == "" then
    util.show_message_until("No method found", 2000)
    return
  end

  local test_command = util.build_test_command_string(M.config, "method", nil, class_name, method_name)

  term.run_command_in_terminal(test_command, method_name)

  vim.notify("󰂓 running test: " .. method_name)
end

function M.run_mvn_test_for_current_class()
  local file_path = util.get_filepath()
  local class_name = util.get_class_name_from_path(file_path)
  local test_command = util.build_test_command_string(M.config, "class", nil, class_name)

  term.run_command_in_terminal(test_command, class_name)

  vim.notify("󰂓 running tests for class: " .. class_name)
end

function M.run_mvn_test_for_current_package()
  local package_name = util.get_package_name()
  local test_command = util.build_test_command_string(M.config, "package", package_name)

  term.run_command_in_terminal(test_command, package_name)

  vim.notify("󰂓 running tests for package: " .. package_name)
end

function M.run_mvn_previous_test()
  if term.last_test_command and term.last_test_component then
    vim.notify("Rerunning tests for: " .. term.last_test_component)
    term.run_command_in_terminal(term.last_test_command, term.last_test_component)
  else
    util.show_message_until("No previous test to run", 2000)
  end
end

function M.run_mvn_test_for_all()
  local test_command = util.build_test_command_string(M.config, "all")
  term.run_command_in_terminal(test_command, "all")

  vim.notify("󰂓 running All tests")
end

return M
