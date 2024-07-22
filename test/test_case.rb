require "minitest/autorun"
require "minitest/reporters"
require "rblade/component_store"
require "rblade/helpers/stack_manager"

class TestCase < Minitest::Test
  def setup
    super

    RBlade::ComponentStore.add_path(File.join(File.dirname(__FILE__), "fixtures"))
  end

  def assert_compiles_to template, expected_code = nil, expected_result = nil
    compiled_string = RBlade::Compiler.compileString(template)

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
