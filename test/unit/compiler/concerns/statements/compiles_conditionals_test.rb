require "test_case"

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
      "if true;if true;@output_buffer.raw_buffer<<-'foo';end;if false;@output_buffer.raw_buffer<<-'baz';end;if true;@output_buffer.raw_buffer<<-'bar';end;end;",
      "foobar"
  end

  def test_if
    assert_compiles_to "@if ( true ) hi @endif", "if true;@output_buffer.raw_buffer<<-'hi';end;", "hi"
    assert_compiles_to "@if(true) hi @endif", "if true;@output_buffer.raw_buffer<<-'hi';end;", "hi"
    assert_compiles_to "@if(false) hi @endif", "if false;@output_buffer.raw_buffer<<-'hi';end;", ""
    assert_compiles_to "@if(true) #{MULTILINE_STRING} @endif", "if true;@output_buffer.raw_buffer<<-'#{MULTILINE_STRING}';end;", MULTILINE_STRING
    assert_compiles_to "@if ( foo == 'FOO' ){{bar}} @endif", "if foo == 'FOO';@output_buffer.append=bar;end;", "BAR"
  end

  def test_blank
    assert_compiles_to "@blank?(nil) blank! @endblank?", "if (nil).blank?;@output_buffer.raw_buffer<<-'blank!';end;", "blank!"
    assert_compiles_to "@blank?(true) blank! @endblank?", "if (true).blank?;@output_buffer.raw_buffer<<-'blank!';end;", ""
    assert_compiles_to "@blank?(false) blank! @endblank?", "if (false).blank?;@output_buffer.raw_buffer<<-'blank!';end;", "blank!"
    assert_compiles_to "@blank?('abc') blank! @endblank?", "if ('abc').blank?;@output_buffer.raw_buffer<<-'blank!';end;", ""
    assert_compiles_to "@blank?('') blank! @endblank?", "if ('').blank?;@output_buffer.raw_buffer<<-'blank!';end;", "blank!"
    assert_compiles_to "@blank?(' ') blank! @endblank?", "if (' ').blank?;@output_buffer.raw_buffer<<-'blank!';end;", "blank!"
    assert_compiles_to "@blank?([]) blank! @endblank?", "if ([]).blank?;@output_buffer.raw_buffer<<-'blank!';end;", "blank!"
    assert_compiles_to "@blank?({}) blank! @endblank?", "if ({}).blank?;@output_buffer.raw_buffer<<-'blank!';end;", "blank!"
  end

  def test_defined
    assert_compiles_to "@defined?(foo) defined! @enddefined?", "if defined? foo;@output_buffer.raw_buffer<<-'defined!';end;", "defined!"
    assert_compiles_to "@defined?(bar) defined! @enddefined?", "if defined? bar;@output_buffer.raw_buffer<<-'defined!';end;", "defined!"
    assert_compiles_to "@defined?(baz) defined! @enddefined?", "if defined? baz;@output_buffer.raw_buffer<<-'defined!';end;", ""
  end

  def test_empty
    assert_compiles_to "@empty?('abc') empty! @endempty?", "if ('abc').empty?;@output_buffer.raw_buffer<<-'empty!';end;", ""
    assert_compiles_to "@empty?('') empty! @endempty?", "if ('').empty?;@output_buffer.raw_buffer<<-'empty!';end;", "empty!"
    assert_compiles_to "@empty?(' ') empty! @endempty?", "if (' ').empty?;@output_buffer.raw_buffer<<-'empty!';end;", ""
    assert_compiles_to "@empty?([]) empty! @endempty?", "if ([]).empty?;@output_buffer.raw_buffer<<-'empty!';end;", "empty!"
    assert_compiles_to "@empty?({}) empty! @endempty?", "if ({}).empty?;@output_buffer.raw_buffer<<-'empty!';end;", "empty!"
  end

  def test_nil
    assert_compiles_to "@nil?(nil) nil! @endnil?", "if (nil).nil?;@output_buffer.raw_buffer<<-'nil!';end;", "nil!"
    assert_compiles_to "@nil?(true) nil! @endnil?", "if (true).nil?;@output_buffer.raw_buffer<<-'nil!';end;", ""
    assert_compiles_to "@nil?(false) nil! @endnil?", "if (false).nil?;@output_buffer.raw_buffer<<-'nil!';end;", ""
    assert_compiles_to "@nil?('abc') nil! @endnil?", "if ('abc').nil?;@output_buffer.raw_buffer<<-'nil!';end;", ""
    assert_compiles_to "@nil?('') nil! @endnil?", "if ('').nil?;@output_buffer.raw_buffer<<-'nil!';end;", ""
    assert_compiles_to "@nil?(' ') nil! @endnil?", "if (' ').nil?;@output_buffer.raw_buffer<<-'nil!';end;", ""
    assert_compiles_to "@nil?([]) nil! @endnil?", "if ([]).nil?;@output_buffer.raw_buffer<<-'nil!';end;", ""
    assert_compiles_to "@nil?({}) nil! @endnil?", "if ({}).nil?;@output_buffer.raw_buffer<<-'nil!';end;", ""
  end

  def test_present
    assert_compiles_to "@present?(nil) present! @endpresent?", "if (nil).present?;@output_buffer.raw_buffer<<-'present!';end;", ""
    assert_compiles_to "@present?(true) present! @endpresent?", "if (true).present?;@output_buffer.raw_buffer<<-'present!';end;", "present!"
    assert_compiles_to "@present?(false) present! @endpresent?", "if (false).present?;@output_buffer.raw_buffer<<-'present!';end;", ""
    assert_compiles_to "@present?('abc') present! @endpresent?", "if ('abc').present?;@output_buffer.raw_buffer<<-'present!';end;", "present!"
    assert_compiles_to "@present?('') present! @endpresent?", "if ('').present?;@output_buffer.raw_buffer<<-'present!';end;", ""
    assert_compiles_to "@present?(' ') present! @endpresent?", "if (' ').present?;@output_buffer.raw_buffer<<-'present!';end;", ""
    assert_compiles_to "@present?([]) present! @endpresent?", "if ([]).present?;@output_buffer.raw_buffer<<-'present!';end;", ""
    assert_compiles_to "@present?({}) present! @endpresent?", "if ({}).present?;@output_buffer.raw_buffer<<-'present!';end;", ""
  end

  def test_elsif
    assert_compiles_to "@if(false) @elsif ( true ) hi @endif", "if false;elsif true;@output_buffer.raw_buffer<<-'hi';end;", "hi"
    assert_compiles_to "@if(false) @elsif(true) hi @endif", "if false;elsif true;@output_buffer.raw_buffer<<-'hi';end;", "hi"
    assert_compiles_to "@if(false) @elsif(false) hi @endif", "if false;elsif false;@output_buffer.raw_buffer<<-'hi';end;", ""
    assert_compiles_to "@if(false) @elsif(true) #{MULTILINE_STRING} @endif", "if false;elsif true;@output_buffer.raw_buffer<<-'#{MULTILINE_STRING}';end;", MULTILINE_STRING
    assert_compiles_to "@if(false) @elsif ( foo == 'FOO' ){{bar}} @endif", "if false;elsif foo == 'FOO';@output_buffer.append=bar;end;", "BAR"
  end

  def test_else
    assert_compiles_to "@if ( false ) @else hi @endif", "if false;else;@output_buffer.raw_buffer<<-'hi';end;", "hi"
    assert_compiles_to "@if(false) @else hi @endif", "if false;else;@output_buffer.raw_buffer<<-'hi';end;", "hi"
    assert_compiles_to "@if(true) @else hi @endif", "if true;else;@output_buffer.raw_buffer<<-'hi';end;", ""
    assert_compiles_to "@if(false) @else #{MULTILINE_STRING} @endif", "if false;else;@output_buffer.raw_buffer<<-'#{MULTILINE_STRING}';end;", MULTILINE_STRING
    assert_compiles_to "@if ( foo == 'BAR' ) @else{{bar}} @endif", "if foo == 'BAR';else;@output_buffer.append=bar;end;", "BAR"
  end

  def test_unless
    assert_compiles_to "@unless ( false ) hi @endunless", "unless false;@output_buffer.raw_buffer<<-'hi';end;", "hi"
    assert_compiles_to "@unless(false) hi @endunless", "unless false;@output_buffer.raw_buffer<<-'hi';end;", "hi"
    assert_compiles_to "@unless(true) hi @endunless", "unless true;@output_buffer.raw_buffer<<-'hi';end;", ""
    assert_compiles_to "@unless(false) #{MULTILINE_STRING} @endunless", "unless false;@output_buffer.raw_buffer<<-'#{MULTILINE_STRING}';end;", MULTILINE_STRING
    assert_compiles_to "@unless( foo == 'BAR' ){{bar}} @endif", "unless foo == 'BAR';@output_buffer.append=bar;end;", "BAR"
  end

  def test_case_when
    assert_compiles_to "@case(1) @when(2) TWO @when(1) ONE @else UNKNOWN @endcase",
      "case 1;when 2;@output_buffer.raw_buffer<<-'TWO';when 1;@output_buffer.raw_buffer<<-'ONE';else;@output_buffer.raw_buffer<<-'UNKNOWN';end;",
      "ONE"

    assert_compiles_to "@case(2) @when(2) TWO @when(1) ONE @else UNKNOWN @endcase",
      "case 2;when 2;@output_buffer.raw_buffer<<-'TWO';when 1;@output_buffer.raw_buffer<<-'ONE';else;@output_buffer.raw_buffer<<-'UNKNOWN';end;",
      "TWO"

    assert_compiles_to "@case(3) @when(2) TWO @when(1) ONE @else UNKNOWN @endcase",
      "case 3;when 2;@output_buffer.raw_buffer<<-'TWO';when 1;@output_buffer.raw_buffer<<-'ONE';else;@output_buffer.raw_buffer<<-'UNKNOWN';end;",
      "UNKNOWN"
  end

  def test_multiple_when_arguments
    assert_compiles_to "@case(1) @when(1,2) ONE OR TWO @endcase",
      "case 1;when 1,2;@output_buffer.raw_buffer<<-'ONE OR TWO';end;",
      "ONE OR TWO"

    assert_compiles_to "@case(2) @when(1,2) ONE OR TWO @endcase",
      "case 2;when 1,2;@output_buffer.raw_buffer<<-'ONE OR TWO';end;",
      "ONE OR TWO"

    assert_compiles_to "@case(3) @when(1,2) ONE OR TWO @endcase",
      "case 3;when 1,2;@output_buffer.raw_buffer<<-'ONE OR TWO';end;",
      ""
  end

  def test_when_edge_cases
    assert_compiles_to "
        @case(1)
        @when(1)
          ONE
        @when(2)
          TWO
        @endcase
      ",
      nil,
      "
                 ONE
             "
  end

  ["checked", "disabled", "required", "selected", "readonly"].each do |statement|
    define_method(:"test_#{statement}") do
      assert_compiles_to "@#{statement}(true)", "if true;@output_buffer.raw_buffer<<-'#{statement}';end;", statement
      assert_compiles_to "@#{statement}(false)", "if false;@output_buffer.raw_buffer<<-'#{statement}';end;", ""
    end
  end

  ["if", "unless", "checked", "disabled", "required", "selected", "readonly", "env"].each do |statement|
    define_method(:"test_#{statement}_with_no_arguments") do
      exception = assert_raises Exception do
        RBlade::Compiler.compile_string("@#{statement}()", RBlade::ComponentStore.new)
      end

      assert_equal "#{statement.capitalize} statement: wrong number of arguments (given 0, expecting 1)", exception.to_s
    end

    define_method(:"test_#{statement}_with_too_many_arguments") do
      exception = assert_raises Exception do
        RBlade::Compiler.compile_string("@#{statement}(1, 2)", RBlade::ComponentStore.new)
      end

      assert_equal "#{statement.capitalize} statement: wrong number of arguments (given 2, expecting 1)", exception.to_s
    end
  end

  def test_env
    Rails.env = "production"
    assert_compiles_to "@env('production') production @endenv",
      "if Array.wrap('production').include?(Rails.env);@output_buffer.raw_buffer<<-'production';end;",
      "production"
    assert_compiles_to "@env(['production']) production @endenv", nil, "production"
    assert_compiles_to "@env(['production', 'development']) production @endenv", nil, "production"

    Rails.env = "development"
    assert_compiles_to "@env ( 'production' ) production @endenv",
      "if Array.wrap('production').include?(Rails.env);@output_buffer.raw_buffer<<-'production';end;",
      ""
    assert_compiles_to "@env(['production']) production @endenv", nil, ""
    assert_compiles_to "@env(['production', 'development']) production @endenv", nil, "production"
  end

  def test_production
    Rails.env = "production"
    assert_compiles_to "@production production @endenv",
      "if Rails.env.production?;@output_buffer.raw_buffer<<-'production';end;",
      "production"

    Rails.env = "development"
    assert_compiles_to "@production production @endenv",
      "if Rails.env.production?;@output_buffer.raw_buffer<<-'production';end;",
      ""
  end
end
