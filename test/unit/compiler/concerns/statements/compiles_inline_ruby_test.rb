require "test_case"

class CompilesInlineRubyTest < TestCase
  def test_inline_ruby
    assert_compiles_to "@ruby(@output_buffer.raw_buffer << -'cake')", "@output_buffer.raw_buffer << -'cake';", "cake"
    assert_compiles_to "@ruby ( @output_buffer.raw_buffer << -'cake'; )", "@output_buffer.raw_buffer << -'cake';", "cake"

    assert_compiles_to "foo @ruby(@output_buffer.raw_buffer << 'bar')baz", nil, "foobarbaz"
    assert_compiles_to "foo  @ruby(@output_buffer.raw_buffer << 'bar')  baz", nil, "foo bar baz"

    assert_compiles_to "foo @ruby(
      @output_buffer.raw_buffer << 'bar'
    )baz", nil, "foobarbaz"
  end
end
