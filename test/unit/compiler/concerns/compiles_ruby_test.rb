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

  def test_ruby_boundaries
    assert_compiles_to "@rubyhi@endruby", "@output_buffer.raw_buffer<<-'@rubyhi@endruby';"
    assert_compiles_to "@rubyhi @endruby", "@output_buffer.raw_buffer<<-'@rubyhi @endruby';"
    assert_compiles_to "a@ruby @endruby", "@output_buffer.raw_buffer<<-'a@ruby @endruby';"

    assert_compiles_to ">@ruby RUBY @endruby", "@output_buffer.raw_buffer<<-'>';RUBY;"
    assert_compiles_to "'@ruby RUBY @endruby", "@output_buffer.raw_buffer<<-'\\'';RUBY;"
    assert_compiles_to ".@ruby RUBY @endruby", "@output_buffer.raw_buffer<<-'.';RUBY;"
  end

  def test_ruby_directive_variations
    assert_compiles_to "@ruby some ruby @endruby", "some ruby;"
    assert_compiles_to "@RUBY some ruby @ENDRUBY", "some ruby;"
    assert_compiles_to "@ruby some ruby @endRuby", "some ruby;"
    assert_compiles_to "@Ruby some ruby @EndRuby", "some ruby;"
    assert_compiles_to "@ruby some ruby @end_ruby", "some ruby;"
    assert_compiles_to "@ruby some ruby @eNd_RuBy", "some ruby;"
  end
end
