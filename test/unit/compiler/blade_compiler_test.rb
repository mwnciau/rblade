require "test_case"
require "rblade/compiler"

class BladeTemplatingTest < TestCase
  def test_strings_are_escaped
    assert_compiles_to %(\\'), "_out<<'\\\\\\'';", %(\\')
  end
end
