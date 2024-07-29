require "test_case"
require "rblade/compiler/compiles_verbatim"

class CompilesVerbatimTest < TestCase
  def test_verbatim
    assert_compiles_to "@verbatim hi @endverbatim", nil, "hi"
    assert_compiles_to "@verbatim hi @endVerbatim", nil, "hi"
    assert_compiles_to "@verbatim hi @end_verbatim", nil, "hi"
  end

  def test_verbatim_statements
    assert_compiles_to " @verbatim @end @endverbatim ", nil, "@end"
  end

  def test_verbatim_components
    assert_compiles_to " @verbatim <x-button/> @endverbatim ", nil, "<x-button/>"
  end

  def test_verbatim_spaces
    assert_compiles_to " @verbatim hi @endverbatim ", nil, "hi"
  end

  def assert_verbatim_found(template, expected = true)
    tokens = [Token.new(:unprocessed, template)]
    RBlade::CompilesVerbatim.new.compile!(tokens)

    assert_equal expected, tokens.any? { |t| t.type == :raw_text }
  end

  def test_verbatim_boundaries
    assert_verbatim_found "@verbatimhi@endverbatim", false
    assert_verbatim_found "@verbatim hi@endverbatim", false
    assert_verbatim_found "@verbatimhi @endverbatim", false
    assert_verbatim_found "a@verbatim @endverbatim", false

    assert_compiles_to ">@verbatim hi @endverbatim", nil, ">hi"
    assert_compiles_to "'@verbatim hi @endverbatim", nil, "'hi"
    assert_compiles_to ".@verbatim hi @endverbatim", nil, ".hi"
  end
end
