require "test_case"
require "rblade/compiler"
require "rblade/component_store"

class ComponentStoreTest < TestCase
  def setup
    super

    @component_store = RBlade::ComponentStore.new
  end

  def test_component_compiles_once
    component_method = @component_store.component "button"
    component_method2 = @component_store.component "link"
    component_method3 = @component_store.component "button"

    assert_equal "_rblade_component_button", component_method
    assert_equal "_rblade_component_link", component_method2
    assert_equal "_rblade_component_button", component_method3

    compiled_code = @component_store.get

    #    assert_equal "", compiled_code
    assert_equal 1, compiled_code.scan("def self._rblade_component_button(").count
    assert_equal 1, compiled_code.scan("def self._rblade_component_link(").count
  end

  def test_extensions_index
    @component_store.component "component_store_test_extensions"
    assert @component_store.get.match("index.rblade")
  end

  def test_extensions_html
    @component_store.component "component_store_test_extensions.html"
    assert @component_store.get.match("html.html.rblade")
  end

  def test_extensions_rblade
    @component_store.component "component_store_test_extensions.rblade"
    assert @component_store.get.match("rblade.rblade")
  end

  def test_extensions_clashing
    @component_store.component "component_store_test_extensions.clashing"
    assert @component_store.get.match("clashing.rblade")
  end

  def test_relative_names
    assert_compiles_to "<x-component_store_test_relative_names.component/>",
      nil,
      "success!"

    assert_compiles_to "<x-relative_button/>",
      nil,
      '<button class="button">relative</button>'
  end

  def test_relative_names_compiles_once
    @component_store.component "component_store_test_relative_names"
    @component_store.component "component_store_test_relative_names.component"
    @component_store.component "component_store_test_relative_names.success"

    compiled_code = @component_store.get

    assert_equal 1, compiled_code.scan("def self._rblade_component_component_store_test_relative_names(").size
    assert_equal 1, compiled_code.scan("def self._rblade_component_component_store_test_relative_names__success(").size
    assert_equal 1, compiled_code.scan("def self._rblade_component_component_store_test_relative_names__component(").size
  end
end
