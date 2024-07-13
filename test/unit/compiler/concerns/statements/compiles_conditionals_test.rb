require_relative "../../../../test_case"
require_relative "../../../../../lib/compiler/blade_compiler"

class EchoTest < TestCase
  def test_if
    assert_compiles_to "@if ( true ) hi @endif", "if(true);_out<<' hi ';end;", " hi "
    assert_compiles_to "@if(true) hi @endif", "if(true);_out<<' hi ';end;", " hi "

    multilineString = "
      hi
    "
    assert_compiles_to "@if(true)#{multilineString}@endif", "if(true);_out<<'#{multilineString}';end;", "#{multilineString}"
  end

  def test_nested_if
    assert_compiles_to "@if(true) @if(true) foo @endif @if(false) baz @endif @if(true) bar @endif @endif",
      "if(true);_out<<' ';if(true);_out<<' foo ';end;_out<<' ';if(false);_out<<' baz ';end;_out<<' ';if(true);_out<<' bar ';end;_out<<' ';end;",
      "  foo    bar  "
  end

  def test_if_variables
    assert_compiles_to "@if ( foo == 'FOO' ){{bar}}@endif", "if(foo == 'FOO');_out<<h(bar);end;", "BAR"
  end

  def test_fails_with_wrong_arguments
    exception = assert_raises Exception do
      BladeCompiler.compileString("@if()")
    end
    assert_equal "If statement: wrong number of arguments (given 0, expecting 1)", exception.to_s


    exception = assert_raises Exception do
      BladeCompiler.compileString("@if(1, 2)")
    end
    assert_equal "If statement: wrong number of arguments (given 2, expecting 1)", exception.to_s
  end
end
