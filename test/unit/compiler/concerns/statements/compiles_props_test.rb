require "test_case"

class CompilesPropsTest < TestCase
  def assert_compiles_to template, expected_code = nil, expected_result = nil
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

  def test_props_hash
    assert_compiles_to "@props({b: 'default'}) {{ b }}",
      "b=attributes[:'b'].nil? ? 'default' : attributes[:'b'];attributes.delete :'b';_out<<h(b);",
      "default"

    assert_compiles_to "@props({a: 'default'}) {{ a }}",
      "a=attributes[:'a'].nil? ? 'default' : attributes[:'a'];attributes.delete :'a';_out<<h(a);",
      "A"

    assert_compiles_to "@props({a: 'default', b:false,}) {{ a }} {{ b }}", nil, "A false"
  end

  def test_required
    exception = assert_raises Exception do
      assert_compiles_to "@props({b: _required}) {{ b }}",
        "if !attributes.has?(:'b');raise \"Props statement: b is not defined\";end;b=attributes[:'b'].nil? ? _required : attributes[:'b'];attributes.delete :'b';_out<<h(b);",
        ""
    end
    assert_equal "Props statement: b is not defined", exception.to_s

    assert_compiles_to "@props({a: _required}) {{ a }}",
      "if !attributes.has?(:'a');raise \"Props statement: a is not defined\";end;a=attributes[:'a'].nil? ? _required : attributes[:'a'];attributes.delete :'a';_out<<h(a);",
      "A"
  end

  def test_props_removed_from_attributes
    assert_compiles_to "{{ attributes }}", nil, 'a="A"'
    assert_compiles_to "@props({a: 'A'}) {{ attributes }}", nil, ""
    assert_compiles_to "@props({b: 'B'}) {{ attributes }}", nil, 'a="A"'
  end

  def test_props_with_valid_names
    assert_compiles_to "@props({a: nil, a_b: 'A'}) {{ a_b }}", nil, "A"
    assert_compiles_to "@props({a: nil, _a: 'A'}) {{ _a }}", nil, "A"
    assert_compiles_to "@props({a: nil, a1: 'A'}) {{ a1 }}", nil, "A"
    assert_compiles_to "@props({a: nil, :b => 'A'}) {{ b }}", nil, "A"
    assert_compiles_to "@props({a: nil, \"b\": 'A'}) {{ b }}", nil, "A"
    assert_compiles_to "@props({a: nil, 'b': 'A'}) {{ b }}", nil, "A"
  end

  def test_props_with_invalid_names
    assert_compiles_to "@props({a: nil, 'for': 'A'}) {{ attributes }}", nil, 'for="A"'
    assert_compiles_to "@props({a: nil, 'a-b': 'A'}) {{ attributes }}", nil, 'a-b="A"'
    assert_compiles_to "@props({a: nil, '1': 'A'}) {{ attributes }}", nil, '1="A"'
    assert_compiles_to "@props({a: nil, 2: 'A'}) {{ attributes }}", nil, '2="A"'
  end
end
