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
    assert_tokenizes_to "@ruby", [{name: "ruby"}]
    assert_tokenizes_to "@ruby @if", [{name: "ruby"}, {name: "if"}]
    assert_tokenizes_to "@ruby  @if", [{name: "ruby"}, {name: "if"}]
    assert_tokenizes_to "@ruby   @if", [{name: "ruby"}, " ", {name: "if"}]
    assert_tokenizes_to "@ruby()", [{name: "ruby"}]
    assert_tokenizes_to "@ruby(1, 2, 3)", [{name: "ruby", arguments: ["1", "2", "3"]}]
    assert_tokenizes_to "@ruby   (1, 2, 3)", [{name: "ruby", arguments: ["1", "2", "3"]}]
    assert_tokenizes_to "@ruby   (1,
    2,
    3)", [{name: "ruby", arguments: ["1", "2", "3"]}]
  end

  def test_nested_statements
    assert_tokenizes_to "@ruby(@if)", [{name: "ruby", arguments: ["@if"]}]
    assert_tokenizes_to "@ruby(@@if)", [{name: "ruby", arguments: ["@@if"]}]
    assert_tokenizes_to "@@ruby(@if)", ["@ruby", "(", {name: "if"}, ")"]
    assert_tokenizes_to "@@ruby(()@if)", ["@ruby", "(()", {name: "if"}, ")"]
  end

  def test_skip_statement
    assert_tokenizes_to "@@ruby", ["@ruby"]
    assert_tokenizes_to "@@ruby(1, 2, 3)", ["@ruby", "(1, 2, 3)"]
  end

  def test_bracket_matching
    assert_tokenizes_to "@ruby()", [{name: "ruby"}]
    assert_tokenizes_to "@ruby(')', 2)", [{name: "ruby", arguments: ["')'", "2"]}]
    assert_tokenizes_to "@ruby('(', 2)", [{name: "ruby", arguments: ["'('", "2"]}]
    assert_tokenizes_to "@ruby(%q[)], 2)", [{name: "ruby", arguments: ["%q[)]", "2"]}]

    assert_tokenizes_to "@ruby((1), ((2)), (3))", [{name: "ruby", arguments: ["(1)", "((2))", "(3)"]}]
    assert_tokenizes_to "@ruby((1 + 2), 3)", [{name: "ruby", arguments: ["(1 + 2)", "3"]}]
    assert_tokenizes_to "@ruby(#{"(" * 100}#{")" * 100})", [{name: "ruby", arguments: ["#{"(" * 100}#{")" * 100}"]}]

    assert_tokenizes_to "@ruby(1,
    2)", [{name: "ruby", arguments: ["1", "2"]}]
    assert_tokenizes_to "@ruby(1
, 2)", [{name: "ruby", arguments: ["1", "2"]}]
    assert_tokenizes_to "@ruby(1,
    (2 + (3)),
    4) @if()", [{name: "ruby", arguments: ["1", "(2 + (3))", "4"]}, {name: "if"}]

    assert_tokenizes_to "( @ruby())", ["(", {name: "ruby"}, ")"]
    assert_tokenizes_to "@ruby)", [{name: "ruby"}, ")"]
    assert_tokenizes_to "@ruby(", [{name: "ruby"}, "("]
    assert_tokenizes_to "@ruby(()(()", [{name: "ruby"}, "(()(()"]
  end

  def test_commas_in_brackets
    assert_tokenizes_to "@ruby([1, 2, 3])", [{name: "ruby", arguments: ["[1, 2, 3]"]}]
    assert_tokenizes_to "@ruby([1, {2, 3}])", [{name: "ruby", arguments: ["[1, {2, 3}]"]}]
    assert_tokenizes_to "@ruby([1], ([{2, 3}]))", [{name: "ruby", arguments: ["[1]", "([{2, 3}])"]}]
  end

  def test_boundaries
    # Should be compiled
    assert_compiles_to "\n@end", "end;"
    assert_compiles_to "\n\n@end", "_out<<'\n';end;"
    assert_compiles_to "a @end", "_out<<'a';end;"
    assert_compiles_to ">@end", "_out<<'>';end;"
    assert_compiles_to "'@end", "_out<<'\\'';end;"
    assert_compiles_to "\n@end?", "end;"

    # Should not be compiled
    assert_compiles_to "a@end", "_out<<'a@end';"
    assert_compiles_to "1@end", "_out<<'1@end';"

    # Should partly be compiled
    assert_compiles_to "@end@end", "end;_out<<'@end';"

    # Whitespace should not be trimmed for non-statements
    assert_compiles_to " @cake ", "_out<<' @cake ';"
  end
end
