require_relative "../../../../test_case"
require_relative "../../../../../lib/compiler/blade_compiler"

class CompilesInlineRubyTest < TestCase
  def test_inline_ruby
    assert_compiles_to "@ruby(_out = 'cake')", "_out = 'cake';", "cake"
    assert_compiles_to "@ruby ( _out = 'cake'; )", "_out = 'cake';", "cake"

    assert_compiles_to "foo @ruby(_out << 'bar')baz", nil, "foobarbaz"
    assert_compiles_to "foo  @ruby(_out << 'bar') baz", nil, "foo bar baz"

    assert_compiles_to "foo @ruby(
      _out << 'bar'
    )baz", nil, "foobarbaz"
  end
end
