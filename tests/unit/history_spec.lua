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

  describe("multimodule history:", function()
    before_each(function()
      M.cmd_history = {}
    end)

    it("should save history with module information", function()
      -- Arrange
      local command = "mvn test -Dtest=TestClass -pl=module1"
      local component = "TestClass"
      local type = TestType.CLASS
      local module = "module1"
      -- Act
      M.save_to_history(command, component, type, module)
      -- Assert
      assert.equals(#M.cmd_history, 1)
      assert.equals(M.cmd_history[1].command, command)
      assert.equals(M.cmd_history[1].component, component)
      assert.equals(M.cmd_history[1].type, type)
      assert.equals(M.cmd_history[1].module, module)
    end)

    it("should save history without module for single module project", function()
      -- Arrange
      local command = "mvn test -Dtest=TestClass"
      local component = "TestClass"
      local type = TestType.CLASS
      local module = nil
      -- Act
      M.save_to_history(command, component, type, module)
      -- Assert
      assert.equals(#M.cmd_history, 1)
      assert.equals(M.cmd_history[1].command, command)
      assert.equals(M.cmd_history[1].component, component)
      assert.equals(M.cmd_history[1].type, type)
      assert.is_nil(M.cmd_history[1].module)
    end)

    it("should check for duplicates with module information", function()
      -- Arrange
      local command = "mvn test -Dtest=TestClass -pl=module1"
      local component = "TestClass"
      local type = TestType.CLASS
      local module = "module1"
      M.save_to_history(command, component, type, module)
      -- Act
      local is_duplicate = M.check_for_duplicate(command, component, type, module)
      -- Assert
      assert.is_true(is_duplicate)
    end)

    it("should not consider same component in different modules as duplicate", function()
      -- Arrange
      local command1 = "mvn test -Dtest=TestClass -pl=module1"
      local command2 = "mvn test -Dtest=TestClass -pl=module2"
      local component = "TestClass"
      local type = TestType.CLASS
      M.save_to_history(command1, component, type, "module1")
      -- Act
      local is_duplicate = M.check_for_duplicate(command2, component, type, "module2")
      -- Assert
      assert.is_false(is_duplicate)
    end)

    it("should get descriptions with module prefix", function()
      -- Arrange
      M.save_to_history("mvn test -Dtest=TestClass -pl=module1", "TestClass", TestType.CLASS, "module1")
      M.save_to_history("mvn test -Dtest=TestMethod -pl=module2", "TestMethod", TestType.METHOD, "module2")
      M.save_to_history("mvn test -Dtest=TestClass2", "TestClass2", TestType.CLASS, nil)

      -- Act
      local descriptions = M.get_all_descriptions()

      -- Assert
      assert.equals(#descriptions, 3)
      assert.equals(descriptions[1], "[module1] TestClass")
      assert.equals(descriptions[2], "[module2] TestMethod")
      assert.equals(descriptions[3], "TestClass2")
    end)

    it("should get command by component with module prefix", function()
      -- Arrange
      local command = "mvn test -Dtest=TestClass -pl=module1"
      M.save_to_history(command, "TestClass", TestType.CLASS, "module1")
      -- Act
      local found_command = M.get_command_by_component("[module1] TestClass")
      -- Assert
      assert.equals(found_command, command)
    end)

    it("should not write to history if call came from menu (module is '.')", function()
      -- Arrange
      M.cmd_history = {}
      local command = "mvn test -Dtest=TestClass -pl=module1"
      local component = "TestClass"
      local type = TestType.CLASS
      local module = "."
      -- Act
      M.save_to_history(command, component, type, module)
      -- Assert
      assert.equals(#M.cmd_history, 0)
    end)

    it("should get type by component with module prefix", function()
      -- Arrange
      M.save_to_history("mvn test -Dtest=TestClass -pl=module1", "TestClass", TestType.CLASS, "module1")
      -- Act
      local found_type = M.get_type_by_component("[module1] TestClass")
      -- Assert
      assert.equals(found_type, TestType.CLASS)
    end)

    it("should remove from history by component with module prefix", function()
      -- Arrange
      M.save_to_history("mvn test -Dtest=TestClass -pl=module1", "TestClass", TestType.CLASS, "module1")
      M.save_to_history("mvn test -Dtest=TestClass2", "TestClass2", TestType.CLASS, nil)
      -- Act
      M.remove_from_history("[module1] TestClass")
      -- Assert
      assert.equals(#M.cmd_history, 1)
      assert.equals(M.cmd_history[1].component, "TestClass2")
    end)
  end)
end)
