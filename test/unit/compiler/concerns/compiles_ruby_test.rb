require "test_case"

class CompilesRubyTest < TestCase
  def test_block_ruby
    assert_compiles_to "@ruby @output_buffer.raw_buffer << -'cake' @endruby", "@output_buffer.raw_buffer << -'cake';", "cake"
    assert_compiles_to "@ruby @output_buffer.raw_buffer << -'cake';@endruby", "@output_buffer.raw_buffer << -'cake';", "cake"
    assert_compiles_to "@ruby @output_buffer.raw_buffer << -'cake'@endruby", "@output_buffer.raw_buffer << -'cake';", "cake"

    assert_compiles_to "foo @ruby @output_buffer.raw_buffer << 'bar' @endruby baz", nil, "foobarbaz"
    assert_compiles_to "foo  @ruby @output_buffer.raw_buffer << 'bar' @endruby  baz", nil, "foo bar baz"

    assert_compiles_to "foo @ruby
      @output_buffer.raw_buffer << 'bar'
    @endruby baz", nil, "foobarbaz"

    assert_compiles_to "hi@ruby.dev ho@endruby.com", nil, "hi@ruby.dev ho@endruby.com"
  end

  def test_escaped_block_ruby
    assert_compiles_to "@@ruby @output_buffer.raw_buffer << -'cake' @endruby", nil, "@ruby @output_buffer.raw_buffer << -'cake' @endruby"
    assert_compiles_to "@@ruby @output_buffer.raw_buffer << -'cake';@endruby", nil, "@ruby @output_buffer.raw_buffer << -'cake';@endruby"
    assert_compiles_to "@@ruby @output_buffer.raw_buffer << -'cake'@endruby", nil, "@ruby @output_buffer.raw_buffer << -'cake'@endruby"

    assert_compiles_to "foo @@ruby @output_buffer.raw_buffer << 'bar' @endruby baz", nil, "foo @ruby @output_buffer.raw_buffer << 'bar' @endruby baz"

    assert_compiles_to "foo @@ruby
      @output_buffer.raw_buffer << 'bar'
    @endruby baz", nil, "foo @ruby
      @output_buffer.raw_buffer << 'bar'
    @endruby baz"
  end

  def test_erb_style_tags
    assert_compiles_to "<% @output_buffer.raw_buffer << -'cake' %>", "@output_buffer.raw_buffer << -'cake';", "cake"
    assert_compiles_to "<% @output_buffer.raw_buffer << -'cake';%>", "@output_buffer.raw_buffer << -'cake';", "cake"
    assert_compiles_to "<% @output_buffer.raw_buffer << -'cake'%>", "@output_buffer.raw_buffer << -'cake';", "cake"

    assert_compiles_to "foo<% @output_buffer.raw_buffer << 'bar' %>baz", nil, "foobarbaz"
    assert_compiles_to "foo <% @output_buffer.raw_buffer << 'bar' %> baz", nil, "foo bar baz"

    assert_compiles_to "foo <%
      @output_buffer.raw_buffer << 'bar'
    %> baz", nil, "foo bar baz"
  end

  def test_erb_style_tags_with_no_spaces
    assert_compiles_to "<%@output_buffer.raw_buffer << -'cake'%>", "@output_buffer.raw_buffer << -'cake';", "cake"
  end

  def test_escaped_erb_style_tags
    assert_compiles_to "<%% @output_buffer.raw_buffer << -'cake' %%>", nil, "<% @output_buffer.raw_buffer << -'cake' %>"
    assert_compiles_to "<%% @output_buffer.raw_buffer << -'cake';%%>", nil, "<% @output_buffer.raw_buffer << -'cake';%>"
    assert_compiles_to "<%% @output_buffer.raw_buffer << -'cake'%%>", nil, "<% @output_buffer.raw_buffer << -'cake'%>"

    assert_compiles_to "foo <%% @output_buffer.raw_buffer << 'bar' %%> baz", nil, "foo <% @output_buffer.raw_buffer << 'bar' %> baz"

    assert_compiles_to "foo <%%
      @output_buffer.raw_buffer << 'bar'
    %%> baz", nil, "foo <%
      @output_buffer.raw_buffer << 'bar'
    %> baz"
  end

  def assert_ruby_found(template, expected = true)
    tokens = [Token.new(:unprocessed, template)]
    RBlade::CompilesRuby.new.compile!(tokens)

    assert_equal expected, tokens.any? { |t| t.type == :ruby }
  end

  def test_boundaries
    assert_ruby_found "@rubyhi@endruby", false
    assert_ruby_found "@rubyhi @endruby", false
    assert_ruby_found "a@ruby @endruby", false

    assert_compiles_to ">@ruby RUBY @endruby", "@output_buffer.raw_buffer<<'>';RUBY;"
    assert_compiles_to "'@ruby RUBY @endruby", "@output_buffer.raw_buffer<<'\\'';RUBY;"
    assert_compiles_to ".@ruby RUBY @endruby", "@output_buffer.raw_buffer<<'.';RUBY;"
  end

  def test_directive_variations
    assert_ruby_found "@ruby hi @endruby"
    assert_ruby_found "@RUBY hi @ENDRUBY"
    assert_ruby_found "@ruby hi @endRuby"
    assert_ruby_found "@Ruby hi @EndRuby"
    assert_ruby_found "@ruby hi @end_ruby"
  end
end
