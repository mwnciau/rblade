require "test_case"
require "rblade/compiler"
require "rblade/helpers/attributes_manager"

class BladeTemplatingTest < TestCase
  def test_attributes_to_s
    assert_compiles_to "<x-attributes/>", nil, "<div ></div>"
    assert_compiles_to "<x-attributes a=b/>", nil, '<div a="b"></div>'
    assert_compiles_to "@ruby(name='bob')<x-attributes a=b :c=name/>",
      nil,
      '<div a="b" c="bob"></div>'
  end

  def test_only
    assert_compiles_to "<x-attributes_only/>", nil, "<div ></div>"
    assert_compiles_to "<x-attributes_only a=b/>", nil, '<div a="b"></div>'
    assert_compiles_to "@ruby(name='bob')<x-attributes_only a=b :c=name/>",
      nil,
      '<div a="b"></div>'
  end

  def test_except
    assert_compiles_to "<x-attributes_except/>", nil, "<div ></div>"
    assert_compiles_to "<x-attributes_except a=b/>", nil, "<div ></div>"
    assert_compiles_to "@ruby(name='bob')<x-attributes_except a=b :c=name/>",
      nil,
      '<div c="bob"></div>'
  end

  def test_merge
    assert_compiles_to "<x-attributes_merge/>",
      nil,
      '<div class="font-bold" style="font-size: 10px" a="cake"></div>'

    assert_compiles_to "<x-attributes_merge a=b/>",
      nil,
      '<div class="font-bold" style="font-size: 10px" a="b"></div>'

    assert_compiles_to "<x-attributes_merge c=d/>",
      nil,
      '<div class="font-bold" style="font-size: 10px" a="cake" c="d"></div>'

    assert_compiles_to "<x-attributes_merge class='text-lg'/>",
      nil,
      '<div class="font-bold text-lg" style="font-size: 10px" a="cake"></div>'

    assert_compiles_to "<x-attributes_merge style='font-weight: bold'/>",
      nil,
      '<div class="font-bold" style="font-size: 10px;font-weight: bold" a="cake"></div>'
  end

  def test_chain
    assert_compiles_to "<x-attributes_chain a=A c=C/>", nil, '<div a="A" c="d"></div>'
  end

  def test_class
    assert_compiles_to "<x-attributes @class({'abc': false})/>",
      nil,
      '<div class=""></div>'

    assert_compiles_to "<x-attributes @class({'abc': true})/>",
      nil,
      '<div class="abc"></div>'

    assert_compiles_to "<x-attributes_merge @class({})/>",
      nil,
      '<div class="font-bold " style="font-size: 10px" a="cake"></div>'

    assert_compiles_to "<x-attributes_merge @class({'some': true, 'class': false})/>",
      nil,
      '<div class="font-bold some" style="font-size: 10px" a="cake"></div>'

    assert_compiles_to "<x-attributes_empty_merge @class({})/>",
      nil,
      '<div class=""></div>'

    assert_compiles_to "<x-attributes_empty_merge @class({'some': true, 'class': false})/>",
      nil,
      '<div class="some"></div>'
  end

  def test_class_method
    assert_equal 'class="block mt-2"', RBlade::AttributesManager.new({}).class("block mt-2").to_s
    assert_equal 'class="block mt-2"', RBlade::AttributesManager.new({}).class(["block", "mt-2"]).to_s
    assert_equal 'class="block mt-2"', RBlade::AttributesManager.new({}).class({"block": true, "mt-2": true, "mb-6": false}).to_s

    assert_equal 'class="relative block mt-2"', RBlade::AttributesManager.new({class: "relative"}).class("block mt-2").to_s
    assert_equal 'class="relative block mt-2"', RBlade::AttributesManager.new({class: "relative"}).class(["block", "mt-2"]).to_s
    assert_equal 'class="relative block mt-2"', RBlade::AttributesManager.new({class: "relative"}).class({"block": true, "mt-2": true, "mb-6": false}).to_s
  end

  def test_style
    assert_compiles_to "<x-attributes @style({'abc': false})/>",
      nil,
      '<div style=""></div>'

    assert_compiles_to "<x-attributes @style({'abc': true})/>",
      nil,
      '<div style="abc;"></div>'

    assert_compiles_to "<x-attributes_merge @style({})/>",
      nil,
      '<div class="font-bold" style="font-size: 10px;" a="cake"></div>'

    assert_compiles_to "<x-attributes_merge @style({'color: red': true, 'font-weight: bold;': false})/>",
      nil,
      '<div class="font-bold" style="font-size: 10px;color: red;" a="cake"></div>'

    assert_compiles_to "<x-attributes_empty_merge @style({})/>",
      nil,
      '<div style=""></div>'

    assert_compiles_to "<x-attributes_empty_merge @style({'some': true, 'style': false})/>",
      nil,
      '<div style="some;"></div>'
  end

  def test_missing_method
    attributes = RBlade::AttributesManager.new({a: "1", b: "2"})

    assert_equal "1", attributes[:a]
    attributes[:c] = "3"
    attributes.delete :b

    assert_equal "13", attributes.compact.map(&:last).join
  end
end
