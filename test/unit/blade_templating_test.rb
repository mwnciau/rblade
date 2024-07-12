require_relative "../test_case"
require "lib/rblade"

class BladeTemplatingTest < TestCase
  def test_compile
    assert_equal "abcd", Blade.compile("abcd")
  end
end
