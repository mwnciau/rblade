require "minitest/autorun"
require "minitest/reporters"
require_relative "../lib/helpers/stack_manager"

class TestCase < Minitest::Test
  def assert_compiles_to template, expected_code = nil, expected_result = nil
    compiled_string = BladeCompiler.compileString(template)

    if expected_code
      assert_equal expected_code, compiled_string
    end

    if expected_result
      RBlade::StackManager.clear
      setup = "foo = 'FOO';bar = 'BAR';_out='';_stacks=[];"
      setdown = "RBlade::StackManager.get(_stacks) + _out"
      result = eval setup + compiled_string + setdown # standard:disable Security/Eval

      assert_equal expected_result, result
    end
  end
end
