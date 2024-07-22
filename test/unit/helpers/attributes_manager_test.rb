require "test_case"
require "rblade/compiler"

class BladeTemplatingTest < TestCase
  def test_attributes_to_s
    assert_compiles_to "<x-attributes/>", nil, '<div ></div>'
    assert_compiles_to "<x-attributes a=b/>", nil, '<div a="b"></div>'
    assert_compiles_to "@ruby(name='bob')<x-attributes a=b :c=name/>",
      nil,
      '<div a="b" c="bob"></div>'
  end

  def test_only
    assert_compiles_to "<x-attributes_only/>", nil, '<div ></div>'
    assert_compiles_to "<x-attributes_only a=b/>", nil, '<div a="b"></div>'
    assert_compiles_to "@ruby(name='bob')<x-attributes_only a=b :c=name/>",
      nil,
      '<div a="b"></div>'
  end

  def test_except
    assert_compiles_to "<x-attributes_except/>", nil, '<div ></div>'
    assert_compiles_to "<x-attributes_except a=b/>", nil, '<div ></div>'
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
end
