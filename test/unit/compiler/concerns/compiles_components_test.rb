require "test_case"

class CompilesComponentsTest < TestCase
  def test_components
    assert_compiles_to "<x-button>hello</x-button>", nil, '<button class="button">hello</button>'
    assert_compiles_to "<x-button/>", nil, '<button class="button"></button>'
    assert_compiles_to "<x-link href=#>visit</x-link>", nil, '<a href="#">visit</a>'
    assert_compiles_to "<x-profile name='bob'>Bob's name is Bob</x-profile>",
      nil,
      '<div class="profile"><h2>Bob</h2>Bob&#39;s name is Bob<button class="button">View</button></div>'
  end

  def test_slot_html
    assert_compiles_to "<x-button><b>hello</b></x-button>", nil, '<button class="button"><b>hello</b></button>'
  end
end
