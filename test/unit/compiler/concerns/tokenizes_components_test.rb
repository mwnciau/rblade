require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"
require_relative "../../../../lib/compiler/concerns/tokenizes_components"

class TokenizesComponentsTest < TestCase
  def assert_tokenizes_to template, expected
    tokens = [Token.new(:unprocessed, template)]
    TokenizesComponents.tokenize!(tokens)

    expected.each.with_index do |expected_item, i|
      if expected_item.is_a?(Hash) && !expected_item[:token_type].nil?
        assert_equal expected_item[:token_type], tokens[i].type
        expected_item.delete :token_type
      end

      assert_equal expected_item, tokens[i].value
    end
  end

  def test_tokenize_tags
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

    assert_tokenizes_to "<x-banana/>", [{name: "banana", attributes: [], token_type: :component}]
    assert_tokenizes_to "<x:banana/>", [{name: "banana", attributes: [], token_type: :component}]
    assert_tokenizes_to "<   x-banana   />", [{name: "banana", attributes: [], token_type: :component}]

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

  def test_echos_in_attribute
    # todo
    assert_tokenizes_to '<x-a b="out{{\'value\'}}">', [{name: "a", attributes: [{name: "b", value: "_out<<'out';_out<<h('value');", type: "compiled"}]}]
  end

  def test_tokenize_single_attributes
    assert_tokenizes_to "<x-a attribute='value'>", [{name: "a", attributes: [{name: "attribute", value: "_out<<'value';", type: "compiled"}]}]
    assert_tokenizes_to '<x-a b="c">', [{name: "a", attributes: [{name: "b", value: "_out<<'c';", type: "compiled"}]}]
    assert_tokenizes_to '<x-a :b="c">', [{name: "a", attributes: [{name: "b", value: "c", type: "ruby"}]}]
    assert_tokenizes_to '<x-a ::b="c">', [{name: "a", attributes: [{name: ":b", value: "_out<<'c';", type: "compiled"}]}]
    assert_tokenizes_to '<x-a b=c>', [{name: "a", attributes: [{name: "b", value: "_out<<'c';", type: "compiled"}]}]
    assert_tokenizes_to '<x-a :b>', [{name: "a", attributes: [{name: "b", type: "pass_through"}]}]
    assert_tokenizes_to '<x-a b>', [{name: "a", attributes: [{name: "b", type: "empty"}]}]

    assert_tokenizes_to '<x-a      b="c"    >', [{name: "a", attributes: [{name: "b", value: "_out<<'c';", type: "compiled"}]}]
    assert_tokenizes_to '<x-a
      b="c"
    >', [{name: "a", attributes: [{name: "b", value: "_out<<'c';", type: "compiled"}]}]
  end

  def scenario
    #assert_tokenizes_to '<x-component {{ attributes(blah) }}>', []
    #assert_tokenizes_to '<x-component @class({cake: "one"})>', []
    #assert_tokenizes_to '<x-component @style({cake: "two"})>', []
    #assert_tokenizes_to '<x-component cheese=yes readonly>', []
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
    ], []
  end
end
