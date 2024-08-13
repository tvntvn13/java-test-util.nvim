local M = require("java_test_util.core")

local mock = require("luassert.mock")
local stub = require("luassert.stub")

describe("core:", function()
  local term, default_config

  before_each(function()
    term = mock(require("java_test_util.terminal"), true)
    stub(vim, "notify")
    stub(term, "run_command_in_terminal")
    require("java_test_util").setup({})
  end)

  after_each(function()
    vim.notify:revert()
  end)

  it("should load config correctly", function()
    default_config = require("java_test_util.config")
    -- Arrange
    -- Act
    -- Assert
    assert.are.same(M.config, default_config)
  end)

  it("should not rerun if no previous test", function()
    -- Arrange
    stub(require("java_test_util.util"), "show_message_until")
    -- Act
    M.run_mvn_previous_test()
    -- Assert
    assert.stub(vim.notify).was_not_called()
    assert.stub(require("java_test_util.util").show_message_until).was_called_with("No previous test to run", 2000)
  end)

  it("should run all tests", function()
    -- Arrange
    -- Act
    M.run_mvn_test_for_all()
    -- Assert
    assert.stub(vim.notify).was_called_with("󰂓 running All tests")
  end)

  it("should rerun the previous test", function()
    -- Arrange
    -- Act
    M.run_mvn_test_for_all()
    term.last_test_command = "mvn test"
    term.last_test_component = "all tests"

    M.run_mvn_previous_test()
    -- Assert
    assert.stub(vim.notify).was_called(2)
    assert.stub(vim.notify).was_called_with("Rerunning tests for: all tests")
  end)

  it("should run test for current package", function()
    -- Arrange
    local mock_command = "mvn test -Dtest='api/*.java'"
    stub(require("java_test_util.util"), "get_package_name").returns("api")
    stub(require("java_test_util.util"), "build_test_command_string").returns("mvn test -Dtest='api/*.java'")
    -- Act
    M.run_mvn_test_for_current_package()

    -- Assert
    assert.stub(term.run_command_in_terminal).was_called_with(mock_command, "api")
  end)

  it("should run test for current method", function()
    -- Arrange
    local mock_command = "mvn test -Dtest='ProjectControllerIntegrationTest#testMethod'"
    stub(require("java_test_util.util"), "get_method_name_from_cursor_position").returns(
      "ProjectControllerIntegrationTest",
      "testMethod"
    )
    stub(require("java_test_util.util"), "build_test_command_string").returns(
      "mvn test -Dtest='ProjectControllerIntegrationTest#testMethod'"
    )
    -- Act
    M.run_mvn_test_for_current_method()

    --Assert
    assert.stub(term.run_command_in_terminal).was_called_with(mock_command, "testMethod")
  end)

  it("should run test for current class", function()
    -- Arrange
    local mock_command = "mvn test -Dtest='ProjectControllerIntegrationTest'"
    stub(require("java_test_util.util"), "get_class_name_from_path").returns("ProjectControllerIntegrationTest")
    stub(require("java_test_util.util"), "build_test_command_string").returns(
      "mvn test -Dtest='ProjectControllerIntegrationTest'"
    )
    -- Act
    M.run_mvn_test_for_current_class()
    -- Assert
    assert.stub(term.run_command_in_terminal).was_called_with(mock_command, "ProjectControllerIntegrationTest")
  end)

  it("should handle case when not inside method", function()
    -- Arrange
    stub(require("java_test_util.util"), "get_method_name_from_cursor_position").returns("", "")
    stub(require("java_test_util.util"), "show_message_until")
    -- Act
    M.run_mvn_test_for_current_method()
    -- Assert
    assert.stub(require("java_test_util.util").show_message_until).was_called_with("No method found", 2000)
  end)
end)
