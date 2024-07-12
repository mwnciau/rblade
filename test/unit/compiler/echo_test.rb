require_relative "../../test_case"
require_relative "../../../lib/compiler/blade_compiler"

class EchoTest < TestCase
  def test_normal_echo
    compiledString = BladeCompiler.compileString("ab{{my_var}}cd")

    assert_equal "_out='';_out.<<'ab';_out.<<h(my_var);_out.<<'cd';", compiledString

    my_var = "MY_VAR";
    result = eval compiledString + ";_out"

    assert_equal "abMY_VARcd", result
  end

  def test_echo_quotes
    compiledString = BladeCompiler.compileString("{{ 'ca' + \"ke\" }}")

    assert_equal "_out='';_out.<<h( 'ca' + \"ke\" );", compiledString

    result = eval compiledString + ";_out"

    assert_equal "cake", result
  end

  def test_echo_html_entities
    compiledString = BladeCompiler.compileString("{{ '<&\"\\'>' }}")

    assert_equal "_out='';_out.<<h( '<&\"\\'>' );", compiledString

    result = eval compiledString + ";_out"

    assert_equal "&lt;&amp;&quot;&apos;&gt;", result
  end
end
