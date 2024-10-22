require "test_case"
require "rblade/compiler"

class CompilesStatementsTest < TestCase
  def test_end
    assert_compiles_to "@end", "end;"
  end

  def test_escaping
    assert_compiles_to "@@end", "_out<<'@end';"
    assert_compiles_to "@@this(12345)", "_out<<'@this';_out<<'(12345)';"
    assert_compiles_to "@@this(@end)", "_out<<'@this';_out<<'(';end;_out<<')';"
  end

  def test_statements_are_case_insensitive
    assert_compiles_to "@endIf", "end;"
  end

  def test_statements_ignore_underscores
    assert_compiles_to "@end_if", "end;"
  end

  def test_does_not_parse_invalid_statements
    assert_compiles_to "@not_a_real_statement", "_out<<'@not_a_real_statement';"
    assert_compiles_to "@not_a_real_statement()", "_out<<'@not_a_real_statement()';"
    assert_compiles_to "@not_a_real_statement(1, 2, 3)", "_out<<'@not_a_real_statement(1, 2, 3)';"
    assert_compiles_to "@not_a_real_statement  (1, 2, 3)", "_out<<'@not_a_real_statement  (1, 2, 3)';"
    assert_compiles_to "@not_a_real_statement   (1, 2, 3)", "_out<<'@not_a_real_statement   (1, 2, 3)';"
  end
end
