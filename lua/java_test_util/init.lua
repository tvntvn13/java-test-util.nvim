local default_config = require("java_test_util.config")
local core = require("java_test_util.core")
local term = require("java_test_util.terminal")
local menu = require("java_test_util.menu")
local util = require("java_test_util.util")
local history = require("java_test_util.history")

local M = {}

function M.setup(opts)
  ---@type Config
  M.config = vim.tbl_deep_extend("force", default_config, opts or {})
  core.config = M.config
  term.config = M.config
  history.config = M.config
  menu.config = M.config
  util.config = M.config

  util.root_dir = util.get_project_root()

  if util.root_dir then
    util.build_tool = util.detect_build_tool()
    history.load_cached_history()
  end
end

M.run_mvn_test_for_current_method = core.run_mvn_test_for_current_method
M.run_mvn_test_for_current_class = core.run_mvn_test_for_current_class
M.run_mvn_test_for_current_package = core.run_mvn_test_for_current_package
M.run_mvn_previous_test = core.run_mvn_previous_test
M.run_mvn_test_for_all = core.run_mvn_test_for_all
M.create_history_menu = menu.create_history_menu
M.detect_build_tool = util.detect_build_tool

return M
