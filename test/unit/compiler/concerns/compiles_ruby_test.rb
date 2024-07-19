require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"

class CompilesRubyTest < TestCase
  def test_block_ruby
    assert_compiles_to "@ruby _out = 'cake' @endruby", "_out = 'cake';", "cake"
    assert_compiles_to "@ruby _out = 'cake';@endruby", "_out = 'cake';", "cake"
    assert_compiles_to "@ruby _out = 'cake'@endruby", "_out = 'cake';", "cake"

    assert_compiles_to "foo @ruby _out << 'bar' @endruby baz", nil, "foobarbaz"
    assert_compiles_to "foo  @ruby _out << 'bar' @endruby  baz", nil, "foo bar baz"

    assert_compiles_to "foo @ruby
      _out << 'bar'
    @endruby baz", nil, "foobarbaz"

    assert_compiles_to "hi@ruby.dev ho@endruby.com", nil, "hi@ruby.dev ho@endruby.com"
  end

  def test_escaped_block_ruby
    assert_compiles_to "@@ruby _out = 'cake' @endruby", nil, "@ruby _out = 'cake' @endruby"
    assert_compiles_to "@@ruby _out = 'cake';@endruby", nil, "@ruby _out = 'cake';@endruby"
    assert_compiles_to "@@ruby _out = 'cake'@endruby", nil, "@ruby _out = 'cake'@endruby"

    assert_compiles_to "foo @@ruby _out << 'bar' @endruby baz", nil, "foo @ruby _out << 'bar' @endruby baz"

    assert_compiles_to "foo @@ruby
      _out << 'bar'
    @endruby baz", nil, "foo @ruby
      _out << 'bar'
    @endruby baz"
  end

  def test_erb_style_tags
    assert_compiles_to "<% _out = 'cake' %>", "_out = 'cake';", "cake"
    assert_compiles_to "<% _out = 'cake';%>", "_out = 'cake';", "cake"
    assert_compiles_to "<% _out = 'cake'%>", "_out = 'cake';", "cake"

    assert_compiles_to "foo<% _out << 'bar' %>baz", nil, "foobarbaz"
    assert_compiles_to "foo <% _out << 'bar' %> baz", nil, "foo bar baz"

    assert_compiles_to "foo <%
      _out << 'bar'
    %> baz", nil, "foo bar baz"
  end

  def test_escaped_erb_style_tags
    assert_compiles_to "<%% _out = 'cake' %%>", nil, "<% _out = 'cake' %>"
    assert_compiles_to "<%% _out = 'cake';%%>", nil, "<% _out = 'cake';%>"
    assert_compiles_to "<%% _out = 'cake'%%>", nil, "<% _out = 'cake'%>"

    assert_compiles_to "foo <%% _out << 'bar' %%> baz", nil, "foo <% _out << 'bar' %> baz"

    assert_compiles_to "foo <%%
      _out << 'bar'
    %%> baz", nil, "foo <%
      _out << 'bar'
    %> baz"
  end
end
