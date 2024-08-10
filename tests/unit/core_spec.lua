local M = require("java_test_util.core")
local mock = require("luassert.mock")
local stub = require("luassert.stub")

describe("java_test_util", function()
  local config = {
    use_maven_wrapper = false,
    timeoutlen = 5000,
    hide_terminal = false,
    display_name = "Test Terminal",
    direction = "float",
    auto_scroll = true,
    close_on_exit = true,
    terminal_border = "curved",
    terminal_height = 30,
    terminal_width = 80,
    title_pos = "left",
    close_key = "q",
    toggle_key = "<leader>Mm",
  }

  local terminal, ts_utils

  before_each(function()
    M.config = config

    vim = mock(vim, false)
    stub(vim.api, "nvim_get_current_buf")
    stub(vim.api, "nvim_buf_set_keymap")
    stub(vim.api, "nvim_set_keymap")
    stub(vim, "notify")
    stub(vim.treesitter, "get_node_text")
    stub(vim.fn, "expand")
    stub(vim, "defer_fn")
    stub(vim, "cmd")
    ts_utils = stub(require("nvim-treesitter.ts_utils"), "get_node_at_cursor")
    terminal = stub(require("toggleterm.terminal"), "new")
  end)

  after_each(function()
    vim.api.nvim_get_current_buf:revert()
    vim.api.nvim_buf_set_keymap:revert()
    vim.api.nvim_set_keymap:revert()
    vim.notify:revert()
    vim.treesitter.get_node_text:revert()
    vim.fn.expand:revert()
    vim.defer_fn:revert()
    vim.cmd:revert()
  end)

  it("should load config correctly", function()
    assert.equals(M.config.terminal_border, "curved")
    assert.equals(M.config.direction, "float")
    assert.equals(M.config.use_maven_wrapper, false)
    assert.equals(M.config.timeoutlen, 5000)
  end)

  it("should run all tests", function()
    M.run_mvn_test_for_all()
    assert.stub(vim.notify).was_called_with("󰂓 running All tests")
  end)

  it("should rerun the previous test", function()
    M.run_mvn_test_for_all()

    M.run_mvn_previous_test()
    assert.stub(vim.notify).was_called_with("Rerunning tests for: all tests")
  end)

  it("should not rerun if no previous test", function()
    M.last_test_command = nil
    M.run_mvn_previous_test()
    -- assert.stub(vim.cmd).was_called_with("echo ''")
    assert.stub(vim.cmd).was_called_with("stopinsert")
  end)
end)
