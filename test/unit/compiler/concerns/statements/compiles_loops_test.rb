require_relative "../../../../test_case"
require_relative "../../../../../lib/compiler/blade_compiler"

class CompilesLoopsTest < TestCase
  def test_while
    assert_compiles_to "@ruby(i = 0) @while(i < 5) {{ i += 1 }} @endwhile",
      "i = 0;while i < 5;_out<<h(i += 1);end;",
      "12345"
  end

  def test_for
    assert_compiles_to "@for(i in 1..5) {{ i }} @endfor",
      "for i in 1..5;_out<<h(i);end;",
      "12345"
  end

  def test_until
    assert_compiles_to "@ruby(i = 0) @until(i == 5) {{ i += 1 }} @endwhile",
      "i = 0;until i == 5;_out<<h(i += 1);end;",
      "12345"
  end

  def test_break
    assert_compiles_to "@break", "break;"
    assert_compiles_to "@ruby(i = 0) @while(true) @if(i == 5) @break @endif {{ i += 1 }} @endwhile",
      "i = 0;while true;if i == 5;break;end;_out<<h(i += 1);end;",
      "12345"

    assert_compiles_to "@breakif(true)", "if true;break;end;"
    assert_compiles_to "@ruby(i = 0) @while(true) @breakif(i == 5) {{ i += 1 }} @endwhile",
      "i = 0;while true;if i == 5;break;end;_out<<h(i += 1);end;",
      "12345"
  end

  def test_next
    assert_compiles_to "@next", "next;"
    assert_compiles_to "@next(5)", "next 5;"
    assert_compiles_to "@ruby(i = 0) @while(i < 5) @ruby(i += 1) @if(i == 3) @next @endif {{ i }} @endwhile",
      "i = 0;while i < 5;i += 1;if i == 3;next;end;_out<<h(i);end;",
      "1245"

    assert_compiles_to "@nextif(true)", "if true;next;end;"
    assert_compiles_to "@nextif(true, 5)", "if true;next 5;end;"
    assert_compiles_to "@ruby(i = 0) @while(i < 5) @ruby(i += 1) @nextif(i == 3) {{ i }} @endwhile",
      "i = 0;while i < 5;i += 1;if i == 3;next;end;_out<<h(i);end;",
      "1245"
  end
end
