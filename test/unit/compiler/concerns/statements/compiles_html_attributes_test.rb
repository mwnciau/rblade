require "test_case"

class CompilesHtmlAttributesTest < TestCase
  def test_class
    multiline_hash = '{
      "block w-full h-full": foo != "FOO",
      "inline w-auto": foo == "FOO",
      "absolute": true
    }'
    assert_compiles_to '@class({"block w-full": true})', nil, 'class="block w-full"'
    assert_compiles_to "@class(#{multiline_hash})", nil, 'class="inline w-auto absolute"'
    assert_compiles_to '@class({"block w-full": (true)})', nil, 'class="block w-full"'
    assert_compiles_to '@class("block w-full": true)', nil, 'class="block w-full"'
  end

  def test_style
    multiline_hash = '{
      "background-colour: red": bar == "BAR",
      "font-weight: bold": true,
      "position: absolute": false
    }'
    assert_compiles_to '@style({"font-size: 20px": true})', nil, 'style="font-size: 20px;"'
    assert_compiles_to "@style(#{multiline_hash})", nil, 'style="background-colour: red;font-weight: bold;"'
    assert_compiles_to '@style({"color: blue": (true)})', nil, 'style="color: blue;"'
    assert_compiles_to '@style("color: blue": (true))', nil, 'style="color: blue;"'
  end
end
