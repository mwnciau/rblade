require "test_case"

class CompilesComponentsTest < TestCase
  def test_components
    assert_compiles_to "<x-button>hello</x-button>", nil, '<button class="button">hello</button>'
    assert_compiles_to "<x-button disabled>hello</x-button>", nil, '<button class="button" disabled>hello</button>'
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
      '<button class="button block" type="button">hello</button>'

    assert_compiles_to "<x-nested_button type=submit>hello</x-nested_button>",
      nil,
      '<button class="button block" type="button">hello</button>'

    assert_compiles_to "<x-nested_button class=hidden>hello</x-nested_button>",
      nil,
      '<button class="button block hidden" type="button">hello</button>'
  end

  def test_slots
    assert_compiles_to "@ruby(label = 'hello')<x-button>{{label}}</x-button>",
      nil,
      '<button class="button">hello</button>'
    assert_compiles_to "<x-button><b>hello</b></x-button>", nil, '<button class="button"><b>hello</b></button>'
  end

  def test_props
    exception = assert_raises Exception do
      assert_compiles_to "<x-compiles_components_test.props/>",
        nil,
        ""
    end
    assert_equal "Props statement: firstName is not defined", exception.to_s

    assert_compiles_to "<x-compiles_components_test.props firstName=\"bob\"/>",
      nil,
      "bob"

    assert_compiles_to "<x-compiles_components_test.props firstName=\"bob\" :visible=false/>",
      nil,
      ""
  end

  def test_unsafe_close
    assert_compiles_to "<x-button>hello<//>", nil, '<button class="button">hello</button>'
  end

  def test_slot_components
    assert_compiles_to "<x-compiles_components_test.slot><x-slot::title>TITLE<//>SLOT<//>",
      nil,
      "TITLE - SLOT"

    assert_compiles_to "<x-compiles_components_test.slot><x-slot::title><strong>TITLE</strong><//>SLOT<//>",
      nil,
      "<strong>TITLE</strong> - SLOT"

    assert_compiles_to "<x-compiles_components_test.slot>SLOT<x-slot::title>TITLE<//><//>",
      nil,
      "TITLE - SLOT"

    assert_compiles_to "<x-compiles_components_test.slot>SL<x-slot::title>TITLE<//>OT<//>",
      nil,
      "TITLE - SLOT"
  end

  def test_slot_attributes
    assert_compiles_to "<x-compiles_components_test.slot-attributes><x-slot::title>TITLE<//>SLOT<//>",
      nil,
      "<div ><h1 >TITLE</h1>SLOT</div>"

    assert_compiles_to "<x-compiles_components_test.slot-attributes><x-slot::title a=b>TITLE<//>SLOT<//>",
      nil,
      '<div ><h1 a="b">TITLE</h1>SLOT</div>'

    assert_compiles_to "<x-compiles_components_test.slot-attributes a=B><x-slot::title a=b>TITLE<//>SLOT<//>",
      nil,
      '<div a="B"><h1 a="b">TITLE</h1>SLOT</div>'

    assert_compiles_to '
      <x-compiles_components_test.slot-attributes
        class="block mt-2"
        id="container"
        ><x-slot::title class="font-bold text-xl">TITLE</x-slot::title>
        <p>This is my content</p>
        <br>
        <p>Some more content</p>
      </x-compiles_components_test.slot-attributes>
    ',
      nil,
      '
      <div class="block mt-2" id="container"><h1 class="font-bold text-xl">TITLE</h1>
        <p>This is my content</p>
        <br>
        <p>Some more content</p>
      </div>
    '
  end

  def test_interpolated_attributes
    assert_compiles_to "<x-compiles_components_test.props firstName=\"{{ \"bob\" }}\"/>", nil, "bob"
    assert_compiles_to "<x-compiles_components_test.props firstName='b{{ 'o' }}b'/>", nil, "bob"
    assert_compiles_to "<x-compiles_components_test.props firstName={{ \"b\" }}{{'o'}}{{ 'B'.downcase }}/>", nil, "bob"
    assert_compiles_to "<x-compiles_components_test.props firstName=\"{{2}}\"/>", nil, "2"

    assert_compiles_to "<x-compiles_components_test.props firstName=\"{{\"/>", nil, "{{"

    assert_compiles_to "<x-compiles_components_test.props firstName=\"{{ '\"' }}\"/>", nil, "&quot;"
  end

  def test_empty_attributes
    assert_compiles_to '<x-button type="">hello</x-button>', nil, '<button class="button" type="">hello</button>'
  end

  def test_escaped_interpolated_attributes
    assert_compiles_to "<x-compiles_components_test.props firstName=\"@{{ bob }}\"/>", nil, "{{ bob }}"
    assert_compiles_to "<x-compiles_components_test.props firstName=\"@{{2}}\"/>", nil, "{{2}}"

    assert_compiles_to "<x-compiles_components_test.props firstName=\"@{{\"/>", nil, "{{"
  end

  def test_module_methods_are_accessible
    assert_compiles_to "<x-compiles_components_test.params/>", nil, "user@example.com"
  end

  def test_end_tag_checking
    exception = assert_raises Exception do
      assert_compiles_to "<x-button>", nil, ""
    end
    assert_equal "Unexpected end of document. Expecting </x-button>", exception.to_s
    exception = assert_raises Exception do
      assert_compiles_to "</x-button>", nil, ""
    end
    assert_equal "Unexpected closing tag </x-button>", exception.to_s

    exception = assert_raises Exception do
      assert_compiles_to "<x-button><x-link></x-button>", nil, ""
    end
    assert_equal "Unexpected closing tag </x-button>, expecting </x-link>", exception.to_s
  end
end
