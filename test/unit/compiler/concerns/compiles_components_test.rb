require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"

class CompilesComponentsTest < TestCase
  def test_end
    assert_compiles_to "<x-button>hello</x-button>", nil, '<button class="button">hello</button>'
    assert_compiles_to "<x-button/>", nil, '<button class="button"></button>'
    assert_compiles_to "<x-link href=#>visit</x-link>", nil, '<a href="#">visit</a>'
    assert_compiles_to "<x-profile name='bob'>Bob's name is Bob</x-profile>",
      nil,
      '<div class="profile"><h2>Bob</h2>Bob&apos;s name is Bob<button class="button">View</button></div>'
  end
end
