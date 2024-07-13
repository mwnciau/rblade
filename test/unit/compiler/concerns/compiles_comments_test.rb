require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"

class EchoTest < TestCase
  def test_comments
    assert_compiles_to "{{--this is a comment--}}", "_out='';", ""
    assert_compiles_to "{{--
    this is a comment
    --}}", "_out='';", ""
    assert_compiles_to "{{-- this is a #{"very " * 1000} long comment --}}", "_out='';", ""
  end

  def test_code_inside_comments
    assert_compiles_to "{{-- {{ myvar }} --}}", "_out='';", ""
  end
end
