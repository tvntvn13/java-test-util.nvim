local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local lsp_util = require("lspconfig.util")
local config = require("java_test_util.shared").config

---@enum TestType
TestType = {
  METHOD = "method",
  CLASS = "class",
  PACKAGE = "package",
  ALL = "all",
}

---@enum BuildTool
BuildTool = {
  GRADLE = "gradle",
  MAVEN = "mvn",
}

---@enum BuildToolWrapper
BuildToolWrapper = {
  GRADLE = "./gradlew",
  MAVEN = "./mvnw",
}

---@type string|nil
M.root_dir = nil

---@type BuildTool|nil
M.build_tool = config.build_tool or nil

---@param message string
---@param time integer
---@param level? integer
function M.show_message_until(message, time, level)
  vim.notify(message, level)
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

---@param type TestType
---@param package_name? string|nil
---@param class_name? string|nil
---@param method_name? string|nil
---@return string
local function build_maven_command(type, package_name, class_name, method_name)
  local test_runner = config.use_wrapper and BuildToolWrapper.MAVEN or BuildTool.MAVEN

  if type == TestType.ALL then
    return test_runner .. " test"
  elseif type == TestType.PACKAGE then
    return test_runner .. " test -Dtest=" .. "'" .. package_name .. "/*.java'"
  elseif type == TestType.CLASS then
    return test_runner .. " test -Dtest=" .. class_name
  elseif type == TestType.METHOD then
    return test_runner .. " test -Dtest=" .. class_name .. "#" .. method_name
  else
    return ""
  end
end

---@param type TestType
---@param package_name? string
---@param class_name? string
---@param method_name? string
---@return string
local function build_gradle_command(type, package_name, class_name, method_name)
  local test_runner = config.use_wrapper and BuildToolWrapper.GRADLE or BuildTool.GRADLE

  if type == TestType.ALL then
    return test_runner .. " test"
  elseif type == TestType.PACKAGE and package_name then
    return test_runner .. " test --tests '*." .. package_name .. ".*'"
  elseif type == TestType.CLASS and class_name then
    return test_runner .. " test --tests " .. class_name
  elseif type == TestType.METHOD then
    return test_runner .. " test --tests '*." .. class_name .. "." .. method_name .. "'"
  else
    return ""
  end
end

---@param type TestType
---@param package_name string|nil
---@param class_name string|nil
---@param method_name string|nil
---@return string
function M.build_test_command_string(type, package_name, class_name, method_name)
  if not M.build_tool then
    M.build_tool = M.detect_build_tool(M.root_dir)
  end

  ---@type string
  local command

  if M.build_tool == BuildTool.MAVEN then
    command = build_maven_command(type, package_name, class_name, method_name)
    return command
  elseif M.build_tool == BuildTool.GRADLE then
    command = build_gradle_command(type, package_name, class_name, method_name)
    return command
  else
    return ""
  end
end

---@return string|nil
function M.get_project_root()
  local root_dir_func = lsp_util.root_pattern({ ".git", ".mvn", "build.gradle", "gradlew", "mvnw", "pom.xml" })
  local root_dir = root_dir_func(M.get_filepath())

  if not root_dir then
    return nil
  end

  return root_dir
end

---@param root_dir string root of project
---@return BuildTool|nil
function M.detect_build_tool(root_dir)
  if config.build_tool then
    return config.build_tool
  end

  if not root_dir then
    return nil
  end

  M.root_dir = root_dir

  if lsp_util.path.exists(lsp_util.path.join(root_dir, "pom.xml")) then
    return BuildTool.MAVEN
  elseif lsp_util.path.exists(lsp_util.path.join(root_dir, "build.gradle")) then
    return BuildTool.GRADLE
  else
    return nil
  end
end

---@param component string
---@param type TestType
function M.notify_tests_running(component, type)
  if type == TestType.METHOD then
    vim.notify("󰂓 running test: " .. component)
  elseif type == TestType.CLASS then
    vim.notify("󰂓 running tests for class: " .. component)
  elseif type == TestType.PACKAGE then
    vim.notify("󰂓 running tests for package: " .. component)
  elseif type == TestType.ALL then
    vim.notify("󰂓 running All tests")
  end
end

---@return string
function M.get_filepath()
  return vim.fn.expand("%:p")
end

return M
