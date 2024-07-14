require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"
require_relative "../../../../lib/compiler/concerns/tokenizes_components"

class EchoTest < TestCase
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
    assert_tokenizes_to '<x-banana a=""">', ["<x-banana a='>''>"]
    assert_tokenizes_to '<x-banana "a">', ['<x-banana "a">']
    assert_tokenizes_to "<x-banana/ >", ["<x-banana/ >"]
    assert_tokenizes_to "< /x-banana>", ["< /x-banana>"]
    assert_tokenizes_to "<x->", ["<x->"]
    assert_tokenizes_to "<x-<>", ["<x-<>"]
  end

  def test_tokenize_single_attributes
    assert_tokenizes_to "<x-a attribute='X'>", [{name: "a", attributes: [{name: "attribute", type: "string", value: "X"}]}]
    assert_tokenizes_to '<x-a b="c">', [{name: "a", attributes: [{name: "b", type: "string", value: "c"}]}]
    assert_tokenizes_to '<x-a :b="c">', [{name: "a", attributes: [{name: "b", type: "ruby", value: "c"}]}]
    assert_tokenizes_to '<x-a ::b="c">', [{name: "a", attributes: [{name: ":b", type: "string", value: "c"}]}]
    assert_tokenizes_to '<x-a b=c>', [{name: "a", attributes: [{name: "b", type: "string", value: "c"}]}]
    assert_tokenizes_to '<x-a :b>', [{name: "a", attributes: [{name: "b", type: "pass_through"}]}]
    assert_tokenizes_to '<x-a b>', [{name: "a", attributes: [{name: "b", type: "empty"}]}]

    assert_tokenizes_to '<x-a      b="c"    >', [{name: "a", attributes: [{name: "b", type: "string", value: "c"}]}]
    assert_tokenizes_to '<x-a
      b="c"
    >', [{name: "a", attributes: [{name: "b", type: "string", value: "c"}]}]
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
