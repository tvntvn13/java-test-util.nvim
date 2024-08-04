local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local Terminal = require("toggleterm.terminal").Terminal
local timeoutlen = 5000

---@param message string
---@param time integer
local function show_message_until(message, time)
  print(message)
  vim.defer_fn(function()
    vim.cmd("echo ''")
  end, time)
end

---@param command string
local function run_command_in_terminal(command)
  local float_term = Terminal:new({
    cmd = command,
    hidden = true,
    display_name = "mvn test",
    direction = "float",
    auto_scroll = true,
    close_on_exit = false,
    float_opts = {
      border = "curved",
      height = 25,
      width = 90,
      title_pos = "center",
    },
    on_open = function(term)
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
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
  float_term:spawn()

  --HACK: maybe fix this later
  function Toggle_term()
    float_term:toggle()
  end

  vim.api.nvim_set_keymap(
    "n",
    "<leader>Mm",
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
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_node = ts_utils.get_node_at_cursor()

  while cursor_node do
    if cursor_node:type() == "method_declaration" then
      local method_name = vim.treesitter.get_node_text(cursor_node:field("name")[1], bufnr)
      local file_path = vim.fn.expand("%:p")
      local class_name = get_class_name_from_path(file_path)
      local test_command = "mvn test -Dtest=" .. class_name .. "#" .. method_name

      run_command_in_terminal(test_command)

      vim.notify("󰂓 running test: " .. method_name)
      break
    end
    cursor_node = cursor_node:parent()
  end
end

function M.run_mvn_test_for_current_class()
  local file_path = vim.fn.expand("%:p")
  local class_name = get_class_name_from_path(file_path)
  local test_command = "mvn test -Dtest=" .. class_name

  run_command_in_terminal(test_command)

  vim.notify("󰂓 running tests for class: " .. class_name)
end

function M.run_mvn_test_for_current_package()
  local file_path = vim.fn.expand("%:p")
  local path_components = {}

  for component in file_path:gmatch("[^/]+") do
    table.insert(path_components, component)
  end

  local package_name = path_components[#path_components - 1]
  local test_command = "mvn test -Dtest=" .. "'" .. package_name .. "/*.java'"

  run_command_in_terminal(test_command)

  vim.notify("󰂓 running tests for package: " .. package_name)
end

function M.run_mvn_test_for_all()
  run_command_in_terminal("mvn test")

  vim.notify("󰂓 running All tests")
end

return M
