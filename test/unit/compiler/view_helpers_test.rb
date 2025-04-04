require "test_case"
require "rblade/compiler"

class ViewHelpersTest < TestCase
  def test_component_helper
    assert_compiles_to "<%= component 'button' %>", nil, "<button class=\"button\"></button>"
    assert_compiles_to "<%= component 'button' do \"cake\" end %>", nil, "<button class=\"button\">cake</button>"
    assert_compiles_to "<%= component 'button' do %>cake<% end %>", nil, "<button class=\"button\">cake</button>"
    assert_compiles_to "<%= component 'button', slot: 'cake' %>", nil, "<button class=\"button\">cake</button>"
    assert_compiles_to "<%= component 'button', type: 'submit' %>", nil, "<button class=\"button\" type=\"submit\"></button>"

    assert_compiles_to "<%= component 'nested_button' do '1234' end %>", nil, "<button class=\"button block\" type=\"button\">1234</button>"
    assert_compiles_to "<%= component 'relative_button' %>", nil, "<button class=\"button\">relative</button>"
  end

  def test_component_helper_with_direct_component_rendering
    assert_partial_compiles_to "<%= component 'button' %>", "<button class=\"button\"></button>"
    assert_partial_compiles_to "<%= component 'button' do \"cake\" end %>", "<button class=\"button\">cake</button>"
    assert_partial_compiles_to "<%= component 'button' do %>cake<% end %>", "<button class=\"button\">cake</button>"
    assert_partial_compiles_to "<%= component 'button', type: 'submit' %>", "<button class=\"button\" type=\"submit\"></button>"

    assert_partial_compiles_to "<%= component 'nested_button' do '1234' end %>", "<button class=\"button block\" type=\"button\">1234</button>"
    assert_partial_compiles_to "<%= component 'relative_button' %>", "<button class=\"button\">relative</button>"
  end

  def test_rename_component_helper
    RBlade.component_helper_method_name = :rblade_component

    assert_compiles_to "<%= rblade_component 'button' %>", nil, "<button class=\"button\"></button>"
    assert_partial_compiles_to "<%= rblade_component 'button' %>", "<button class=\"button\"></button>"
    assert_partial_compiles_to "<x-dynamic component=button/>", "<button class=\"button\"></button>"
  ensure
    RBlade.component_helper_method_name = :component
  end

  def test_component_helper_slots
    assert_compiles_to "<x-dynamic component='compiles_components_test.slot'><x-slot::title>TITLE<//>SLOT<//>", nil, "TITLE - SLOT"
    assert_compiles_to "<x-dynamic component='compiles_components_test.slot'><x-slot::title><b>TITLE</b><//>SLOT<//>", nil, "<b>TITLE</b> - SLOT"

    assert_compiles_to %(<%= component "compiles_components_test.slot" do |slot| %><% slot.call :title do %>TITLE<% end %>SLOT<% end %>), nil, "TITLE - SLOT"
    assert_compiles_to %(<%= component "compiles_components_test.slot" do |slot| %><% slot.call :title do %><b>TITLE</b><% end %>SLOT<% end %>), nil, "<b>TITLE</b> - SLOT"
  end
end
