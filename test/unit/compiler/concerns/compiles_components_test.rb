require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"

class CompilesComponentsTest < TestCase
  def test_end
    assert_compiles_to "<x-button a=b />", ""
  end
end
