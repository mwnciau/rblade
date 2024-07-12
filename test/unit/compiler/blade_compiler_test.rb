require_relative "../../test_case"
require_relative "../../../lib/compiler/blade_compiler"

class BladeTemplatingTest < TestCase
  def test_strings_are_escaped
    compiledString = BladeCompiler.compileString(%Q{\"})

    assert_equal "_out='';_out<<'\\\"';", compiledString

    result = eval compiledString + ";_out"
    expected = %Q{\\\"}
    assert_equal expected, result
  end
end
