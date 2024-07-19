require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"
require_relative "../../../../lib/compiler/concerns/tokenizes_statements"

class TokenizesStatementsTest < TestCase
  def assert_tokenizes_to template, expected
    tokens = [Token.new(:unprocessed, template)]
    TokenizesStatements.new.tokenize!(tokens)

    expected.each.with_index do |expected_item, i|
      assert_equal expected_item, tokens[i].value
    end
  end

  def test_tokenize
    assert_tokenizes_to "@foo", [{name: "foo"}]
    assert_tokenizes_to "@foo::bar", [{name: "foo::bar"}]
    assert_tokenizes_to "@foo @bar", [{name: "foo"}, {name: "bar"}]
    assert_tokenizes_to "@foo  @bar", [{name: "foo"}, " ", {name: "bar"}]
    assert_tokenizes_to "@foo()", [{name: "foo"}]
    assert_tokenizes_to "@foo(1, 2, 3)", [{name: "foo", arguments: ["1", "2", "3"]}]
    assert_tokenizes_to "@foo   (1, 2, 3)", [{name: "foo", arguments: ["1", "2", "3"]}]
    assert_tokenizes_to "@foo   (1,
    2,
    3)", [{name: "foo", arguments: ["1", "2", "3"]}]
  end

  def test_nested_statements
    assert_tokenizes_to "@foo(@bar)", [{name: "foo", arguments: ["@bar"]}]
    assert_tokenizes_to "@foo(@@bar)", [{name: "foo", arguments: ["@@bar"]}]
    assert_tokenizes_to "@@foo(@bar)", ["@foo", "(@bar)"]
    assert_tokenizes_to "@@foo(()@bar)", ["@foo", "(()", "@bar)"]
  end

  def test_skip_statement
    assert_tokenizes_to "@@foo", ["@foo"]
    assert_tokenizes_to "@@foo::bar", ["@foo::bar"]
    assert_tokenizes_to "@@foo(1, 2, 3)", ["@foo", "(1, 2, 3)"]
  end

  def test_bracket_matching
    assert_tokenizes_to "@foo()", [{name: "foo"}]
    assert_tokenizes_to "@foo(')', 2)", [{name: "foo", arguments: ["')'", "2"]}]
    assert_tokenizes_to "@foo('(', 2)", [{name: "foo", arguments: ["'('", "2"]}]
    assert_tokenizes_to "@foo(%q[)], 2)", [{name: "foo", arguments: ["%q[)]", "2"]}]

    assert_tokenizes_to "@foo((1), ((2)), (3))", [{name: "foo", arguments: ["(1)", "((2))", "(3)"]}]
    assert_tokenizes_to "@foo((1 + 2), 3)", [{name: "foo", arguments: ["(1 + 2)", "3"]}]
    assert_tokenizes_to "@foo(#{"(" * 100}#{")" * 100})", [{name: "foo", arguments: ["#{"(" * 100}#{")" * 100}"]}]

    assert_tokenizes_to "@foo(1,
    2)", [{name: "foo", arguments: ["1", "2"]}]
    assert_tokenizes_to "@foo(1
, 2)", [{name: "foo", arguments: ["1", "2"]}]
    assert_tokenizes_to "@foo(1,
    (2 + (3)),
    4) @bar()", [{name: "foo", arguments: ["1", "(2 + (3))", "4"]}, {name: "bar"}]

    assert_tokenizes_to "( @foo())", ["(", {name: "foo"}, ")"]
    assert_tokenizes_to "@foo)", [{name: "foo"}, ")"]
    assert_tokenizes_to "@foo(", [{name: "foo"}, "("]
    assert_tokenizes_to "@foo(()(()", [{name: "foo"}, "(()(()"]
  end
end
