require "test_case"

class CompilesComponentHelpersTest < TestCase
  def assert_props_compiles_to template, expected_code = nil, expected_result = nil
    locals = %[
      attributes = RBlade::AttributesManager.new({a: "A"})
    ]

    assert_compiles_to template, expected_code, expected_result, locals
  end

  def test_should_render
    assert_compiles_to "@shouldRender(true) rendered", "unless(true);return'';end;@output_buffer.raw_buffer<<-'rendered';", "rendered"
    assert_compiles_to "@shouldRender(false) rendered", "unless(false);return'';end;@output_buffer.raw_buffer<<-'rendered';", ""

    assert_compiles_to "rendered @shouldRender(true)", "@output_buffer.raw_buffer<<-'rendered';unless(true);return'';end;", "rendered"
    assert_compiles_to "rendered @shouldRender(false)", "@output_buffer.raw_buffer<<-'rendered';unless(false);return'';end;", ""
  end

  def test_should_render_component
    assert_compiles_to "<x-compiles_component_helpers.should_render/>", nil, "ab"
    assert_compiles_to "<x-compiles_component_helpers.should_not_render/>", nil, nil
  end

  def test_props_hash
    assert_props_compiles_to "@props({b: 'default'}) {{ b }}",
      "attributes.default(:'b', 'default');b=attributes.delete :'b';@output_buffer.append=b;",
      "default"

    assert_props_compiles_to "@props({a: 'default'}) {{ a }}",
      "attributes.default(:'a', 'default');a=attributes.delete :'a';@output_buffer.append=a;",
      "A"

    assert_props_compiles_to "@props({a: 'default', b:false,}) {{ a }} {{ b }}", nil, "A false"

    assert_props_compiles_to "@props({b: ',\\''})",
      "attributes.default(:'b', ',\\'');b=attributes.delete :'b';"
    assert_props_compiles_to "@props({b: {c: 1, d: 2}})",
      "attributes.default(:'b', {c: 1, d: 2});b=attributes.delete :'b';"
  end

  def test_props_without_hash
    assert_props_compiles_to "@props(b: 'default') {{ b }}",
      "attributes.default(:'b', 'default');b=attributes.delete :'b';@output_buffer.append=b;",
      "default"

    assert_props_compiles_to "@props(a: 'default') {{ a }}",
      "attributes.default(:'a', 'default');a=attributes.delete :'a';@output_buffer.append=a;",
      "A"

    assert_props_compiles_to "@props(a: 'default', b:false) {{ a }} {{ b }}", nil, "A false"

    assert_props_compiles_to "@props(b: ',\\'')",
      "attributes.default(:'b', ',\\'');b=attributes.delete :'b';"
    assert_props_compiles_to "@props(b: {c: 1, d: 2} )",
      "attributes.default(:'b', {c: 1, d: 2});b=attributes.delete :'b';"
  end

  def test_required
    exception = assert_raises Exception do
      assert_props_compiles_to "@props({b: required}) {{ b }}",
        "if !attributes.has?(:'b');raise \"Props statement: b is not defined\";end;b=attributes.delete :'b';@output_buffer.append=b;",
        ""
    end
    assert_equal "Props statement: b is not defined", exception.to_s

    assert_props_compiles_to "@props({a: required}) {{ a }}",
      "if !attributes.has?(:'a');raise \"Props statement: a is not defined\";end;a=attributes.delete :'a';@output_buffer.append=a;",
      "A"
  end

  def test_props_removed_from_attributes
    assert_props_compiles_to "{{ attributes }}", nil, 'a="A"'
    assert_props_compiles_to "@props({a: 'A'}) {{ attributes }}", nil, ""
    assert_props_compiles_to "@props({b: 'B'}) {{ attributes }}", nil, 'a="A"'
  end

  def test_props_with_valid_names
    assert_props_compiles_to "@props({a: nil, a_b: 'A'}) {{ a_b }}", nil, "A"
    assert_props_compiles_to "@props({a: nil, _a: 'A'}) {{ _a }}", nil, "A"
    assert_props_compiles_to "@props({a: nil, a1: 'A'}) {{ a1 }}", nil, "A"
    assert_props_compiles_to "@props({a: nil, :b => 'A'}) {{ b }}", nil, "A"
    assert_props_compiles_to "@props({a: nil, \"b\": 'A'}) {{ b }}", nil, "A"
    assert_props_compiles_to "@props({a: nil, 'b': 'A'}) {{ b }}", nil, "A"
  end

  def test_props_with_invalid_names
    assert_props_compiles_to "@props({a: nil, 'for': 'A'}) {{ attributes }}", nil, 'for="A"'
    assert_props_compiles_to "@props({a: nil, 'a-b': 'A'}) {{ attributes }}", nil, 'a-b="A"'
    assert_props_compiles_to "@props({a: nil, '1': 'A'}) {{ attributes }}", nil, '1="A"'
    assert_props_compiles_to "@props({a: nil, 2: 'A'}) {{ attributes }}", nil, '2="A"'
  end

  def test_should_auto_detect_slots
    component = "compiles_component_helpers.should_auto_detect_slots"
    assert_compiles_to "<x-#{component}/>", nil, "abc "
    assert_compiles_to "<x-#{component}><x-slot::mySlot>def<//><//>", nil, "def "
    assert_compiles_to "<x-#{component}><x-slot::mySlot a=b/><//>", nil, ' a="b"'
    assert_compiles_to "<x-#{component}><x-slot::mySlot a=b>ghi<//><//>", nil, 'ghi a="b"'
  end

  def test_should_allow_non_string_defaults
    component = "compiles_component_helpers.should_allow_non_string_defaults"
    assert_compiles_to "<x-#{component}/>", nil, ""
    assert_compiles_to "<x-#{component}><x-slot::falseSlot a=b>c<//><//>", nil, '  c a="b"'
    assert_compiles_to "<x-#{component}><x-slot::nilSlot a=b>c<//><//>", nil, '  c a="b"'

    assert_compiles_to "<x-#{component} nilSlot='123'/>", nil, "  123 "
  end

  def test_partials_props_uses_content_for
    # When enabled, components rendered normally should still work
    assert_partial_compiles_to "@props(cake: 'choccy'){{ cake }}", "choccy"
    assert_partial_compiles_to "@props(cake: required){{ cake }}", exception: "Props statement: cake is not defined"

    # content_for content should override defaults and not cause errors when props are required
    assert_partial_compiles_to "<% content_for :cake, 'choccy' %>@props(cake: 'not choccy'){{ cake }}", "choccy"
    assert_partial_compiles_to "<% content_for :cake, 'choccy' %>@props(cake: required){{ cake }}", "choccy"

    # Directly assigned locals should override content_for content
    assert_partial_compiles_to "<% content_for :cake, 'not choccy' %>@props(cake: required){{ cake }}", "choccy", locals: {cake: 'choccy'}
  end
end
