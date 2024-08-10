require "test_case"
require "rblade/compiler"
require "rblade/helpers/class_manager"

class ClassManagerTest < TestCase
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
end
