require "test_case"

class TokenizesStatementsTest < TestCase
  def assert_tokenizes_to template, expected
    tokens = [Token.new(:unprocessed, template)]
    RBlade::TokenizesStatements.new.tokenize!(tokens)

    expected.each.with_index do |expected_item, i|
      actual = tokens[i].value
      if expected_item.is_a? Hash
        assert_equal expected_item[:name], actual[:name]
        if expected_item[:arguments].nil?
          assert_nil actual[:arguments]
        else
          assert_equal expected_item[:arguments], actual[:arguments]
        end
      else
        assert_equal expected_item, actual
      end
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

  def test_commas_in_brackets
    assert_tokenizes_to "@foo([1, 2, 3])", [{name: "foo", arguments: ["[1, 2, 3]"]}]
    assert_tokenizes_to "@foo([1, {2, 3}])", [{name: "foo", arguments: ["[1, {2, 3}]"]}]
    assert_tokenizes_to "@foo([1], ([{2, 3}]))", [{name: "foo", arguments: ["[1]", "([{2, 3}])"]}]
  end
end
