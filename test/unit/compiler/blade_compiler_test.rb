require_relative "../../test_case"
require_relative "../../../lib/compiler/blade_compiler"

class BladeTemplatingTest < TestCase
  def test_strings_are_escaped
    compiledString = BladeCompiler.compileString(%(\\'))

    assert_equal "_out<<'\\\\\\'';", compiledString

    result = eval "_out='';#{compiledString}_out"
    expected = %(\\')
    assert_equal expected, result
  end
end
