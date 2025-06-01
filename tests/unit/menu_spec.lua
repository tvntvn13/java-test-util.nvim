local M = require("java_test_util.menu")

local mock = require("luassert.mock")
local stub = require("luassert.stub")
-- local spy = require("luassert.spy")

describe("menu:", function()
  local popup_mock, history_mock, terminal_mock, util_mock
  local TEST_METHOD = "TestMethod"

  before_each(function()
    vim = mock(vim, false)
    stub(vim, "notify")
    require("java_test_util").setup({})
    util_mock = mock(require("java_test_util.util"), true)
    popup_mock = mock(require("nui.popup"), true)
    history_mock = mock(require("java_test_util.history"), true)
    terminal_mock = mock(require("java_test_util.terminal"), true)
    stub(history_mock, "get_command_by_component").returns("mvn test -Dtest=TestClass#TestMethod")
    stub(history_mock, "get_type_by_component").returns(TestType.METHOD)
    stub(history_mock, "get_all_descriptions")
    stub(terminal_mock, "run_command_in_terminal")
    stub(util_mock, "notify_tests_running")
    stub(popup_mock, "mount")
    stub(popup_mock, "unmount")
    stub(popup_mock, "map")
    stub(popup_mock, "on")
    stub(M, "create_popup").returns(popup_mock)
    stub(vim.api, "nvim_set_option_value")
    stub(vim.api, "nvim_buf_set_lines")
    stub(vim.api, "nvim_get_current_line").returns(TEST_METHOD)
    stub(vim.api, "nvim_set_keymap")
  end)

  after_each(function()
    popup_mock.mount:revert()
    popup_mock.map:revert()
    popup_mock.on:revert()
    popup_mock.unmount:revert()
    history_mock.get_command_by_component:revert()
    history_mock.get_type_by_component:revert()
    history_mock.get_all_descriptions:revert()
    util_mock.notify_tests_running:revert()
    terminal_mock.run_command_in_terminal:revert()
    vim.api.nvim_buf_set_lines:revert()
    vim.api.nvim_get_current_line:revert()
    vim.api.nvim_set_option_value:revert()
    vim.notify:revert()
  end)

  it("should initialize correctly", function()
    -- Arrange
    -- Act
    -- Assert
    assert.is_not_nil(M.create_popup())
    assert.is_table(M.create_popup())
  end)

  it("should not mount the menu on setup", function()
    -- Arrange
    -- Act
    require("java_test_util").setup({})
    -- Assert
    assert.stub(popup_mock.mount).was_not_called()
  end)

  it("should mount the popup menu when called", function()
    -- Arrange
    -- Act
    M.create_history_menu()
    -- Assert
    assert.stub(popup_mock.mount).was_called(1)
    assert.stub(popup_mock.map).was_called(5)
    assert.stub(popup_mock.on).was_called(1)
    assert.stub(vim.api.nvim_buf_set_lines).was_called(1)
    assert.stub(vim.api.nvim_set_option_value).was_called(3)
  end)

  it("should show the history when mounted", function()
    -- Arrange
    -- Act
    M.create_history_menu()
    -- Assert
    assert.stub(popup_mock.map).was_called(5)
    assert.stub(history_mock.get_all_descriptions).was_called(1)
    assert.stub(vim.api.nvim_buf_set_lines).was_called(1)
    assert.stub(vim.api.nvim_set_option_value).was_called(3)
  end)

  it("should run correct command when item is selected", function()
    -- Arrange
    -- Act
    M.select_menu_item()
    -- Assert
    assert
      .stub(terminal_mock.run_command_in_terminal)
      .was_called_with("mvn test -Dtest=TestClass#TestMethod", TEST_METHOD, TestType.METHOD)
  end)

  it("should show correct info when item is selected", function()
    -- Arrange
    -- Act
    M.select_menu_item()
    -- Assert
    assert.stub(history_mock.get_command_by_component).was_called_with(TEST_METHOD)
    assert.stub(history_mock.get_type_by_component).was_called_with(TEST_METHOD)
    assert.stub(util_mock.notify_tests_running).was_called_with(TEST_METHOD, TestType.METHOD)
  end)
end)
