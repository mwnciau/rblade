require "test_case"
require "rblade/compiler"
require "rblade/helpers/style_manager"

class StyleManagerTest < TestCase
  def test_string
    manager = RBlade::StyleManager.new ""
    assert_equal "", manager.to_s

    manager = RBlade::StyleManager.new "font-size: 20px;"
    assert_equal "font-size: 20px;", manager.to_s

    manager = RBlade::StyleManager.new "font-size: 20px; font-weight: bold"
    assert_equal "font-size: 20px; font-weight: bold;", manager.to_s
  end

  def test_array
    manager = RBlade::StyleManager.new []
    assert_equal "", manager.to_s

    manager = RBlade::StyleManager.new ["font-size: 20px"]
    assert_equal "font-size: 20px;", manager.to_s

    manager = RBlade::StyleManager.new ["font-size: 20px", "font-weight: bold"]
    assert_equal "font-size: 20px;font-weight: bold;", manager.to_s

    manager = RBlade::StyleManager.new ["font-size: 20px;", "font-weight: bold;"]
    assert_equal "font-size: 20px;font-weight: bold;", manager.to_s
  end

  def test_hash
    manager = RBlade::StyleManager.new({})
    assert_equal "", manager.to_s

    manager = RBlade::StyleManager.new({"font-size: 20px": true})
    assert_equal "font-size: 20px;", manager.to_s

    manager = RBlade::StyleManager.new({"font-size: 20px;": true})
    assert_equal "font-size: 20px;", manager.to_s

    manager = RBlade::StyleManager.new({"font-size: 20px;": false})
    assert_equal "", manager.to_s

    manager = RBlade::StyleManager.new({"font-size: 20px": true, "font-weight: bold;": false})
    assert_equal "font-size: 20px;", manager.to_s

    manager = RBlade::StyleManager.new({"font-size: 20px": true, "font-weight: bold;": true})
    assert_equal "font-size: 20px;font-weight: bold;", manager.to_s
  end
end
