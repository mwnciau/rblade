require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"

class CompilesComponentsTest < TestCase
  def test_end
    assert_compiles_to %[
      <x-component
        attribute="value"
        :special="special value"
        :pass_through
        @class({cake: "one"})
        @style({cake: "two"})
        cheese=yes
        readonly
        ::escaped="I only have one colon"
      >
    ], ""
  end
end
