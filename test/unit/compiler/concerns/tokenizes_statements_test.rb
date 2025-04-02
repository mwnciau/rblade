require "test_case"

class TokenizesStatementsTest < TestCase
  def assert_tokenizes_to(template, expected)
    tokens = [Token.new(:unprocessed, template)]
    RBlade::TokenizesStatements.new.tokenize!(tokens)

    expected.each.with_index do |expected_item, i|
      actual = tokens[i]&.value || tokens[i]
      if expected_item.is_a? Hash
        assert_equal expected_item[:name], actual[:name]
        if expected_item[:arguments].nil?
          assert_nil actual[:arguments]
        else
          assert_equal expected_item[:arguments], actual[:arguments]
        end
      elsif expected_item.nil?
        assert_nil actual
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
    assert_tokenizes_to "@@ruby(@if)", ["@ruby(", {name: "if"}, ")"]
    assert_tokenizes_to "@@ruby(()@if)", ["@ruby(()", {name: "if"}, ")"]
  end

  def test_skip_statement
    assert_tokenizes_to "@@ruby", ["@ruby"]
    assert_tokenizes_to "before @@ruby", ["before @ruby"]
    assert_tokenizes_to "before@@ruby", ["before@@ruby"]

    assert_tokenizes_to "@@ruby(1, 2, 3)", ["@ruby(1, 2, 3)"]
    assert_tokenizes_to "before @@ruby(1, 2, 3)", ["before @ruby(1, 2, 3)"]
    assert_tokenizes_to "before@@ruby(1, 2, 3)", ["before@@ruby(1, 2, 3)"]
  end

  def test_bracket_matching
    assert_tokenizes_to "@ruby()", [{name: "ruby"}, nil]
    assert_tokenizes_to "@ruby( )", [{name: "ruby"}, nil]
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

    assert_tokenizes_to "@ruby(<<END\n)\nEND\n)", [{name: "ruby", arguments: ["<<END\n)\nEND"]}]
    assert_tokenizes_to "@ruby(<<\"END\"\n)\nEND\n)", [{name: "ruby", arguments: ["<<\"END\"\n)\nEND"]}]
    assert_tokenizes_to "@ruby(<<'END'\n)\nEND\n)", [{name: "ruby", arguments: ["<<'END'\n)\nEND"]}]
    assert_tokenizes_to "@ruby(<<-END\n)\n  END\n)", [{name: "ruby", arguments: ["<<-END\n)\n  END"]}]
    assert_tokenizes_to "@ruby(<<-\"END\"\n)\n  END\n)", [{name: "ruby", arguments: ["<<-\"END\"\n)\n  END"]}]
    assert_tokenizes_to "@ruby(<<-'END'\n)\n  END\n)", [{name: "ruby", arguments: ["<<-'END'\n)\n  END"]}]
    assert_tokenizes_to "@ruby(<<~END\n)\n\tEND\n)", [{name: "ruby", arguments: ["<<~END\n)\n\tEND"]}]
    assert_tokenizes_to "@ruby(<<~\"END\"\n)\n\tEND\n)", [{name: "ruby", arguments: ["<<~\"END\"\n)\n\tEND"]}]
    assert_tokenizes_to "@ruby(<<~'END'\n)\n\tEND\n)", [{name: "ruby", arguments: ["<<~'END'\n)\n\tEND"]}]

    assert_tokenizes_to "( @ruby())", ["(", {name: "ruby"}, ")"]
    assert_tokenizes_to "@ruby)", [{name: "ruby"}, ")"]
    assert_tokenizes_to "@ruby(", [{name: "ruby"}, "("]
    assert_tokenizes_to "@ruby(()(()", [{name: "ruby"}, "(()(()"]
  end

  def test_commas_in_brackets
    assert_tokenizes_to "@ruby([1, 2, 3])", [{name: "ruby", arguments: ["[1, 2, 3]"]}]
    assert_tokenizes_to "@ruby([1, 2, 3], a)", [{name: "ruby", arguments: ["[1, 2, 3]", "a"]}]
    assert_tokenizes_to "@ruby([1, {2, 3}])", [{name: "ruby", arguments: ["[1, {2, 3}]"]}]
    assert_tokenizes_to "@ruby([1], ([{2, 3}]))", [{name: "ruby", arguments: ["[1]", "([{2, 3}])"]}]
  end

  def test_boundaries
    # Should be compiled
    assert_compiles_to "\n@end", "end;"
    assert_compiles_to "\n\n@end", "@output_buffer.raw_buffer<<-'\n';end;"
    assert_compiles_to "a @end", "@output_buffer.raw_buffer<<-'a';end;"
    assert_compiles_to ">@end", "@output_buffer.raw_buffer<<-'>';end;"
    assert_compiles_to "'@end", "@output_buffer.raw_buffer<<-'\\'';end;"
    assert_compiles_to "\n@end?", "end;"

    # Should not be compiled
    assert_compiles_to "a@end", "@output_buffer.raw_buffer<<-'a@end';"
    assert_compiles_to "1@end", "@output_buffer.raw_buffer<<-'1@end';"

    # Should partly be compiled
    assert_compiles_to "@end@end", "end;@output_buffer.raw_buffer<<-'@end';"

    # Whitespace should not be trimmed for non-statements
    assert_compiles_to " @cake ", "@output_buffer.raw_buffer<<-' @cake ';"
  end

  def test_statement_arguments
    assert_tokenizes_to "@ruby()", [{name: "ruby"}, nil]
    assert_tokenizes_to "@ruby( )", [{name: "ruby"}, nil]

    assert_tokenizes_to "@ruby(1 \n 2 \n 3)", [{name: "ruby", arguments: ["1 \n 2 \n 3"]}]
    assert_tokenizes_to "@ruby(1, \n 2, \n 3)", [{name: "ruby", arguments: ["1", "2", "3"]}]

    # Double commas get merged
    assert_tokenizes_to "@ruby(a,,b)", [{name: "ruby", arguments: ["a", "b"]}]
    assert_tokenizes_to "@ruby(a, ,b)", [{name: "ruby", arguments: ["a", "b"]}]
  end

  def test_limitations
    # Parentheses in regular expressions may cause incorrect matching
    assert_tokenizes_to "@ruby(/\\)/)", [{name: "ruby", arguments: ["/\\"]}, "/)"]

    # A workaround is to use the alternative %r syntax
    assert_tokenizes_to "@ruby(%r/\\)/)", [{name: "ruby", arguments: ["%r/\\)/"]}, nil]
  end
end
