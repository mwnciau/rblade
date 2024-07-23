require "test_case"
require "rblade/compiler"
require "rblade/helpers/class_manager"

class BladeTemplatingTest < TestCase
  def test_string
    manager = RBlade::ClassManager.new ""
    assert_equal "", manager.to_s

    manager = RBlade::ClassManager.new "some classes"
    assert_equal "some classes", manager.to_s

    manager = RBlade::ClassManager.new "some-classes"
    assert_equal "some-classes", manager.to_s

    manager = RBlade::ClassManager.new "some more classes"
    assert_equal "some more classes", manager.to_s
  end

  def test_array
    manager = RBlade::ClassManager.new []
    assert_equal "", manager.to_s

    manager = RBlade::ClassManager.new %w[some classes]
    assert_equal "some classes", manager.to_s

    manager = RBlade::ClassManager.new %w[some-classes]
    assert_equal "some-classes", manager.to_s

    manager = RBlade::ClassManager.new %w[some more classes]
    assert_equal "some more classes", manager.to_s
  end

  def test_hash
    manager = RBlade::ClassManager.new({})
    assert_equal "", manager.to_s

    manager = RBlade::ClassManager.new({"some classes": true})
    assert_equal "some classes", manager.to_s

    manager = RBlade::ClassManager.new({"some-classes": true})
    assert_equal "some-classes", manager.to_s

    manager = RBlade::ClassManager.new({"some classes": false})
    assert_equal "", manager.to_s

    manager = RBlade::ClassManager.new({some: true, classes: false})
    assert_equal "some", manager.to_s

    manager = RBlade::ClassManager.new({some: true, classes: true})
    assert_equal "some classes", manager.to_s
  end

  def test_component_class
    assert_compiles_to "<x-attributes_merge @class({})/>",
      nil,
      '<div class="font-bold " style="font-size: 10px" a="cake"></div>'

    assert_compiles_to "<x-attributes_merge @class({'some': true, 'class': false})/>",
      nil,
      '<div class="font-bold some" style="font-size: 10px" a="cake"></div>'
  end
end
