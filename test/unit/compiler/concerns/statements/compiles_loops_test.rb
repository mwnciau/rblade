require "test_case"

class CompilesLoopsTest < TestCase
  def test_while
    assert_compiles_to "@ruby(i = 0) @while(i < 5) {{ i += 1 }} @endwhile",
      "i = 0;while i < 5;_out<<RBlade.e(i += 1);end;",
      "12345"
  end

  def test_for
    assert_compiles_to "@for(i in 1..5) {{ i }} @endfor",
      "for i in 1..5;_out<<RBlade.e(i);end;",
      "12345"
  end

  def test_until
    assert_compiles_to "@ruby(i = 0) @until(i == 5) {{ i += 1 }} @endwhile",
      "i = 0;until i == 5;_out<<RBlade.e(i += 1);end;",
      "12345"
  end

  def test_break
    assert_compiles_to "@break", "break;"
    assert_compiles_to "@ruby(i = 0) @while(true) @if(i == 5) @break @endif {{ i += 1 }} @endwhile",
      "i = 0;while true;if i == 5;break;end;_out<<RBlade.e(i += 1);end;",
      "12345"

    assert_compiles_to "@break(true)", "if true;break;end;"
    assert_compiles_to "@ruby(i = 0) @while(true) @break(i == 5) {{ i += 1 }} @endwhile",
      "i = 0;while true;if i == 5;break;end;_out<<RBlade.e(i += 1);end;",
      "12345"
  end

  def test_next
    assert_compiles_to "@next", "next;"
    assert_compiles_to "@ruby(i = 0) @while(i < 5) @ruby(i += 1) @if(i == 3) @next @endif {{ i }} @endwhile",
      "i = 0;while i < 5;i += 1;if i == 3;next;end;_out<<RBlade.e(i);end;",
      "1245"

    assert_compiles_to "@next(true)", "if true;next;end;"
    assert_compiles_to "@ruby(i = 0) @while(i < 5) @ruby(i += 1) @next(i == 3) {{ i }} @endwhile",
      "i = 0;while i < 5;i += 1;if i == 3;next;end;_out<<RBlade.e(i);end;",
      "1245"
  end

  def test_for_else
    assert_compiles_to "@forelse(i in []) {{ i }} @empty 0 @endforelse",
      "_looped_1=false;for i in [];_looped_1=true;_out<<RBlade.e(i);end;if !_looped_1;_out<<'0';end;",
      "0"

    assert_compiles_to "@forelse(i in 1..1) {{ i }} @empty 0 @endforelse",
      "_looped_1=false;for i in 1..1;_looped_1=true;_out<<RBlade.e(i);end;if !_looped_1;_out<<'0';end;",
      "1"
  end

  def test_nested_for_else
    assert_compiles_to "@forelse(i in 1..1) @forelse(i in []) {{ i }} @empty 8 @endforelse @empty 9 @endforelse",
      "_looped_1=false;for i in 1..1;_looped_1=true;_looped_2=false;for i in [];_looped_2=true;_out<<RBlade.e(i);end;if !_looped_2;_out<<'8';end;end;if !_looped_1;_out<<'9';end;",
      "8"
  end

  def test_each
    assert_compiles_to "@each(a in [1, 2, 3]) {{ a }} @endEach",
      "[1, 2, 3].each do |a|;_out<<RBlade.e(a);end;",
      "123"

    assert_compiles_to "@each(a, b in {a:1, b:2, c:3}) {{ a }}{{ b }} @endEach",
      "{a:1, b:2, c:3}.each do |a,b|;_out<<RBlade.e(a);_out<<RBlade.e(b);end;",
      "a1b2c3"
  end

  def test_eachelse
    assert_compiles_to "@eachElse(a in []) {{ a }} @empty 0 @endEach",
      "_looped_1=false;[].each do |a|;_looped_1=true;_out<<RBlade.e(a);end;if !_looped_1;_out<<'0';end;",
      "0"

    assert_compiles_to "@eachElse(a in [1]) {{ a }} @empty 0 @endEach",
      "_looped_1=false;[1].each do |a|;_looped_1=true;_out<<RBlade.e(a);end;if !_looped_1;_out<<'0';end;",
      "1"

    assert_compiles_to "@eachElse(a, b in {}) {{ a }}{{ b }} @empty 0 @endEach",
      "_looped_1=false;{}.each do |a,b|;_looped_1=true;_out<<RBlade.e(a);_out<<RBlade.e(b);end;if !_looped_1;_out<<'0';end;",
      "0"

    assert_compiles_to "@eachElse(a, b in {a:1}) {{ a }}{{ b }} @empty 0 @endEach",
      "_looped_1=false;{a:1}.each do |a,b|;_looped_1=true;_out<<RBlade.e(a);_out<<RBlade.e(b);end;if !_looped_1;_out<<'0';end;",
      "a1"
  end

  def test_eachwithindex
    assert_compiles_to "@eachWithIndex(a in ['a', 'b', 'c']) {{ a }} @endEachWithIndex",
      "['a', 'b', 'c'].each_with_index do |a|;_out<<RBlade.e(a);end;",
      "abc"

    assert_compiles_to "@eachWithIndex(a, b in ['a', 'b', 'c']) {{ a }}{{ b }} @endEachWithIndex",
      "['a', 'b', 'c'].each_with_index do |a,b|;_out<<RBlade.e(a);_out<<RBlade.e(b);end;",
      "a0b1c2"

    assert_compiles_to "@eachWithIndex(a in {a:1, b:2, c:3}) {{ a }} @endEachWithIndex",
      "{a:1, b:2, c:3}.each_with_index do |a|;_out<<RBlade.e(a);end;",
      "[:a, 1][:b, 2][:c, 3]"

    assert_compiles_to "@eachWithIndex(a, b in {a:1, b:2, c:3}) {{ a }}{{ b }} @endEachWithIndex",
      "{a:1, b:2, c:3}.each_with_index do |a,b|;_out<<RBlade.e(a);_out<<RBlade.e(b);end;",
      "[:a, 1]0[:b, 2]1[:c, 3]2"

    assert_compiles_to "@eachWithIndex(a, b, c in {a:1, b:2, c:3}) {{ a }}{{ b }}{{ c }} @endEachWithIndex",
      "{a:1, b:2, c:3}.each_with_index do |_ivar,c|;a,b=_ivar;_out<<RBlade.e(a);_out<<RBlade.e(b);_out<<RBlade.e(c);end;",
      "a10b21c32"
  end

  def test_eachwithindexelse
    assert_compiles_to "@eachWithIndexElse(a in []) {{ a }} @empty 0 @endEach",
      "_looped_1=false;[].each_with_index do |a|;_looped_1=true;_out<<RBlade.e(a);end;if !_looped_1;_out<<'0';end;",
      "0"

    assert_compiles_to "@eachWithIndexElse(a in [1]) {{ a }} @empty 0 @endEach",
      "_looped_1=false;[1].each_with_index do |a|;_looped_1=true;_out<<RBlade.e(a);end;if !_looped_1;_out<<'0';end;",
      "1"

    assert_compiles_to "@eachWithIndexElse(a, b in {}) {{ a }}{{ b }} @empty 0 @endEach",
      "_looped_1=false;{}.each_with_index do |a,b|;_looped_1=true;_out<<RBlade.e(a);_out<<RBlade.e(b);end;if !_looped_1;_out<<'0';end;",
      "0"

    assert_compiles_to "@eachWithIndexElse(a, b in {a:1}) {{ a }}{{ b }} @empty 0 @endEach",
      "_looped_1=false;{a:1}.each_with_index do |a,b|;_looped_1=true;_out<<RBlade.e(a);_out<<RBlade.e(b);end;if !_looped_1;_out<<'0';end;",
      "[:a, 1]0"

    assert_compiles_to "@eachWithIndexElse(a, b, c in {}) {{ a }}{{ b }}{{ c }} @empty 0 @endEach",
      "_looped_1=false;{}.each_with_index do |_ivar,c|;a,b=_ivar;_looped_1=true;_out<<RBlade.e(a);_out<<RBlade.e(b);_out<<RBlade.e(c);end;if !_looped_1;_out<<'0';end;",
      "0"

    assert_compiles_to "@eachWithIndexElse(a, b, c in {a:1}) {{ a }}{{ b }}{{ c }} @empty 0 @endEach",
      "_looped_1=false;{a:1}.each_with_index do |_ivar,c|;a,b=_ivar;_looped_1=true;_out<<RBlade.e(a);_out<<RBlade.e(b);_out<<RBlade.e(c);end;if !_looped_1;_out<<'0';end;",
      "a10"
  end
end
