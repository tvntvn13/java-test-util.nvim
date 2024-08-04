local util = require("java_test_util")

vim.api.nvim_create_user_command("MvnRunMethod", util.run_mvn_test_for_current_method, {
  desc = "Run tests for current method",
})

vim.api.nvim_create_user_command("MvnRunClass", util.run_mvn_test_for_current_class, {
  desc = "Run tests for current class",
})

vim.api.nvim_create_user_command("MvnRunPackage", util.run_mvn_test_for_current_package, {
  desc = "Run tests for current package",
})

vim.api.nvim_create_user_command("MvnRunAll", util.run_mvn_test_for_all, {
  desc = "Run all tests",
})
