local util = require("java_test_util")
local history = require("java_test_util.history")

vim.api.nvim_create_user_command("MvnRunMethod", util.run_mvn_test_for_current_method, {
  desc = "Run tests for current method",
})

vim.api.nvim_create_user_command("MvnRunClass", util.run_mvn_test_for_current_class, {
  desc = "Run tests for current class",
})

vim.api.nvim_create_user_command("MvnRunPackage", util.run_mvn_test_for_current_package, {
  desc = "Run tests for current package",
})

vim.api.nvim_create_user_command("MvnRunPrev", util.run_mvn_previous_test, {
  desc = "Run previous test",
})

vim.api.nvim_create_user_command("MvnRunAll", util.run_mvn_test_for_all, {
  desc = "Run all tests",
})

vim.api.nvim_create_user_command("MvnOpenMenu", util.create_history_menu, {
  desc = "Open history menu",
})

vim.api.nvim_create_user_command("MvnDetectBuildTool", util.detect_build_tool, {
  desc = "Detect build tool",
})

vim.api.nvim_create_user_command("MvnRemoveCache", history.remove_cache_file, {
  desc = "Remove history cache file",
})
