require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"
require_relative "../../../../lib/compiler/concerns/tokenizes_statements"

class EchoTest < TestCase
  def assert_tokenizes_to template, expected
    tokens = [Token.new(:unprocessed, template)]
    TokenizesStatements.tokenize!(tokens)

    expected.each.with_index do |expected_item, i|
      assert_equal expected_item, tokens[i].value
    end
  end

  def test_echo_variable
    assert_tokenizes_to "@foo", [{:statement => "foo"}]
    assert_tokenizes_to "@foo::bar", [{:statement => "foo::bar"}]
    assert_tokenizes_to "@foo @bar", [{:statement => "foo"}, " ", {:statement => "bar"}]
    assert_tokenizes_to "@@foo", ["@@foo"]
    assert_tokenizes_to "@foo()", [{:statement => "foo", :arguments => "()"}]
    assert_tokenizes_to "@foo(1, 2, 3)", [{:statement => "foo", :arguments => "(1, 2, 3)"}]
    assert_tokenizes_to "@foo   (1, 2, 3)", [{:statement => "foo", :arguments => "(1, 2, 3)"}]
    assert_tokenizes_to "@foo   (1,
    2,
    3)", [{:statement => "foo", :arguments => "(1,
    2,
    3)"}]
  end
end
