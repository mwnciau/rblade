require "test_case"
require "rblade/compiler"
require "rblade/component_store"

class BladeTemplatingTest < TestCase
  def test_component_compiles_once
    component_method = RBlade::ComponentStore.component "button"
    component_method2 = RBlade::ComponentStore.component "link"
    component_method3 = RBlade::ComponentStore.component "button"

    assert_equal "_c0", component_method
    assert_equal "_c1", component_method2
    assert_equal "_c0", component_method3

    assert RBlade::ComponentStore.get.match("def _c0")
    assert RBlade::ComponentStore.get.match("def _c1")
    assert !RBlade::ComponentStore.get.match("def _c2")
  end

  def test_clear
    RBlade::ComponentStore.component "button"
    assert RBlade::ComponentStore.get.match("def _c0")

    RBlade::ComponentStore.clear
    assert_equal "", RBlade::ComponentStore.get

    RBlade::ComponentStore.component "link"
    assert !RBlade::ComponentStore.get.match("def _c1")
  end

  def test_extensions
    RBlade::ComponentStore.component "component_store_test_extensions"
    assert RBlade::ComponentStore.get.match("index.rblade")
  end
end
