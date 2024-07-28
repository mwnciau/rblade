require "test_case"
require "rblade/compiler"

class CompilesStatementsTest < TestCase
  def test_end
    assert_compiles_to "@end", "end;"
  end

  def test_escaping
    assert_compiles_to "@@end", "_out<<'@end';"
    assert_compiles_to "@@this(12345)", "_out<<'@this';_out<<'(12345)';"

    # TODO Edge case bug: we shouldn't be interpreting the parentheses here
    assert_compiles_to "@@this(@end)", "_out<<'@this';_out<<'(@end)';"
  end

  def test_statements_are_case_insensitive
    assert_compiles_to "@endIf", "end;"
  end

  def test_statements_ignore_underscores
    assert_compiles_to "@end_if", "end;"
  end

  # TODO assess all of these boundaries
  def test_boundaries
    # Works
    assert_compiles_to "\n@end", "end;"
    assert_compiles_to "\n\n@end", "_out<<'\n';end;"
    assert_compiles_to "a @end", "_out<<'a';end;"

    # TODO these statements should be intepreted
    assert_compiles_to ">@end", "_out<<'>@end';"
    assert_compiles_to "'@end", "_out<<'\\\'@end';"

    # Doesn't work
    assert_compiles_to "a@end", "_out<<'a@end';"
    assert_compiles_to "1@end", "_out<<'1@end';"

    # Half works
    assert_compiles_to "@end@end", "end;_out<<'@end';"
  end

  def test_fails_with_wrong_arguments
    exception = assert_raises Exception do
      RBlade::Compiler.compileString("@not_a_real_statement")
    end
    assert_equal "Unhandled statement: @not_a_real_statement", exception.to_s
  end
end
