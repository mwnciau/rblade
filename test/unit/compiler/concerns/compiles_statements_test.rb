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
    assert_compiles_to "@not_a_real_directive", "_out<<'@not_a_real_directive';"
    assert_compiles_to "@not_a_real_directive()", "_out<<'@not_a_real_directive()';"
    assert_compiles_to "@not_a_real_directive(1, 2, 3)", "_out<<'@not_a_real_directive(1, 2, 3)';"
    assert_compiles_to "@not_a_real_directive  (1, 2, 3)", "_out<<'@not_a_real_directive  (1, 2, 3)';"
    assert_compiles_to "@not_a_real_directive   (1, 2, 3)", "_out<<'@not_a_real_directive   (1, 2, 3)';"
  end

  class CustomDirectiveHandler
    def custom_directive args
      return args&.join(",") || 'no arguments'
    end
  end

  def test_register_directive_handler
    RBlade::register_directive_handler('custom_directive', CustomDirectiveHandler, :custom_directive)

    assert_compiles_to "@custom_directive", "no arguments"
    assert_compiles_to "@customDirective", "no arguments"
    assert_compiles_to "@customdirective()", "no arguments"

    assert_compiles_to "@customdirective(one argument)", "one argument"
    assert_compiles_to "@customdirective(a,b)", "a,b"
    assert_compiles_to "@customdirective(1,2,3)", "1,2,3"
  end
end
