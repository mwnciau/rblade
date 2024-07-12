require_relative "../../test_case"
require_relative "../../../lib/compiler/blade_compiler"

class EchoTest < TestCase
  def test_normal_echo
    compiledString = BladeCompiler.compileString("ab{{my_var}}cd")

    assert_equal "_out='';_out<<'ab';_out<<h(my_var);_out<<'cd';", compiledString

    my_var = "MY_VAR";
    result = eval compiledString + ";_out"

    assert_equal "abMY_VARcd", result
  end

  def test_multiple_echos
    compiledString = BladeCompiler.compileString("{{ 'ab' }}{{ 'cd' }}")

    assert_equal "_out='';_out<<h('ab');_out<<h('cd');", compiledString

    result = eval compiledString + ";_out"

    assert_equal "abcd", result
  end

  def test_multiple_lines
    compiledString = BladeCompiler.compileString("{{
    'ab
    c'
    }}d
    ef
    gh")

    assert_equal "_out='';_out<<h('ab
    c');_out<<'d
    ef
    gh';", compiledString

    result = eval compiledString + ";_out"

    assert_equal "ab
    cd
    ef
    gh", result
  end

  def test_echo_quotes
    compiledString = BladeCompiler.compileString("{{ 'ca' + \"ke\" }}")

    assert_equal "_out='';_out<<h('ca' + \"ke\");", compiledString

    result = eval compiledString + ";_out"

    assert_equal "cake", result
  end

  def test_echo_html_entities
    compiledString = BladeCompiler.compileString(%q[{{ '<&"\'>' }}])

    assert_equal %q[_out='';_out<<h('<&"\'>');], compiledString

    result = eval compiledString + ";_out"

    assert_equal "&lt;&amp;&quot;&apos;&gt;", result
  end

  def test_skip_echo_statement
    compiledString = BladeCompiler.compileString("@{{ 'abcd' }}")

    assert_equal "_out='';_out<<'{{ \\'abcd\\' }}';", compiledString

    result = eval compiledString + ";_out"

    assert_equal "{{ 'abcd' }}", result
  end

  def test_unsafe_echo
    compiledString = BladeCompiler.compileString(%q[{!! '<&"\'>' !!}])

    assert_equal %q[_out='';_out<<'<&"\\'>';], compiledString

    result = eval compiledString + ";_out"

    assert_equal %q[<&"'>], result
  end
end
