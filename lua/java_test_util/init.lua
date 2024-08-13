local default_config = require("java_test_util.config")
local core = require("java_test_util.core")
local term = require("java_test_util.terminal")

local M = {}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", default_config, opts or {})
  core.config = M.config
  term.config = M.config
end

M.run_mvn_test_for_current_method = core.run_mvn_test_for_current_method
M.run_mvn_test_for_current_class = core.run_mvn_test_for_current_class
M.run_mvn_test_for_current_package = core.run_mvn_test_for_current_package
M.run_mvn_previous_test = core.run_mvn_previous_test
M.run_mvn_test_for_all = core.run_mvn_test_for_all

return M
