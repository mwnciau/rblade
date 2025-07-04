require "test_case"
require "rblade/compiler"

class CompilesStatementsTest < TestCase
  def test_end
    assert_compiles_to "@end", "end;"
  end

  def test_escaping
    assert_compiles_to "@@end", "@output_buffer.raw_buffer<<-'@end';"
    assert_compiles_to "@@push(12345)", "@output_buffer.raw_buffer<<-'@push(12345)';"
    assert_compiles_to "@@push(@end)", "@output_buffer.raw_buffer<<-'@push(';end;@output_buffer.raw_buffer<<-')';"
  end

  def test_statements_are_case_insensitive
    assert_compiles_to "@endIf", "end;"
  end

  def test_statements_ignore_underscores
    assert_compiles_to "@end_if", "end;"
  end

  def test_does_not_parse_invalid_statements
    assert_compiles_to "@not_a_real_directive", "@output_buffer.raw_buffer<<-'@not_a_real_directive';"
    assert_compiles_to "@not_a_real_directive()", "@output_buffer.raw_buffer<<-'@not_a_real_directive()';"
    assert_compiles_to "@not_a_real_directive(1, 2, 3)", "@output_buffer.raw_buffer<<-'@not_a_real_directive(1, 2, 3)';"
    assert_compiles_to "@not_a_real_directive  (1, 2, 3)", "@output_buffer.raw_buffer<<-'@not_a_real_directive  (1, 2, 3)';"
    assert_compiles_to "@not_a_real_directive   (1, 2, 3)", "@output_buffer.raw_buffer<<-'@not_a_real_directive   (1, 2, 3)';"
  end

  def test_register_directive_handler
    RBlade.register_directive_handler("custom_directive") { "simple" }
    RBlade.register_directive_handler("custom_directive_with_args") { |args| args&.join(",") || "no arguments" }
    RBlade.register_directive_handler("custom_directive_with_tokens") do |tokens, token_index|
      tokens[token_index].value[:name]
    end

    assert_compiles_to "@custom_directive", nil, "simple"
    assert_compiles_to "@CustomDirective", nil, "simple"
    assert_compiles_to "@CUSTOMDIRECTIVE", nil, "simple"
    assert_compiles_to "@customdirective()", nil, "simple"

    assert_compiles_to "@custom_directive_with_args", nil, "no arguments"
    assert_compiles_to "@custom_directive_with_args(one argument)", nil, "one argument"
    assert_compiles_to "@custom_directive_with_args(a,b)", nil, "a,b"
    assert_compiles_to "@custom_directive_with_args(1,2,3)", nil, "1,2,3"
    assert_compiles_to "@custom_directive_with_args('\\'\"')", nil, "'\\'\"'"

    assert_compiles_to "@custom_directive_with_tokens", nil, "customdirectivewithtokens"
  end

  def test_register_raw_directive_handler
    RBlade.register_raw_directive_handler("true?") { "if true;" }
    RBlade.register_raw_directive_handler("not?") { |args| "if !#{args[0]};" }

    assert_compiles_to "@true? cake @end", /if true;/, "cake"
    assert_compiles_to "@not?(true) cake @end", /if !true;/, ""
    assert_compiles_to "@not?(false) cake @end", /if !false;/, "cake"
    assert_compiles_to "@not?(foo == bar) cake @end", /if !foo == bar;/, ""
    assert_compiles_to "@not?((foo == bar))cake @end", /if !\(foo == bar\);/, "cake"

    assert_compiles_to "@TRUE? cake @end", nil, "cake"
    assert_compiles_to "@tR_uE? cake @end", nil, "cake"
    assert_compiles_to "@true?() cake @end", nil, "cake"
    assert_compiles_to "@true?cake @endTrue?", nil, "cake"
  end

  def test_sum_directive_used_in_readme
    RBlade.register_directive_handler("sum") do |args|
      args.inject(0) { |sum, num| sum + num.to_i }
    end

    assert_compiles_to "@sum(1)", nil, "1"
    assert_compiles_to "@sum(1, 2)", nil, "3"
    assert_compiles_to "@sum (1, 2, 3)", nil, "6"
  end

  def test_statements_offsets
    assert_tokens "@end", [{type: :statement, start_offset: 0, end_offset: 4}]
    assert_tokens "abc @end def", [
      {type: :unprocessed, start_offset: 0, end_offset: 3},
      {type: :statement, start_offset: 3, end_offset: 9},
      {type: :unprocessed, start_offset: 9, end_offset: 12},
    ]

    assert_tokens "@if(true)", [{type: :statement, start_offset: 0, end_offset: 9}]
    assert_tokens "abc @if(true) def", [
      {type: :unprocessed, start_offset: 0, end_offset: 3},
      {type: :statement, start_offset: 3, end_offset: 14},
      {type: :unprocessed, start_offset: 14, end_offset: 17},
    ]

    assert_tokens <<~RBLADE, [{type: :statement, start_offset: 0, end_offset: 5}]
      @end
    RBLADE
    source = <<~RBLADE
      abc
      @end
      def
    RBLADE
    assert_tokens source, [
      {type: :unprocessed, start_offset: 0, end_offset: 3},
      {type: :statement, start_offset: 3, end_offset: 9},
      {type: :unprocessed, start_offset: 9, end_offset: 13},
    ]
  end
end
