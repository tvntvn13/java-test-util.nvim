local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local terminal = require("toggleterm.terminal").Terminal

---@type string|nil
local last_test_command = nil

---@type string|nil
local last_test_component = nil

---@param message string
---@param time integer
local function show_message_until(message, time)
  print(message)
  vim.defer_fn(function()
    vim.cmd("echo ''")
  end, time)
end

---@param command string
---@param component string
local function run_command_in_terminal(command, component)
  local config = M.config
  local timeoutlen = M.config.timeoutlen or 5000
  last_test_command = command
  last_test_component = component

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
        show_message_until(" Tests passed", timeoutlen)
      elseif exit_code == 1 then
        show_message_until(" Tests failed", timeoutlen)
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

---@param file_path string
---@return string
local function get_class_name_from_path(file_path)
  local file_name = file_path:match("([^/]+)$")
  local class_name = file_name:gsub("%.java$", "")
  return class_name
end

function M.run_mvn_test_for_current_method()
  local mvn_command = M.config.use_maven_wrapper and "./mvnw" or "mvn"
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_node = ts_utils.get_node_at_cursor()

  while cursor_node do
    if cursor_node:type() == "method_declaration" then
      local method_name = vim.treesitter.get_node_text(cursor_node:field("name")[1], bufnr)
      local file_path = vim.fn.expand("%:p")
      local class_name = get_class_name_from_path(file_path)
      local test_command = mvn_command .. " test -Dtest=" .. class_name .. "#" .. method_name

      run_command_in_terminal(test_command, method_name)

      vim.notify("󰂓 running test: " .. method_name)
      break
    end
    cursor_node = cursor_node:parent()
  end
end

function M.run_mvn_test_for_current_class()
  local mvn_command = M.config.use_maven_wrapper and "./mvnw" or "mvn"
  local file_path = vim.fn.expand("%:p")
  local class_name = get_class_name_from_path(file_path)
  local test_command = mvn_command .. " test -Dtest=" .. class_name

  run_command_in_terminal(test_command, class_name)

  vim.notify("󰂓 running tests for class: " .. class_name)
end

function M.run_mvn_test_for_current_package()
  local mvn_command = M.config.use_maven_wrapper and "./mvnw" or "mvn"
  local file_path = vim.fn.expand("%:p")
  local path_components = {}

  for component in file_path:gmatch("[^/]+") do
    table.insert(path_components, component)
  end

  local package_name = path_components[#path_components - 1]
  local test_command = mvn_command .. " test -Dtest=" .. "'" .. package_name .. "/*.java'"

  run_command_in_terminal(test_command, package_name)

  vim.notify("󰂓 running tests for package: " .. package_name)
end

function M.run_mvn_previous_test()
  if last_test_command and last_test_component then
    vim.notify("Rerunning tests for: " .. last_test_component)
    run_command_in_terminal(last_test_command, last_test_component)
  else
    show_message_until("No previous test to run", 2000)
  end
end

function M.run_mvn_test_for_all()
  local mvn_command = M.config.use_maven_wrapper and "./mvnw" or "mvn"
  run_command_in_terminal(mvn_command .. " test", "all tests")

  vim.notify("󰂓 running All tests")
end

return M
