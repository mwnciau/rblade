require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"

class CompilesCommentsTest < TestCase
  def test_comments
    assert_compiles_to "{{--this is a comment--}}", "", ""
    assert_compiles_to "{{--
    this is a comment
    --}}", "", ""
    assert_compiles_to "{{-- this is a #{"very " * 1000} long comment --}}", "", ""
  end

  def test_erb_style
    assert_compiles_to "<%#this is a comment%>", "", ""
    assert_compiles_to "<%#
    this is a comment
    %>", "", ""
    assert_compiles_to "<%# this is a #{"very " * 1000} long comment %>", "", ""
  end

  def test_code_inside_comments
    assert_compiles_to "{{-- {{ myvar }} --}}", "", ""
  end
end
