local M = require("java_test_util.terminal")

local mock = require("luassert.mock")
local stub = require("luassert.stub")
local shared = require("java_test_util.shared")
-- local spy = require("luassert.spy")

describe("terminal:", function()
  local terminal, mock_term, mock_history, mock_utils
  before_each(function()
    vim = mock(vim, false)
    stub(vim, "notify")
    mock_utils = mock(require("java_test_util.util"), true)
    mock_history = mock(require("java_test_util.history"), true)
    terminal = mock(require("toggleterm.terminal").Terminal, true)
    mock_term = {
      spawn = function() end,
      toggle = function() end,
    }
    stub(vim.api, "nvim_set_keymap")
    stub(mock_term, "spawn")
    stub(mock_term, "toggle")
    stub(terminal, "new").returns(mock_term)
    stub(mock_history, "save_to_history")
    stub(mock_history, "check_for_duplicate").returns(false)
  end)

  after_each(function()
    terminal.new:revert()
    mock_term.spawn:revert()
    mock_term.toggle:revert()
    mock_history.save_to_history:revert()
    mock_history.check_for_duplicate:revert()
    mock_utils.get_current_module:revert()
    vim.api.nvim_set_keymap:revert()
    vim.notify:revert()
  end)

  it("should initialize correctly", function()
    -- Arrange
    -- Act
    require("java_test_util").setup({})
    -- Assert
    assert.equals(M.last_test_command, nil)
    assert.equals(M.last_test_component, nil)
    assert.equals(shared.config.close_key, "q")
    assert.equals(shared.config.use_wrapper, true)
  end)

  it("should store last command and component", function()
    -- Arrange
    -- Act
    M.run_command_in_terminal("mvn test", "all tests", TestType.ALL)
    -- Assert
    assert.equal(M.last_test_command, "mvn test")
    assert.equal(M.last_test_component, "all tests")
  end)

  it("should update last command and component", function()
    -- Arrange
    M.run_command_in_terminal("mvn test -Dtest=TestClass#TestMethod", "TestMethod", TestType.METHOD)
    assert.equals(M.last_test_component, "TestMethod")
    assert.equals(M.last_test_command, "mvn test -Dtest=TestClass#TestMethod")
    -- Act
    M.run_command_in_terminal("mvn test", "all tests", TestType.ALL)
    -- Assert
    assert.equal(M.last_test_command, "mvn test")
    assert.equal(M.last_test_component, "all tests")
    assert.stub(terminal.new).was_called(2)
  end)

  it("should run tests on the background if auto_open is false", function()
    -- Arrange
    require("java_test_util").setup({ auto_open = false })
    -- Act
    M.run_command_in_terminal("mvn test", "all tests", TestType.ALL)
    -- Assert
    assert.stub(mock_term.spawn).was_called()
  end)

  it("should run tests on the foreground if auto_open is true", function()
    -- Arrange
    require("java_test_util").setup({ auto_open = true })
    -- Act
    M.run_command_in_terminal("mvn test", "all tests", TestType.ALL)
    -- Assert
    assert.stub(mock_term.toggle).was_called()
  end)

  it("should set the default toggle keymap", function()
    -- Arrange
    require("java_test_util").setup({})
    -- Act
    M.run_command_in_terminal("mvn test", "all tests", TestType.ALL)
    -- Assert
    assert
      .stub(vim.api.nvim_set_keymap)
      .was_called_with("n", "<leader>Mm", "<cmd>lua _Toggle_term()<cr>", { desc = "Toggle terminal", noremap = true, silent = true })
  end)

  it("should set the custom keymap for toggle", function()
    -- Arrange
    require("java_test_util").setup({ toggle_key = "<c-t>" })
    -- Act
    M.run_command_in_terminal("mvn test", "all tests", TestType.ALL)
    -- Assert
    assert
      .stub(vim.api.nvim_set_keymap)
      .was_called_with("n", "<c-t>", "<cmd>lua _Toggle_term()<cr>", { desc = "Toggle terminal", noremap = true, silent = true })
  end)

  it("should reuse module from history when command is from menu", function()
    -- Arrange
    stub(mock_utils, "get_current_module").returns(".")
    mock_history.cmd_history = {
      { command = "mvn test -Dtest=TestClass", component = "TestClass", type = TestType.CLASS, module = "module1" },
    }
    -- Act
    M.run_command_in_terminal("mvn test -Dtest=TestClass", "TestClass", TestType.CLASS)
    -- Assert
    assert
      .stub(mock_history.check_for_duplicate)
      .was_called_with("mvn test -Dtest=TestClass", "TestClass", TestType.CLASS, ".")
  end)

  it("should get current module when command is not from menu", function()
    -- Arrange
    stub(mock_utils, "get_current_module").returns("current_module")
    mock_history.cmd_history = {
      { command = "mvn test -Dtest=OtherClass", component = "OtherClass", type = TestType.CLASS },
    }
    -- Act
    M.run_command_in_terminal("mvn test -Dtest=NewClass", "NewClass", TestType.CLASS)
    -- Assert
    assert.stub(mock_utils.get_current_module).was_called()
    assert
      .stub(mock_history.check_for_duplicate)
      .was_called_with("mvn test -Dtest=NewClass", "NewClass", TestType.CLASS, "current_module")
  end)
end)
