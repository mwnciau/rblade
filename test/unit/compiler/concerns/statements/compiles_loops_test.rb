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

  def test_for_else
    assert_compiles_to "@forelse(i in []) {{ i }} @empty 0 @endforelse",
      "_fe_empty_1=true;for i in [];_fe_empty_1=false;_out<<h(i);end;if _fe_empty_1;_out<<'0';end;",
      "0"

    assert_compiles_to "@forelse(i in 1..1) {{ i }} @empty 0 @endforelse",
      "_fe_empty_1=true;for i in 1..1;_fe_empty_1=false;_out<<h(i);end;if _fe_empty_1;_out<<'0';end;",
      "1"
  end

  def test_nested_for_else
    assert_compiles_to "@forelse(i in 1..1) @forelse(i in []) {{ i }} @empty 8 @endforelse @empty 9 @endforelse",
      "_fe_empty_1=true;for i in 1..1;_fe_empty_1=false;_fe_empty_2=true;for i in [];_fe_empty_2=false;_out<<h(i);end;if _fe_empty_2;_out<<'8';end;end;if _fe_empty_1;_out<<'9';end;",
      "8"
  end
end
