local default_config = require("java_test_util.config")
local core = require("java_test_util.core")
local menu = require("java_test_util.menu")
local util = require("java_test_util.util")
local history = require("java_test_util.history")
local shared = require("java_test_util.shared")

local M = {}

function M.setup(opts)
  ---@type java_test_util.Config
  shared.config = vim.tbl_deep_extend("force", default_config, opts or {})

  util.root_dir = util.get_project_root()
  if util.root_dir then
    util.build_tool = util.detect_build_tool(util.root_dir)
  end

  if not util.build_tool then
    vim.notify("No build tool detected, disabling java-test-util.nvim", vim.log.levels.INFO)
    M.disabled = true
    return
  end

  M.disabled = false

  history.load_cached_history()

  vim.api.nvim_create_user_command("JTRunMethod", core.run_mvn_test_for_current_method, {
    desc = "Run tests for current method",
  })

  vim.api.nvim_create_user_command("JTRunClass", core.run_mvn_test_for_current_class, {
    desc = "Run tests for current class",
  })

  vim.api.nvim_create_user_command("JTRunPackage", core.run_mvn_test_for_current_package, {
    desc = "Run tests for current package",
  })

  vim.api.nvim_create_user_command("JTRunPrev", core.run_mvn_previous_test, {
    desc = "Run previous test",
  })

  vim.api.nvim_create_user_command("JTRunAll", core.run_mvn_test_for_all, {
    desc = "Run all tests",
  })

  vim.api.nvim_create_user_command("JTOpenMenu", menu.create_history_menu, {
    desc = "Open history menu",
  })

  vim.api.nvim_create_user_command("JTDetectBuildTool", function()
    if util.build_tool then
      print("Current build tool: " .. util.build_tool)
    else
      print("No build tool detected")
    end
  end, {
    desc = "Detect build tool",
  })

  vim.api.nvim_create_user_command("JTRemoveCache", history.remove_cache_file, {
    desc = "Remove history cache file",
  })
end

function M.is_enabled()
  return not M.disabled
end

return M
