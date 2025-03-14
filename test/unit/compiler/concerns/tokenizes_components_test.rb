require "test_case"

class TokenizesComponentsTest < TestCase
  def assert_tokenizes_to template, expected
    tokens = [Token.new(:unprocessed, template)]
    RBlade::TokenizesComponents.new.tokenize!(tokens)

    expected.each.with_index do |expected_item, i|
      if expected_item.is_a?(Hash) && !expected_item[:token_type].nil?
        assert_equal expected_item[:token_type], tokens[i].type
        expected_item.delete :token_type
      end

      assert_equal expected_item, tokens[i].value
    end
  end

  def test_tokenize_opening_tags
    assert_tokenizes_to "<x-banana>", [{name: "banana", attributes: [], token_type: :component_start}]
    assert_tokenizes_to "<x:banana>", [{name: "banana", attributes: [], token_type: :component_start}]
    assert_tokenizes_to "<x-banana>", [{name: "banana", attributes: [], token_type: :component_start}]
    assert_tokenizes_to "<x-apple> <x-banana>", [
      {name: "apple", attributes: []},
      " ",
      {name: "banana", attributes: []}
    ]
    assert_tokenizes_to "<   x-banana   >", [{name: "banana", attributes: []}]
    assert_tokenizes_to "<
      x-banana
    >", [{name: "banana", attributes: []}]
  end

  def test_tokenize_self_closing_tags
    assert_tokenizes_to "<x-banana/>", [{name: "banana", attributes: [], token_type: :component}]
    assert_tokenizes_to "<x:banana/>", [{name: "banana", attributes: [], token_type: :component}]
    assert_tokenizes_to "<   x-banana   />", [{name: "banana", attributes: [], token_type: :component}]
    assert_tokenizes_to "<x-banana a=b />", [{name: "banana", attributes: [{name: "a", value: "b", type: "string"}], token_type: :component}]
  end

  def test_tokenize_closing_tags
    assert_tokenizes_to "</x-banana>", [{name: "banana", token_type: :component_end}]
    assert_tokenizes_to "</x:banana>", [{name: "banana", token_type: :component_end}]
    assert_tokenizes_to "</    x-banana   >", [{name: "banana", token_type: :component_end}]
  end

  def test_invalid_tags
    assert_tokenizes_to "<x-banana a=>", ["<x-banana a=>"]
    assert_tokenizes_to "<x-banana a='>''>", ["<x-banana a='>''>"]
    assert_tokenizes_to '<x-banana a=""">', ['<x-banana a=""">']
    assert_tokenizes_to '<x-banana "a">', ['<x-banana "a">']
    assert_tokenizes_to "<x-banana/ >", ["<x-banana/ >"]
    assert_tokenizes_to "< /x-banana>", ["< /x-banana>"]
    assert_tokenizes_to "<x->", ["<x->"]
    assert_tokenizes_to "<x-<>", ["<x-<>"]

    assert_tokenizes_to "<x-banana <x-apple>>", ["<x-banana ", {name: "apple", attributes: []}, ">"]
  end

  def test_tokenize_single_attributes
    assert_tokenizes_to "<x-a attribute='value'>", [{name: "a", attributes: [{name: "attribute", value: "value", type: "string"}]}]
    assert_tokenizes_to '<x-a b="c">', [{name: "a", attributes: [{name: "b", value: "c", type: "string"}]}]
    assert_tokenizes_to '<x-a :b="c">', [{name: "a", attributes: [{name: "b", value: "c", type: "ruby"}]}]
    assert_tokenizes_to '<x-a ::b="c">', [{name: "a", attributes: [{name: ":b", value: "c", type: "string"}]}]
    assert_tokenizes_to "<x-a b=c>", [{name: "a", attributes: [{name: "b", value: "c", type: "string"}]}]
    assert_tokenizes_to "<x-a :b>", [{name: "a", attributes: [{name: "b", type: "pass_through"}]}]
    assert_tokenizes_to "<x-a b>", [{name: "a", attributes: [{name: "b", type: "empty"}]}]

    assert_tokenizes_to '<x-a      b="c"    >', [{name: "a", attributes: [{name: "b", value: "c", type: "string"}]}]
    assert_tokenizes_to '<x-a
      b="c"
    >', [{name: "a", attributes: [{name: "b", value: "c", type: "string"}]}]
  end

  def test_tokenize_empty_attributes
    assert_tokenizes_to "<x-a attribute=''>", [{name: "a", attributes: [{name: "attribute", value: "", type: "string"}]}]
    assert_tokenizes_to '<x-a attribute="">', [{name: "a", attributes: [{name: "attribute", value: "", type: "string"}]}]
    assert_tokenizes_to '<x-a attribute="">hello</x-a>', [{name: "a", attributes: [{name: "attribute", value: "", type: "string"}]}, "hello", {name: "a"}]
  end

  def test_tokenize_string_interpolation
    assert_tokenizes_to "<x-a b=a{{ b }}c>", [{name: "a", attributes: [{name: "b", value: "a{{ b }}c", type: "string"}]}]
    assert_tokenizes_to "<x-a b=a{b}c>", [{name: "a", attributes: [{name: "b", value: "a{b}c", type: "string"}]}]
    assert_tokenizes_to "<x-a b={{ a }}{{ b }}{{ c }}>", [{name: "a", attributes: [{name: "b", value: "{{ a }}{{ b }}{{ c }}", type: "string"}]}]
    assert_tokenizes_to "<x-a b={{>", [{name: "a", attributes: [{name: "b", value: "{{", type: "string"}]}]

    assert_tokenizes_to '<x-a b="a{{ b }}c">', [{name: "a", attributes: [{name: "b", value: "a{{ b }}c", type: "string"}]}]
    assert_tokenizes_to '<x-a b="a{ b }c">', [{name: "a", attributes: [{name: "b", value: "a{ b }c", type: "string"}]}]
    assert_tokenizes_to '<x-a b="a{{ "b" }}c">', [{name: "a", attributes: [{name: "b", value: "a{{ \"b\" }}c", type: "string"}]}]
    assert_tokenizes_to '<x-a b="a{{ \'b\' }}c">', [{name: "a", attributes: [{name: "b", value: "a{{ 'b' }}c", type: "string"}]}]
    assert_tokenizes_to '<x-a b="{{">', [{name: "a", attributes: [{name: "b", value: "{{", type: "string"}]}]

    assert_tokenizes_to "<x-a b='a{{ b }}c'>", [{name: "a", attributes: [{name: "b", value: "a{{ b }}c", type: "string"}]}]
    assert_tokenizes_to "<x-a b='a{ b }c'>", [{name: "a", attributes: [{name: "b", value: "a{ b }c", type: "string"}]}]
    assert_tokenizes_to "<x-a b='a{{ \"b\" }}c'>", [{name: "a", attributes: [{name: "b", value: "a{{ \"b\" }}c", type: "string"}]}]
    assert_tokenizes_to "<x-a b='a{{ 'b' }}c'>", [{name: "a", attributes: [{name: "b", value: "a{{ 'b' }}c", type: "string"}]}]
    assert_tokenizes_to "<x-a b='{{'>", [{name: "a", attributes: [{name: "b", value: "{{", type: "string"}]}]

    assert_tokenizes_to '<x-a b="}}">', [{name: "a", attributes: [{name: "b", value: "}}", type: "string"}]}]
    assert_tokenizes_to '<x-a b="{{asd">', [{name: "a", attributes: [{name: "b", value: "{{asd", type: "string"}]}]
    assert_tokenizes_to "<x-a b='asd{{'>", [{name: "a", attributes: [{name: "b", value: "asd{{", type: "string"}]}]
    assert_tokenizes_to '<x-a b="{{ {a: "b"} }}c">', [{name: "a", attributes: [{name: "b", value: '{{ {a: "b"} }}c', type: "string"}]}]
  end

  def test_tokenize_string_interpolation_to_ruby
    assert_tokenizes_to "<x-a b={{ c }}>", [{name: "a", attributes: [{name: "b", value: " c ", type: "ruby"}]}]
    assert_tokenizes_to "<x-a b='{{ c }}'>", [{name: "a", attributes: [{name: "b", value: " c ", type: "ruby"}]}]
    assert_tokenizes_to '<x-a b="{{ c }}">', [{name: "a", attributes: [{name: "b", value: " c ", type: "ruby"}]}]
  end

  def test_escaped_string_interpolation
    assert_tokenizes_to "<x-a b=@{{a}}>", [{name: "a", attributes: [{name: "b", value: "@{{a}}", type: "string"}]}]
    assert_tokenizes_to "<x-a b='@{{a}}'>", [{name: "a", attributes: [{name: "b", value: "@{{a}}", type: "string"}]}]
    assert_tokenizes_to "<x-a b=\"@{{a}}\">", [{name: "a", attributes: [{name: "b", value: "@{{a}}", type: "string"}]}]

    assert_tokenizes_to "<x-a b=@{{a c=}}>", [{name: "a", attributes: [{name: "b", value: "@{{a", type: "string"}, {name: "c", value: "}}", type: "string"}]}]
    assert_tokenizes_to "<x-a b='@{{a' c='}}'>", [{name: "a", attributes: [{name: "b", value: "@{{a", type: "string"}, {name: "c", value: "}}", type: "string"}]}]
    assert_tokenizes_to "<x-a b=\"@{{a\" c=\"}}\">", [{name: "a", attributes: [{name: "b", value: "@{{a", type: "string"}, {name: "c", value: "}}", type: "string"}]}]
  end

  def test_class
    multiline_hash = '{
      "block w-full h-full": maximized,
      "inline w-auto": !maximized
    }'
    assert_tokenizes_to '<x-a @class({"block w-full": true})>', [{name: "a", attributes: [{type: "class", value: '{"block w-full": true}'}]}]
    assert_tokenizes_to "<x-a @class(#{multiline_hash})>", [{name: "a", attributes: [{type: "class", value: multiline_hash}]}]
    assert_tokenizes_to '<x-a @class({"block w-full": (true)})>', [{name: "a", attributes: [{type: "class", value: '{"block w-full": (true)}'}]}]
  end

  def test_style
    multiline_hash = '{
      "background-colour: red": showError,
      "font-weight: bold": true
    }'
    assert_tokenizes_to '<x-a @style({"font-size: 20px": true})>', [{name: "a", attributes: [{type: "style", value: '{"font-size: 20px": true}'}]}]
    assert_tokenizes_to "<x-a @style(#{multiline_hash})>", [{name: "a", attributes: [{type: "style", value: multiline_hash}]}]
    assert_tokenizes_to '<x-a @style({"font-size: 20px": (true)})>', [{name: "a", attributes: [{type: "style", value: '{"font-size: 20px": (true)}'}]}]
  end

  def test_attributes
    assert_tokenizes_to "<x-a {{ attributes }}>", [{name: "a", attributes: [{type: "attributes", value: "attributes"}]}]
    assert_tokenizes_to "<x-a {{ attributes.merge({}) }}>", [{name: "a", attributes: [{type: "attributes", value: "attributes.merge({})"}]}]
    assert_tokenizes_to "<x-a {{ attributes.merge({'class': 'block'}) }}>", [{name: "a", attributes: [{type: "attributes", value: "attributes.merge({'class': 'block'})"}]}]

    assert_tokenizes_to "<x-a {{ attributes.merge({
      'class': 'block'
    }) }}>", [{name: "a", attributes: [{type: "attributes", value: "attributes.merge({
      'class': 'block'
    })"}]}]
  end

  def complex_component
    assert_tokenizes_to %[
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
    ], [
      {name: "component", attributes: [
        {name: "attribute", value: "value", type: "string"},
        {name: "special", value: "special value", type: "ruby"},
        {name: "pass_through", type: "pass_through"},
        {type: "class", value: '{cake: "one"}'},
        {type: "style", value: '{cake: "two"}'},
        {name: "cheese", value: "yes", type: "string"},
        {name: "readonly", type: "empty"},
        {name: ":escaped", value: "I only have one colon", type: "string"}
      ]}
    ]
  end

  def test_invalid_syntax
    assert_compiles_to '<x-.related-panels.panel :colour="colours[(i+1) % colours.count]/>', nil, '<x-.related-panels.panel :colour="colours[(i+1) % colours.count]/>'
  end
end
