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
      "b=attributes.default(:'b','default');_out<<h(b);",
      "default"

    assert_compiles_to "@props({a: 'default'}) {{ a }}",
      "a=attributes.default(:'a','default');_out<<h(a);",
      "A"

    assert_compiles_to "@props({a: 'default', b:false,}) {{ a }} {{ b }}",
      "a=attributes.default(:'a','default');b=attributes.default(:'b',false);_out<<h(a);_out<<' ';_out<<h(b);",
      "A false"
  end

  def test_required
    exception = assert_raises Exception do
      assert_compiles_to "@props({b: _required}) {{ b }}",
        "if !defined?(b)&&!attributes.has?(:'b');raise \"Props statement: b is not defined\";end;b=attributes.default(:'b');_out<<h(b);",
        ""
    end
    assert_equal "Props statement: b is not defined", exception.to_s

    assert_compiles_to "@props({a: _required}) {{ a }}",
      "if !defined?(a)&&!attributes.has?(:'a');raise \"Props statement: a is not defined\";end;a=attributes.default(:'a');_out<<h(a);",
      "A"
  end
end
