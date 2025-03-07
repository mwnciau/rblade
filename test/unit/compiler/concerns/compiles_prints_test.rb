require "test_case"

class CompilesPrintsTest < TestCase
  def test_variable
    assert_compiles_to "{{foo}}", "_out<<RBlade.e(foo);", "FOO"
    assert_compiles_to "{{ foo }}", "_out<<RBlade.e(foo);", "FOO"
    assert_compiles_to "{{
      foo
      }}", "_out<<RBlade.e(foo);", "FOO"

    assert_compiles_to "{!!foo!!}", "_out<<(foo).to_s;", "FOO"
    assert_compiles_to "{!! foo !!}", "_out<<(foo).to_s;", "FOO"
    assert_compiles_to "{!!
      foo
      !!}", "_out<<(foo).to_s;", "FOO"
  end

  def test_string
    assert_compiles_to "{{ 'foo' }}", "_out<<RBlade.e('foo');", "foo"
    assert_compiles_to "{{ 1 }}", "_out<<RBlade.e(1);", "1"
    assert_compiles_to "{{ 'hello dear reader' }}", "_out<<RBlade.e('hello dear reader');", "hello dear reader"

    assert_compiles_to "{!! 'foo' !!}", "_out<<('foo').to_s;", "foo"
    assert_compiles_to "{!! 1 !!}", "_out<<(1).to_s;", "1"
    assert_compiles_to "{!! 'hello dear reader' !!}", "_out<<('hello dear reader').to_s;", "hello dear reader"
  end

  def test_expression
    assert_compiles_to "{{ foo + bar << 'BAZ' }}", "_out<<RBlade.e(foo + bar << 'BAZ');", "FOOBARBAZ"
    assert_compiles_to %q({{ "foo" + 'bar' }}), %q[_out<<RBlade.e("foo" + 'bar');], "foobar"
    assert_compiles_to %q({{ "#{foo}" }}), %q[_out<<RBlade.e("#{foo}");], "FOO" # standard:disable Lint/InterpolationCheck
    assert_compiles_to "{{ 'a' * 3 }}", "_out<<RBlade.e('a' * 3);", "aaa"

    assert_compiles_to "{!! foo + bar << 'BAZ' !!}", "_out<<(foo + bar << 'BAZ').to_s;", "FOOBARBAZ"
    assert_compiles_to %q({!! "foo" + 'bar' !!}), %q[_out<<("foo" + 'bar').to_s;], "foobar"
    assert_compiles_to %q({!! "#{foo}" !!}), %q[_out<<("#{foo}").to_s;], "FOO" # standard:disable Lint/InterpolationCheck
    assert_compiles_to "{!! 'a' * 3 !!}", "_out<<('a' * 3).to_s;", "aaa"
  end

  def test_multiple
    assert_compiles_to "{{'foo'}}bar", "_out<<RBlade.e('foo');_out<<'bar';", "foobar"
    assert_compiles_to "foo{{'bar'}}", "_out<<'foo';_out<<RBlade.e('bar');", "foobar"
    assert_compiles_to "foo{{
    'bar'
    }}baz", "_out<<'foo';_out<<RBlade.e('bar');_out<<'baz';", "foobarbaz"

    assert_compiles_to "{!!'foo'!!}bar", "_out<<('foo').to_s;_out<<'bar';", "foobar"
    assert_compiles_to "foo{!!'bar'!!}", "_out<<'foo';_out<<('bar').to_s;", "foobar"
    assert_compiles_to "foo{!!
    'bar'
    !!}baz", "_out<<'foo';_out<<('bar').to_s;_out<<'baz';", "foobarbaz"
  end

  def test_escaped
    assert_compiles_to "@{{foo}}", "_out<<'{{foo}}';", "{{foo}}"
    assert_compiles_to "@{{ foo }}", "_out<<'{{ foo }}';", "{{ foo }}"
    assert_compiles_to "@{{
      foo
      }}", "_out<<'{{
      foo
      }}';", "{{
      foo
      }}"

    assert_compiles_to "@{!!foo!!}", "_out<<'{!!foo!!}';", "{!!foo!!}"
    assert_compiles_to "@{!! foo !!}", "_out<<'{!! foo !!}';", "{!! foo !!}"
    assert_compiles_to "@{!!
        foo
        !!}", "_out<<'{!!
        foo
        !!}';", "{!!
        foo
        !!}"
  end

  def test_dangerous_strings
    assert_compiles_to %q({{ '"\'\\\\\\'' }}), %q[_out<<RBlade.e('"\'\\\\\\'');], "&quot;&#39;\\&#39;"
    assert_compiles_to %q({{ '<&"\'>' }}), %q[_out<<RBlade.e('<&"\'>');], "&lt;&amp;&quot;&#39;&gt;"
    assert_compiles_to %q(@{{ '"\'\\\\\\'' }}), nil, %q({{ '"\\'\\\\\\'' }})

    assert_compiles_to %q({!! '"\'\\\\\\'' !!}), %q[_out<<('"\'\\\\\\'').to_s;], %q("'\\')
    assert_compiles_to %q({!! '<&"\'>' !!}), %q[_out<<('<&"\'>').to_s;], "<&\"'>"
  end

  def test_erb_style
    assert_compiles_to "<%=foo%>", "_out<<RBlade.e(foo);", "FOO"
    assert_compiles_to "<%= foo %>", "_out<<RBlade.e(foo);", "FOO"
    assert_compiles_to "<%=
      foo
      %>", "_out<<RBlade.e(foo);", "FOO"

    assert_compiles_to "<%==foo%>", "_out<<(foo).to_s;", "FOO"
    assert_compiles_to "<%== foo %>", "_out<<(foo).to_s;", "FOO"
    assert_compiles_to "<%==
      foo
      %>", "_out<<(foo).to_s;", "FOO"
  end

  def test_limitations
    # The end tag cannot appear within the print
    assert_compiles_to "{{ 'foo}}' }}", "_out<<RBlade.e('foo);_out<<'\\' }}';"
    assert_compiles_to "<%= 'foo%>' %>", "_out<<RBlade.e('foo);_out<<'\\' %>';"

    # A workaround to this is using the alternative syntax
    assert_compiles_to "<%= 'foo}}' %>", "_out<<RBlade.e('foo}}');", "foo}}"
    assert_compiles_to "{{ 'foo%>' }}", "_out<<RBlade.e('foo%>');", "foo%&gt;"
  end

  def test_raw
    assert_compiles_to "{{ '<>' }}", "_out<<RBlade.e('<>');", "&lt;&gt;"
    assert_compiles_to "{{ raw('<>') }}", "_out<<RBlade.e(raw('<>'));", "<>"

    assert_compiles_to "{{ '\"\\'' }}", nil, "&quot;&#39;"
    assert_compiles_to "{{ raw('\"\\'') }}", nil, "\"'"
  end

  def test_printing_member_variables
    assert_compiles_to "{{ @foo }}", "_out<<RBlade.e(@foo);"
  end

  def self.block_helper_func
    output = +"2"
    output << yield
    output << "4"
  end

  def self.block_helper_func_with_arg
    output = +"2"
    output << (yield "3")
    output << "4"
  end

  def test_block_helpers
    assert_compiles_to "1{{ CompilesPrintsTest::block_helper_func do }}3{{ end }}5", nil, "12345"
    assert_compiles_to "1<%= CompilesPrintsTest::block_helper_func do %>3<%= end %>5", nil, "12345"
    assert_compiles_to "1{{ CompilesPrintsTest::block_helper_func_with_arg do |x| }}{{ x }}{{ end }}5", nil, "12345"
    assert_compiles_to "1<%= CompilesPrintsTest::block_helper_func_with_arg do |x| %><%= x %><%= end %>5", nil, "12345"

    # Test that if statements on the end block work
    assert_compiles_to "1{{ CompilesPrintsTest::block_helper_func do }}3{{ end if true }}5", nil, "12345"
    assert_compiles_to "1{{ CompilesPrintsTest::block_helper_func do }}3{{ end if false }}5", nil, "15"

    # Ensure return value is properly set
    assert_compiles_to "1{{ CompilesPrintsTest::block_helper_func do }}3<% x = 'bad' %>{{ end }}5", nil, "12345"
    assert_compiles_to "1{{ CompilesPrintsTest::block_helper_func do }}3 @ruby(x = 'bad'){{ end }}5", nil, "12345"
    assert_compiles_to "1{{ CompilesPrintsTest::block_helper_func_with_arg do |x| }}<%= x %><% x = 'bad' %>{{ end }}5", nil, "12345"

    # Ensure this still works when we wrap the end block differently
    assert_compiles_to "1<%= CompilesPrintsTest::block_helper_func do %>3<% end %>5", nil, "12345"
    assert_compiles_to "1<%= CompilesPrintsTest::block_helper_func do %>3 @ruby(end)5", nil, "12345"
    assert_compiles_to "1<%= CompilesPrintsTest::block_helper_func do %>3<% x = 'bad' %><% end %>5", nil, "12345"
  end
end
