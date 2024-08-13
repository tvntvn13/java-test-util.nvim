local M = require("java_test_util.terminal")

-- local mock = require("luassert.mock")
local stub = require("luassert.stub")
-- local spy = require("luassert.spy")

describe("terminal:", function()
  local terminal, mock_term
  before_each(function()
    -- vim = mock(vim)
    terminal = require("toggleterm.terminal").Terminal
    mock_term = {
      spawn = function() end,
      toggle = function() end,
    }
    stub(vim.api, "nvim_set_keymap")
    stub(mock_term, "spawn")
    stub(mock_term, "toggle")
    stub(terminal, "new").returns(mock_term)
  end)

  after_each(function()
    terminal.new:revert()
    mock_term.spawn:revert()
    mock_term.toggle:revert()
    vim.api.nvim_set_keymap:revert()
  end)

  it("should initialize correctly", function()
    -- Arrange
    -- Act
    require("java_test_util").setup({})
    -- Assert
    assert.equals(M.last_test_command, nil)
    assert.equals(M.last_test_component, nil)
    assert.equals(M.config.close_key, "q")
    assert.equals(M.config.use_maven_wrapper, false)
  end)

  it("should store last command and component", function()
    -- Arrange
    -- Act
    M.run_command_in_terminal("mvn test", "all tests")
    -- Assert
    assert.equal(M.last_test_command, "mvn test")
    assert.equal(M.last_test_component, "all tests")
  end)

  it("should update last command and component", function()
    -- Arrange
    -- Act
    M.run_command_in_terminal("mvn test -Dtest=TestClass#TestMethod", "TestMethod")
    -- Assert
    assert.equals(M.last_test_component, "TestMethod")
    assert.equals(M.last_test_command, "mvn test -Dtest=TestClass#TestMethod")

    -- Arrange
    -- Act
    M.run_command_in_terminal("mvn test", "all tests")
    -- Assert
    assert.equal(M.last_test_command, "mvn test")
    assert.equal(M.last_test_component, "all tests")
    assert.stub(terminal.new).was_called(2)
  end)

  it("should run tests on the background if hide_terminal is true", function()
    -- Arrange
    require("java_test_util").setup({ hide_terminal = true })
    -- Act
    M.run_command_in_terminal("mvn test", "all tests")
    -- Assert
    assert.stub(mock_term.spawn).was_called()
  end)

  it("should run tests on the foreground if hide_terminal is false", function()
    -- Arrange
    require("java_test_util").setup({ hide_terminal = false })
    -- Act
    M.run_command_in_terminal("mvn test", "all tests")
    -- Assert
    assert.stub(mock_term.toggle).was_called()
  end)

  it("should set the default toggle keymap", function()
    -- Arrange
    require("java_test_util").setup({})
    -- Act
    M.run_command_in_terminal("mvn test", "all tests")
    -- Assert
    assert
        .stub(vim.api.nvim_set_keymap)
        .was_called_with("n", "<leader>Mm", "<cmd>lua Toggle_term()<cr>",
          { desc = "Toggle terminal", noremap = true, silent = true })
  end)

  it("should set the custom keymap for toggle", function()
    -- Arrange
    require("java_test_util").setup({ toggle_key = "<c-t>" })
    -- Act
    M.run_command_in_terminal("mvn test", "all tests")
    -- Assert
    assert
        .stub(vim.api.nvim_set_keymap)
        .was_called_with("n", "<c-t>", "<cmd>lua Toggle_term()<cr>",
          { desc = "Toggle terminal", noremap = true, silent = true })
  end)
end)
