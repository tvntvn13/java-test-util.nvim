local M = require("java_test_util.util")
local stub = require("luassert.stub")
local mock = require("luassert.mock")

local mockPath = "/postgres-demo/src/test/java/com/tvntvn/postgresdemo/api/ProjectControllerIntegrationTest.java"

describe("util:", function()
  before_each(function()
    vim = mock(vim, false)
    stub(vim, "notify")
    stub(vim.fn, "expand").returns(mockPath)
  end)

  after_each(function()
    vim.fn.expand:revert()
    vim.notify:revert()
  end)

  it("should initialize correctly", function()
    -- Arrange
    -- Act
    -- Assert
    assert.is_not_nil(M.get_filepath)
    assert.is_not_nil(M.get_class_name_from_path)
    assert.is_not_nil(M.get_package_name)
    assert.is_not_nil(M.show_message_until)
    assert.is_not_nil(M.build_test_command_string)
    assert.is_not_nil(M.get_method_name_from_cursor_position)
  end)

  it("should get the filepath correctly", function()
    -- Arrange
    -- Act
    local path = M.get_filepath()
    -- Assert
    assert.stub(vim.fn.expand).was_called(1)
    assert.equals(path, mockPath)
  end)

  it("should get package name correctly", function()
    -- Arrange
    -- Act
    local package_name = M.get_package_name()
    -- Assert
    assert.equals(package_name, "api")
  end)

  it("should get class name correctly", function()
    -- Arrange
    -- Act
    local file_path = M.get_filepath()
    local class_name = M.get_class_name_from_path(file_path)
    -- Assert
    assert.equals(class_name, "ProjectControllerIntegrationTest")
  end)

  it("should print the correct message", function()
    -- Arrange
    -- Act
    M.show_message_until("hello", 110, vim.log.levels.ERROR)
    -- Assert
    assert.stub(vim.notify).was_called_with("hello", 4)
    assert.stub(vim.notify).was_called(1)
  end)
end)
