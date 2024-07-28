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

  def test_fails_with_wrong_arguments
    exception = assert_raises Exception do
      RBlade::Compiler.compileString("@not_a_real_statement")
    end
    assert_equal "Unhandled statement: @not_a_real_statement", exception.to_s
  end
end
