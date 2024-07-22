require "test_case"

class CompilesEchoTest < TestCase
  def test_variable
    assert_compiles_to "{{foo}}", "_out<<h(foo);", "FOO"
    assert_compiles_to "{{ foo }}", "_out<<h(foo);", "FOO"
    assert_compiles_to "{{
      foo
      }}", "_out<<h(foo);", "FOO"

    assert_compiles_to "{!!foo!!}", "_out<<(foo).to_s;", "FOO"
    assert_compiles_to "{!! foo !!}", "_out<<(foo).to_s;", "FOO"
    assert_compiles_to "{!!
      foo
      !!}", "_out<<(foo).to_s;", "FOO"
  end

  def test_string
    assert_compiles_to "{{ 'foo' }}", "_out<<h('foo');", "foo"
    assert_compiles_to "{{ 1 }}", "_out<<h(1);", "1"
    assert_compiles_to "{{ 'hello dear reader' }}", "_out<<h('hello dear reader');", "hello dear reader"

    assert_compiles_to "{!! 'foo' !!}", "_out<<('foo').to_s;", "foo"
    assert_compiles_to "{!! 1 !!}", "_out<<(1).to_s;", "1"
    assert_compiles_to "{!! 'hello dear reader' !!}", "_out<<('hello dear reader').to_s;", "hello dear reader"
  end

  def test_expression
    assert_compiles_to "{{ foo + bar << 'BAZ' }}", "_out<<h(foo + bar << 'BAZ');", "FOOBARBAZ"
    assert_compiles_to %q({{ "foo" + 'bar' }}), %q[_out<<h("foo" + 'bar');], "foobar"
    assert_compiles_to %q({{ "#{foo}" }}), %q[_out<<h("#{foo}");], "FOO" # standard:disable Lint/InterpolationCheck
    assert_compiles_to "{{ 'a' * 3 }}", "_out<<h('a' * 3);", "aaa"

    assert_compiles_to "{!! foo + bar << 'BAZ' !!}", "_out<<(foo + bar << 'BAZ').to_s;", "FOOBARBAZ"
    assert_compiles_to %q({!! "foo" + 'bar' !!}), %q[_out<<("foo" + 'bar').to_s;], "foobar"
    assert_compiles_to %q({!! "#{foo}" !!}), %q[_out<<("#{foo}").to_s;], "FOO" # standard:disable Lint/InterpolationCheck
    assert_compiles_to "{!! 'a' * 3 !!}", "_out<<('a' * 3).to_s;", "aaa"
  end

  def test_multiple
    assert_compiles_to "{{'foo'}}bar", "_out<<h('foo');_out<<'bar';", "foobar"
    assert_compiles_to "foo{{'bar'}}", "_out<<'foo';_out<<h('bar');", "foobar"
    assert_compiles_to "foo{{
    'bar'
    }}baz", "_out<<'foo';_out<<h('bar');_out<<'baz';", "foobarbaz"

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
    assert_compiles_to %q({{ '"\'\\\\\\'' }}), %q[_out<<h('"\'\\\\\\'');], "&quot;&#39;\\&#39;"
    assert_compiles_to %q({{ '<&"\'>' }}), %q[_out<<h('<&"\'>');], "&lt;&amp;&quot;&#39;&gt;"
    assert_compiles_to %q(@{{ '"\'\\\\\\'' }}), nil, %q({{ '"\\'\\\\\\'' }})

    assert_compiles_to %q({!! '"\'\\\\\\'' !!}), %q[_out<<('"\'\\\\\\'').to_s;], %q("'\\')
    assert_compiles_to %q({!! '<&"\'>' !!}), %q[_out<<('<&"\'>').to_s;], "<&\"'>"
  end

  def test_erb_style
    assert_compiles_to "<%=foo%>", "_out<<h(foo);", "FOO"
    assert_compiles_to "<%= foo %>", "_out<<h(foo);", "FOO"
    assert_compiles_to "<%=
      foo
      %>", "_out<<h(foo);", "FOO"
  end

  def test_limitations
    # The end tag cannot appear within the echo
    assert_compiles_to "{{ 'foo}}' }}", "_out<<h('foo);_out<<'\\' }}';"
    assert_compiles_to "<%= 'foo%>' %>", "_out<<h('foo);_out<<'\\' %>';"

    # A workaround to this is using the alternative syntax
    assert_compiles_to "<%= 'foo}}' %>", "_out<<h('foo}}');", "foo}}"
    assert_compiles_to "{{ 'foo%>' }}", "_out<<h('foo%>');", "foo%&gt;"
  end
end
