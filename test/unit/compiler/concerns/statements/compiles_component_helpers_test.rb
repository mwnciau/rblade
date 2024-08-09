require "test_case"

class CompilesComponentHelpersTest < TestCase
  def assert_props_compiles_to template, expected_code = nil, expected_result = nil
    compiled_string = RBlade::Compiler.compileString(template)

    if expected_code
      assert_equal expected_code, compiled_string
    end

    if expected_result
      attributes = RBlade::AttributesManager.new({a: "A"}) # standard:disable Lint/UselessAssignment
      result = eval RBlade::RailsTemplate.new.call(nil, template) # standard:disable Security/Eval

      assert_equal expected_result, result
    end
  end

  def test_should_render
    assert_compiles_to "@shouldRender(true) rendered", "unless(true);return'';end;_out<<'rendered';", "rendered"
    assert_compiles_to "@shouldRender(false) rendered", "unless(false);return'';end;_out<<'rendered';", ""

    assert_compiles_to "rendered @shouldRender(true)", "_out<<'rendered';unless(true);return'';end;", "rendered"
    assert_compiles_to "rendered @shouldRender(false)", "_out<<'rendered';unless(false);return'';end;", ""
  end

  def test_should_render_component
    assert_compiles_to "<x-compiles_component_helpers.should_render/>", nil, "ab"
    assert_compiles_to "<x-compiles_component_helpers.should_not_render/>", nil, nil
  end

  def test_props_hash
    assert_props_compiles_to "@props({b: 'default'}) {{ b }}",
      "attributes.default(:'b', 'default');b=attributes.delete :'b';_out<<RBlade.e(b);",
      "default"

    assert_props_compiles_to "@props({a: 'default'}) {{ a }}",
      "attributes.default(:'a', 'default');a=attributes.delete :'a';_out<<RBlade.e(a);",
      "A"

    assert_props_compiles_to "@props({a: 'default', b:false,}) {{ a }} {{ b }}", nil, "A false"
  end

  def test_required
    exception = assert_raises Exception do
      assert_props_compiles_to "@props({b: required}) {{ b }}",
        "if !attributes.has?(:'b');raise \"Props statement: b is not defined\";end;b=attributes.delete :'b';_out<<RBlade.e(b);",
        ""
    end
    assert_equal "Props statement: b is not defined", exception.to_s

    assert_props_compiles_to "@props({a: required}) {{ a }}",
      "if !attributes.has?(:'a');raise \"Props statement: a is not defined\";end;a=attributes.delete :'a';_out<<RBlade.e(a);",
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

    assert_compiles_to "<x-#{component} nilSlot='123'/>", nil, '  123 '
  end
end
