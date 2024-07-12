require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"

class EchoTest < TestCase
  def test_echo_variable
    assert_compiles_to "{{foo}}", "_out='';_out<<h(foo);", "FOO"
    assert_compiles_to "{{ foo }}", "_out='';_out<<h(foo);", "FOO"
    assert_compiles_to "{{
      foo
      }}", "_out='';_out<<h(foo);", "FOO"

    assert_compiles_to "{!!foo!!}", "_out='';_out<<(foo);", "FOO"
    assert_compiles_to "{!! foo !!}", "_out='';_out<<(foo);", "FOO"
    assert_compiles_to "{!!
      foo
      !!}", "_out='';_out<<(foo);", "FOO"
  end

  def test_echo_string
    assert_compiles_to "{{ 'foo' }}", "_out='';_out<<h('foo');", "foo"
    assert_compiles_to "{{ 'hello dear reader' }}", "_out='';_out<<h('hello dear reader');", "hello dear reader"

    assert_compiles_to "{!! 'foo' !!}", "_out='';_out<<('foo');", "foo"
    assert_compiles_to "{!! 'hello dear reader' !!}", "_out='';_out<<('hello dear reader');", "hello dear reader"
  end

  def test_echo_expression
    assert_compiles_to %q[{{ foo + bar << 'BAZ' }}], %q[_out='';_out<<h(foo + bar << 'BAZ');], "FOOBARBAZ"
    assert_compiles_to %q[{{ "foo" + 'bar' }}], %q[_out='';_out<<h("foo" + 'bar');], "foobar"
    assert_compiles_to %q[{{ "#{foo}" }}], %q[_out='';_out<<h("#{foo}");], "FOO"
    assert_compiles_to %q[{{ 'a' * 3 }}], %q[_out='';_out<<h('a' * 3);], "aaa"

    assert_compiles_to %q[{!! foo + bar << 'BAZ' !!}], %q[_out='';_out<<(foo + bar << 'BAZ');], "FOOBARBAZ"
    assert_compiles_to %q[{!! "foo" + 'bar' !!}], %q[_out='';_out<<("foo" + 'bar');], "foobar"
    assert_compiles_to %q[{!! "#{foo}" !!}], %q[_out='';_out<<("#{foo}");], "FOO"
    assert_compiles_to %q[{!! 'a' * 3 !!}], %q[_out='';_out<<('a' * 3);], "aaa"
  end

  def test_echo_multiple
    assert_compiles_to "{{'foo'}}bar", "_out='';_out<<h('foo');_out<<'bar';", "foobar"
    assert_compiles_to "foo{{'bar'}}", "_out='';_out<<'foo';_out<<h('bar');", "foobar"
    assert_compiles_to "foo{{
    'bar'
    }}baz", "_out='';_out<<'foo';_out<<h('bar');_out<<'baz';", "foobarbaz"

    assert_compiles_to "{!!'foo'!!}bar", "_out='';_out<<('foo');_out<<'bar';", "foobar"
    assert_compiles_to "foo{!!'bar'!!}", "_out='';_out<<'foo';_out<<('bar');", "foobar"
    assert_compiles_to "foo{!!
    'bar'
    !!}baz", "_out='';_out<<'foo';_out<<('bar');_out<<'baz';", "foobarbaz"
  end

  def test_skip_echo
    assert_compiles_to "@{{foo}}", "_out='';_out<<'{{foo}}';", "{{foo}}"
    assert_compiles_to "@{{ foo }}", "_out='';_out<<'{{ foo }}';", "{{ foo }}"
    assert_compiles_to "@{{
      foo
      }}", "_out='';_out<<'{{
      foo
      }}';", "{{
      foo
      }}"

      assert_compiles_to "@{!!foo!!}", "_out='';_out<<'{!!foo!!}';", "{!!foo!!}"
      assert_compiles_to "@{!! foo !!}", "_out='';_out<<'{!! foo !!}';", "{!! foo !!}"
      assert_compiles_to "@{!!
        foo
        !!}", "_out='';_out<<'{!!
        foo
        !!}';", "{!!
        foo
        !!}"
  end


  def test_echo_dangerous_strings
    assert_compiles_to %q[{{ '"\'\\\\\\'' }}], %q[_out='';_out<<h('"\'\\\\\\'');], "&quot;&apos;\\&apos;"
    assert_compiles_to %q[{{ '<&"\'>' }}], %q[_out='';_out<<h('<&"\'>');], "&lt;&amp;&quot;&apos;&gt;"
    assert_compiles_to %q[@{{ '"\'\\\\\\'' }}], nil, %q[{{ '\"\\'\\\\\\'' }}]

    assert_compiles_to %q[{!! '"\'\\\\\\'' !!}], %q[_out='';_out<<('"\'\\\\\\'');], %q["'\\']
    assert_compiles_to %q[{!! '<&"\'>' !!}], %q[_out='';_out<<('<&"\'>');], "<&\"'>"
  end
end
