require_relative "../../../../test_case"
require_relative "../../../../../lib/compiler/blade_compiler"

class CompilesConditionalsTest < TestCase
  MULTILINE_STRING = "
    this
    string
    has
    multiple
    lines
  "

  def test_nested_statements
    assert_compiles_to "@if(true) @if(true) foo @endif @if(false) baz @endif @if(true) bar @endif @endif",
      "if(true);if(true);_out<<' foo';end;if(false);_out<<' baz';end;if(true);_out<<' bar';end;end;",
      " foo bar"
  end

  def test_if
    assert_compiles_to "@if ( true ) hi @endif", "if(true);_out<<' hi';end;", " hi"
    assert_compiles_to "@if(true) hi @endif", "if(true);_out<<' hi';end;", " hi"
    assert_compiles_to "@if(false) hi @endif", "if(false);_out<<' hi';end;", ""
    assert_compiles_to "@if(true)#{MULTILINE_STRING} @endif", "if(true);_out<<'#{MULTILINE_STRING}';end;", "#{MULTILINE_STRING}"
    assert_compiles_to "@if ( foo == 'FOO' ){{bar}} @endif", "if(foo == 'FOO');_out<<h(bar);end;", "BAR"
  end

  def test_elsif
    assert_compiles_to "@if(false) @elsif ( true ) hi @endif", "if(false);elsif(true);_out<<' hi';end;", " hi"
    assert_compiles_to "@if(false) @elsif(true) hi @endif", "if(false);elsif(true);_out<<' hi';end;", " hi"
    assert_compiles_to "@if(false) @elsif(false) hi @endif", "if(false);elsif(false);_out<<' hi';end;", ""
    assert_compiles_to "@if(false) @elsif(true)#{MULTILINE_STRING} @endif", "if(false);elsif(true);_out<<'#{MULTILINE_STRING}';end;", "#{MULTILINE_STRING}"
    assert_compiles_to "@if(false) @elsif ( foo == 'FOO' ){{bar}} @endif", "if(false);elsif(foo == 'FOO');_out<<h(bar);end;", "BAR"
  end

  def test_else
    assert_compiles_to "@if ( false ) @else hi @endif", "if(false);else;_out<<' hi';end;", " hi"
    assert_compiles_to "@if(false) @else hi @endif", "if(false);else;_out<<' hi';end;", " hi"
    assert_compiles_to "@if(true) @else hi @endif", "if(true);else;_out<<' hi';end;", ""
    assert_compiles_to "@if(false) @else#{MULTILINE_STRING} @endif", "if(false);else;_out<<'#{MULTILINE_STRING}';end;", "#{MULTILINE_STRING}"
    assert_compiles_to "@if ( foo == 'BAR' ) @else{{bar}} @endif", "if(foo == 'BAR');else;_out<<h(bar);end;", "BAR"
  end

  def test_unless
    assert_compiles_to "@unless ( false ) hi @endunless", "unless(false);_out<<' hi';end;", " hi"
    assert_compiles_to "@unless(false) hi @endunless", "unless(false);_out<<' hi';end;", " hi"
    assert_compiles_to "@unless(true) hi @endunless", "unless(true);_out<<' hi';end;", ""
    assert_compiles_to "@unless(false)#{MULTILINE_STRING} @endunless", "unless(false);_out<<'#{MULTILINE_STRING}';end;", "#{MULTILINE_STRING}"
    assert_compiles_to "@unless( foo == 'BAR' ){{bar}} @endif", "unless(foo == 'BAR');_out<<h(bar);end;", "BAR"
  end

  def test_case_when
    assert_compiles_to "@case(1) @when(2) TWO @when(1) ONE @else UNKNOWN @endcase",
      "case(1);when 2;_out<<' TWO';when 1;_out<<' ONE';else;_out<<' UNKNOWN';end;",
      " ONE"

    assert_compiles_to "@case(2) @when(2) TWO @when(1) ONE @else UNKNOWN @endcase",
      "case(2);when 2;_out<<' TWO';when 1;_out<<' ONE';else;_out<<' UNKNOWN';end;",
      " TWO"

    assert_compiles_to "@case(3) @when(2) TWO @when(1) ONE @else UNKNOWN @endcase",
      "case(3);when 2;_out<<' TWO';when 1;_out<<' ONE';else;_out<<' UNKNOWN';end;",
      " UNKNOWN"
  end

  def test_multiple_when_arguments
    assert_compiles_to "@case(1) @when(1,2) ONE OR TWO @endcase",
      "case(1);when 1,2;_out<<' ONE OR TWO';end;",
      " ONE OR TWO"

    assert_compiles_to "@case(2) @when(1,2) ONE OR TWO @endcase",
      "case(2);when 1,2;_out<<' ONE OR TWO';end;",
      " ONE OR TWO"

    assert_compiles_to "@case(3) @when(1,2) ONE OR TWO @endcase",
      "case(3);when 1,2;_out<<' ONE OR TWO';end;",
      ""
  end

  ["checked", "disabled", "required", "selected", "readonly"].each do |statement|
    define_method(:"test_#{statement}") do
      assert_compiles_to "@#{statement}(true)", "if(true);_out<<'#{statement}';end;", "#{statement}"
      assert_compiles_to "@#{statement}(false)", "if(false);_out<<'#{statement}';end;", ""
    end
  end

  ["if", "unless", "checked", "disabled", "required", "selected", "readonly"].each do |statement|
    define_method(:"test_#{statement}_with_no_arguments") do
      exception = assert_raises Exception do
        BladeCompiler.compileString("@#{statement}()")
      end

      assert_equal "#{statement.capitalize} statement: wrong number of arguments (given 0, expecting 1)", exception.to_s
    end

    define_method(:"test_#{statement}_with_too_many_arguments") do
      exception = assert_raises Exception do
        BladeCompiler.compileString("@#{statement}(1, 2)")
      end

      assert_equal "#{statement.capitalize} statement: wrong number of arguments (given 2, expecting 1)", exception.to_s
    end
  end
end
