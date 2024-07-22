require "test_case"
require "rblade/compiler"

class BladeTemplatingTest < TestCase
  def test_attributes_to_s
    assert_compiles_to "<x-attributes/>", nil, '<div ></div>'
    assert_compiles_to "<x-attributes a=b/>", nil, '<div a="b"></div>'
  end
end
