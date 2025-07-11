local M = {}

---@class CommandHistoryItem
---@field command? string
---@field component? string
---@field type? string

local util = require("java_test_util.util")
local shared = require("java_test_util.shared")

---@type CommandHistoryItem[]|nil
M.cmd_history = {}

local max_size = shared.config.max_history_size or 10
local CACHE_PATH = "/java-test-util/"
local CACHE_SUFFIX = "_history.lua"

---@param command string
---@param component string
---@param type TestType
---@return boolean
function M.check_for_duplicate(command, component, type)
  for _, item in ipairs(M.cmd_history) do
    if item.command == command and item.component == component and item.type == type then
      return true
    end
  end
  return false
end

---@return string|nil
local function get_cache_path()
  local project_root

  if util.root_dir then
    project_root = util.root_dir
  else
    project_root = util.get_project_root()
  end

  if project_root then
    local cache_path = vim.fn.stdpath("cache") .. CACHE_PATH .. vim.fn.fnamemodify(project_root, ":t") .. CACHE_SUFFIX
    return cache_path
  end
  vim.notify("no project root found!", vim.log.levels.ERROR)
  return nil
end

function M.load_cached_history()
  local cache_path = get_cache_path()

  if not cache_path then
    vim.notify("no cache found", vim.log.levels.WARN)
    return nil
  end

  if cache_path and vim.fn.filereadable(cache_path) == 1 then
    local chunk = loadfile(cache_path)
    if chunk then
      local loaded_history = chunk()
      if type(loaded_history) == "table" then
        M.cmd_history = loaded_history
      end
    end
  end
end

function M.write_history_to_cache()
  local cache_path = get_cache_path()
  if not cache_path then
    vim.notify("no cache_path")
    return
  end

  if cache_path then
    vim.fn.mkdir(vim.fn.fnamemodify(cache_path, ":h"), "p")
    local serialized_history = "return " .. vim.inspect(M.cmd_history)
    vim.fn.writefile(vim.split(serialized_history, "\n"), cache_path)
  end
end

function M.remove_cache_file()
  local cache_path = get_cache_path()
  if cache_path and vim.fn.filereadable(cache_path) == 1 then
    vim.fn.delete(cache_path)
    M.cmd_history = {}
    vim.notify("history file removed from: " .. cache_path)
  else
    vim.notify("no history file found for the current project", vim.log.levels.WARN)
  end
end

---@param command string
---@param component string
---@param type TestType
function M.save_to_history(command, component, type)
  if M.check_for_duplicate(command, component, type) then
    return
  end

  if #M.cmd_history >= max_size then
    table.remove(M.cmd_history, 1)
  end

  table.insert(M.cmd_history, { command = command, component = component, type = type })
  M.write_history_to_cache()
end

---@param component string
function M.remove_from_history(component)
  for i, item in ipairs(M.cmd_history) do
    if item.component == component then
      table.remove(M.cmd_history, i)
      M.write_history_to_cache()
      break
    end
  end
end

---@return table<string>
function M.get_all_descriptions()
  local descriptions = {}
  for _, item in ipairs(M.cmd_history) do
    table.insert(descriptions, item.component)
  end
  return descriptions
end

---@param component string
---@return string|nil
function M.get_command_by_component(component)
  for _, item in ipairs(M.cmd_history) do
    if item.component == component then
      return item.command
    end
  end
  return nil
end

---@param component string
---@return TestType|string
function M.get_type_by_component(component)
  for _, item in ipairs(M.cmd_history) do
    if item.component == component then
      return item.type
    end
  end
  return ""
end

return M
