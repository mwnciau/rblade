require "minitest/autorun"
require "minitest/reporters"

class TestCase < Minitest::Test
  def assert_compiles_to template, expected_code = nil, expected_result = nil
    compiled_string = BladeCompiler.compileString(template)

    if expected_code
      assert_equal expected_code, compiled_string
    end

    if expected_result
      result = eval "foo = 'FOO';bar = 'BAR';_out='';" + compiled_string + "_out" # standard:disable Security/Eval

      assert_equal expected_result, result
    end
  end
end
