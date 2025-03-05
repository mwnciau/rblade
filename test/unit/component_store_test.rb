require "test_case"
require "rblade/compiler"
require "rblade/component_store"

class ComponentStoreTest < TestCase
  def setup
    super

    RBlade::ComponentStore.clear
  end

  def test_component_compiles_once
    component_method = RBlade::ComponentStore.component "button"
    component_method2 = RBlade::ComponentStore.component "link"
    component_method3 = RBlade::ComponentStore.component "button"

    assert_equal "_rblade_components.c_button", component_method
    assert_equal "_rblade_components.c_link", component_method2
    assert_equal "_rblade_components.c_button", component_method3

    compiled_code = RBlade::ComponentStore.get

    assert_equal 1, compiled_code.scan("def c_button(").count
    assert_equal 1, compiled_code.scan("def c_link(").count
  end

  def test_clear
    RBlade::ComponentStore.component "button"
    assert RBlade::ComponentStore.get.match("def c_button")

    RBlade::ComponentStore.clear
    assert_equal "", RBlade::ComponentStore.get

    RBlade::ComponentStore.component "link"
    assert !RBlade::ComponentStore.get.match("def c_button")
  end

  def test_extensions_index
    RBlade::ComponentStore.component "component_store_test_extensions"
    assert RBlade::ComponentStore.get.match("index.rblade")
  end

  def test_extensions_html
    RBlade::ComponentStore.component "component_store_test_extensions.html"
    assert RBlade::ComponentStore.get.match("html.html.rblade")
  end

  def test_extensions_rblade
    RBlade::ComponentStore.component "component_store_test_extensions.rblade"
    assert RBlade::ComponentStore.get.match("rblade.rblade")
  end

  def test_extensions_clashing
    RBlade::ComponentStore.component "component_store_test_extensions.clashing"
    assert RBlade::ComponentStore.get.match("clashing.rblade")
  end

  def test_relative_names
    assert_compiles_to "<x-component_store_test_relative_names.component/>",
      nil,
      "success!"
  end

  def test_relative_names_compiles_once
    RBlade::ComponentStore.component "component_store_test_relative_names"
    RBlade::ComponentStore.component "component_store_test_relative_names.component"
    RBlade::ComponentStore.component "component_store_test_relative_names.success"

    compiled_code = RBlade::ComponentStore.get

    assert_equal 1, compiled_code.scan("def c_component_store_test_relative_names(").size
    assert_equal 1, compiled_code.scan("def c_component_store_test_relative_names__success(").size
    assert_equal 1, compiled_code.scan("def c_component_store_test_relative_names__component(").size
  end
end
