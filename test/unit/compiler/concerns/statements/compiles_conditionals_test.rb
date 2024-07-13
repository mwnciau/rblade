require_relative "../../../../test_case"
require_relative "../../../../../lib/compiler/blade_compiler"

class EchoTest < TestCase
  MULTILINE_STRING = "
    this
    string
    has
    multiple
    lines
  "

  def test_nested_statements
    assert_compiles_to "@if(true) @if(true) foo @endif @if(false) baz @endif @if(true) bar @endif @endif",
      "if(true);_out<<' ';if(true);_out<<' foo ';end;_out<<' ';if(false);_out<<' baz ';end;_out<<' ';if(true);_out<<' bar ';end;_out<<' ';end;",
      "  foo    bar  "
  end

  def test_if
    assert_compiles_to "@if ( true ) hi @endif", "if(true);_out<<' hi ';end;", " hi "
    assert_compiles_to "@if(true) hi @endif", "if(true);_out<<' hi ';end;", " hi "
    assert_compiles_to "@if(false) hi @endif", "if(false);_out<<' hi ';end;", ""
    assert_compiles_to "@if(true)#{MULTILINE_STRING}@endif", "if(true);_out<<'#{MULTILINE_STRING}';end;", "#{MULTILINE_STRING}"
    assert_compiles_to "@if ( foo == 'FOO' ){{bar}}@endif", "if(foo == 'FOO');_out<<h(bar);end;", "BAR"
  end

  def test_unless
    assert_compiles_to "@unless ( false ) hi @endunless", "unless(false);_out<<' hi ';end;", " hi "
    assert_compiles_to "@unless(false) hi @endunless", "unless(false);_out<<' hi ';end;", " hi "
    assert_compiles_to "@unless(true) hi @endunless", "unless(true);_out<<' hi ';end;", ""
    assert_compiles_to "@unless(false)#{MULTILINE_STRING}@endunless", "unless(false);_out<<'#{MULTILINE_STRING}';end;", "#{MULTILINE_STRING}"
    assert_compiles_to "@unless( foo == 'BAR' ){{bar}}@endif", "unless(foo == 'BAR');_out<<h(bar);end;", "BAR"
  end

  ['checked', 'disabled', 'required', 'selected', 'readonly'].each do |statement|
    define_method("test_#{statement}") do
      assert_compiles_to "@#{statement}(true)", "if(true);_out<<'#{statement}';end;", "#{statement}"
      assert_compiles_to "@#{statement}(false)", "if(false);_out<<'#{statement}';end;", ""
    end
  end

  ['if', 'unless', 'checked', 'disabled', 'required', 'selected', 'readonly'].each do |statement|
    define_method("test_#{statement}_with_no_arguments") do
      exception = assert_raises Exception do
        BladeCompiler.compileString("@#{statement}()")
      end

      assert_equal "#{statement.capitalize} statement: wrong number of arguments (given 0, expecting 1)", exception.to_s
    end

    define_method("test_#{statement}_with_too_many_arguments") do
      exception = assert_raises Exception do
        BladeCompiler.compileString("@#{statement}(1, 2)")
      end

      assert_equal "#{statement.capitalize} statement: wrong number of arguments (given 2, expecting 1)", exception.to_s
    end
  end
end
