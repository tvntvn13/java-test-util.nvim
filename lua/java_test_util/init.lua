local Default_config = require("java_test_util.config")
local Core = require("java_test_util.core")

local M = {}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", Default_config, opts or {})
  Core.config = M.config
  print("M.config: " .. vim.inspect(M.config))
end

M.run_mvn_test_for_current_method = Core.run_mvn_test_for_current_method
M.run_mvn_test_for_current_class = Core.run_mvn_test_for_current_class
M.run_mvn_test_for_current_package = Core.run_mvn_test_for_current_package
M.run_mvn_test_for_all = Core.run_mvn_test_for_all

return M
