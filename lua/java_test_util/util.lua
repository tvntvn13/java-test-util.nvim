local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")

---@param message string
---@param time integer
function M.show_message_until(message, time)
  print(message)
  vim.defer_fn(function()
    vim.cmd("echo ''")
  end, time)
end

---@param file_path string
---@return string
function M.get_class_name_from_path(file_path)
  local file_name = file_path:match("([^/]+)$")
  local class_name = file_name:gsub("%.java$", "")
  return class_name
end

---@return string, string
function M.get_method_name_from_cursor_position()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_node = ts_utils.get_node_at_cursor()

  while cursor_node do
    if cursor_node:type() == "method_declaration" then
      local method_name = vim.treesitter.get_node_text(cursor_node:field("name")[1], bufnr)
      local file_path = vim.fn.expand("%:p")
      local class_name = M.get_class_name_from_path(file_path)

      return class_name, method_name
    end
    cursor_node = cursor_node:parent()
  end
  return "", ""
end

---@return string
function M.get_package_name()
  local file_path = M.get_filepath()
  local path_components = {}

  for component in file_path:gmatch("[^/]+") do
    table.insert(path_components, component)
  end

  local package_name = path_components[#path_components - 1]

  return package_name
end

---@param config table
---@param type string
---@param package_name string|nil
---@param class_name string|nil
---@param method_name string|nil
---@return string
function M.build_test_command_string(config, type, package_name, class_name, method_name)
  local test_runner = config.use_maven_wrapper and "./mvnw" or "mvn"

  if type == "all" then
    return test_runner .. " test"
  elseif type == "package" then
    return test_runner .. " test -Dtest=" .. "'" .. package_name .. "/*.java'"
  elseif type == "class" then
    return test_runner .. " test -Dtest=" .. class_name
  elseif type == "method" then
    return test_runner .. " test -Dtest=" .. class_name .. "#" .. method_name
  else
    return ""
  end
end

---@return string
function M.get_filepath()
  return vim.fn.expand("%:p")
end

return M
