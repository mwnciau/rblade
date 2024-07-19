require_relative "../../../../test_case"
require_relative "../../../../../lib/compiler/blade_compiler"

class CompilesLoopsTest < TestCase
  def test_while
    assert_compiles_to "@ruby(i = 0) @while(i < 5) {{ i += 1 }} @endwhile",
     "i = 0;while(i < 5);_out<<h(i += 1);end;",
     "12345"
  end
end
