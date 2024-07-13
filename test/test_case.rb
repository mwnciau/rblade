require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use!

class TestCase < Minitest::Test
  def assert_compiles_to template, expected_code = nil, expected_result = nil
    compiledString = BladeCompiler.compileString(template)

    if expected_code
      assert_equal expected_code, compiledString
    end

    if expected_result
      result = eval "foo = 'FOO';bar = 'BAR';_out='';" + compiledString + ";_out"

      assert_equal expected_result, result
    end
  end
end
