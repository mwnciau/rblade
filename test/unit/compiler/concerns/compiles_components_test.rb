require "test_case"

class CompilesComponentsTest < TestCase
  def test_components
    assert_compiles_to "<x-button>hello</x-button>", nil, '<button class="button">hello</button>'
    assert_compiles_to "<x-button disabled>hello</x-button>", nil, '<button class="button" disabled="disabled">hello</button>'
    assert_compiles_to "<x-button/>", nil, '<button class="button"></button>'
    assert_compiles_to "<x-link href=#>visit</x-link>", nil, '<a href="#">visit</a>'
    assert_compiles_to "<x-profile name='bob'>Bob's name is Bob</x-profile>",
      nil,
      '<div class="profile"><h2>Bob</h2>Bob\'s name is Bob<button class="button">View</button></div>'
  end

  def test_nested_components
    assert_compiles_to "<x-profile name='bob'><x-button>hello</x-button></x-profile>",
      nil,
      '<div class="profile"><h2>Bob</h2><button class="button">hello</button><button class="button">View</button></div>'

    assert_compiles_to "<x-nested_button type=button>hello</x-nested_button>",
      nil,
      '<button class="button mx-2 block" type="button">hello</button>'

    assert_compiles_to "<x-nested_button type=submit>hello</x-nested_button>",
      nil,
      '<button class="button mx-2 block" type="button">hello</button>'

    assert_compiles_to "<x-nested_button class=hidden>hello</x-nested_button>",
      nil,
      '<button class="button mx-2 block hidden" type="button">hello</button>'
  end

  def test_slots
    assert_compiles_to "@ruby(label = 'hello')<x-button>{{label}}</x-button>",
      nil,
      '<button class="button">hello</button>'
    assert_compiles_to "<x-button><b>hello</b></x-button>", nil, '<button class="button"><b>hello</b></button>'
  end

  def test_attributes_and_props
    exception = assert_raises Exception do
      assert_compiles_to "<x-folder.props/>",
        nil,
        ""
    end
    assert_equal "Props statement: firstName is not defined", exception.to_s

    assert_compiles_to "<x-folder.props firstName=\"bob\"/>",
      nil,
      "bob"

    assert_compiles_to "<x-folder.props firstName=\"bob\" :visible=false/>",
      nil,
      ""
  end
end
