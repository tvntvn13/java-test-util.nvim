local M = require("java_test_util.history")
local shared = require("java_test_util.shared")

local mock = require("luassert.mock")
local stub = require("luassert.stub")

describe("history:", function()
  before_each(function()
    vim = mock(vim, false)
    stub(vim, "notify")
  end)

  after_each(function()
    vim.notify:revert()
  end)

  it("should initialize correctly", function()
    -- Arrange
    -- Act
    require("java_test_util").setup({})
    -- Assert
    assert.equals(shared.config.max_history_size, 12)
    assert.are.same(M.cmd_history, {})
  end)

  it("should set the values from the config", function()
    -- Arrange
    -- Act
    require("java_test_util").setup({ max_history_size = 10 })
    assert.stub(vim.notify).was_called(1)
    assert
      .stub(vim.notify)
      .was_called_with("No build tool detected, disabling java-test-util.nvim", vim.log.levels.INFO)
    -- Assert
    assert.equals(shared.config.max_history_size, 10)
  end)
end)
