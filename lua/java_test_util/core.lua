local M = {}

local term = require("java_test_util.terminal")
local util = require("java_test_util.util")

function M.run_mvn_test_for_current_method()
  local class_name, method_name = util.get_method_name_from_cursor_position()

  if class_name == "" or method_name == "" then
    util.show_message_until("No method found", 2000)
    return
  end

  local test_command = util.build_test_command_string(T_Type.METHOD, nil, class_name, method_name)

  term.run_command_in_terminal(test_command, method_name, T_Type.METHOD)
  util.notify_tests_running(method_name, T_Type.METHOD)
end

function M.run_mvn_test_for_current_class()
  local file_path = util.get_filepath()
  local class_name = util.get_class_name_from_path(file_path)
  local test_command = util.build_test_command_string(T_Type.CLASS, nil, class_name)

  term.run_command_in_terminal(test_command, class_name, T_Type.CLASS)
  util.notify_tests_running(class_name, T_Type.CLASS)
end

function M.run_mvn_test_for_current_package()
  local package_name = util.get_package_name()
  local test_command = util.build_test_command_string(T_Type.PACKAGE, package_name)

  term.run_command_in_terminal(test_command, package_name, T_Type.PACKAGE)
  util.notify_tests_running(package_name, T_Type.PACKAGE)
end

function M.run_mvn_previous_test()
  if term.last_test_command and term.last_test_component then
    vim.notify("󰂓 Re-running tests for: " .. term.last_test_component)
    term.run_command_in_terminal(term.last_test_command, term.last_test_component, term.last_test_type)
  else
    util.show_message_until("No previous test to run", 2000)
  end
end

function M.run_mvn_test_for_all()
  local test_command = util.build_test_command_string(T_Type.ALL, T_Type.ALL)
  term.run_command_in_terminal(test_command, T_Type.ALL, T_Type.ALL)
  util.notify_tests_running(T_Type.ALL, T_Type.ALL)
end

return M
