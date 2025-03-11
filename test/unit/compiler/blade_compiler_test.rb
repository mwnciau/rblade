require "test_case"
require "rblade/compiler"

class BladeCompilerTest < TestCase
  def test_strings_are_escaped
    assert_compiles_to %(\\'), "@output_buffer.raw_buffer<<-'\\\\\\'';", %(\\')
  end

  def test_escape_quotes
    assert_equal "\\'", RBlade::escape_quotes("'")
    assert_equal "\\'Hello, World!\\'", RBlade::escape_quotes("'Hello, World!'")

    assert_equal "", RBlade::escape_quotes("")
    assert_equal "\\\x0", RBlade::escape_quotes("\x0")
  end
end
