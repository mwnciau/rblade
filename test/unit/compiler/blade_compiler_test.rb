require_relative "../../test_case"
require_relative "../../../lib/compiler/blade_compiler"

class BladeTemplatingTest < TestCase
  def test_strings_are_escaped
    assert_compiles_to %(\\'), "_out<<'\\\\\\'';", %(\\')
  end
end
