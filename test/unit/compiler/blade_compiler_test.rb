require "test_case"
require "rblade/compiler"

class BladeCompilerTest < TestCase
  def test_strings_are_escaped
    assert_compiles_to %(\\'), "@output_buffer.raw_buffer<<'\\\\\\'';", %(\\')
  end
end
