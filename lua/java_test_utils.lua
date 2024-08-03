local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local timeoutlen = 3000

---@param command string
local function run_command_in_terminal(command)
  local Terminal = require("toggleterm.terminal").Terminal
  local float_term = Terminal:new({
    cmd = command,
    hidden = false,
    display_name = "󰂓 mvn test",
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
  })
  float_term:toggle()
end

---@param file_path string
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

      print(" 󰂓 running test: " .. method_name .. "..")
      vim.defer_fn(function()
        vim.cmd("echo ''")
      end, timeoutlen)

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

  print(" 󰂓 running tests for class: " .. class_name .. "..")
  vim.defer_fn(function()
    vim.cmd("echo ''")
  end, timeoutlen)
end

function M.run_mvn_test_for_current_package()
  local file_path = vim.fn.expand("%:p")
  local path_components = {}

  for component in string.gmatch(file_path, "[^/]+") do
    table.insert(path_components, component)
  end

  local package_name = path_components[#path_components - 1]
  local test_command = "mvn test -Dtest=" .. "'" .. package_name .. "/*.java'"

  run_command_in_terminal(test_command)

  print(" 󰂓 running tests for package: " .. package_name .. "..")
  vim.defer_fn(function()
    vim.cmd("echo ''")
  end, timeoutlen)
end

function M.run_mvn_test_for_all()
  run_command_in_terminal("mvn test")

  print(" 󰂓 running All tests")
  vim.defer_fn(function()
    vim.cmd("echo ''")
  end, timeoutlen)
end

return M
