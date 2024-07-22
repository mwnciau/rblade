require "test_case"

class CompilesLoopsTest < TestCase
  def test_props_hash
    assert_compiles_to "@props({a: 'default'}) {{ a }}",
      "if !defined?(a);a='default';end;_out<<h(a);",
      "default"

    assert_compiles_to "@ruby(a = 'A') @props({a: 'default'}) {{ a }}",
      "a = 'A';if !defined?(a);a='default';end;_out<<h(a);",
      "A"

    assert_compiles_to "@props({a: 'default', b:false,}) {{ a }}",
      "if !defined?(a);a='default';end;if !defined?(b);b=false;end;_out<<h(a);",
      "default"
  end

  def test_required
    exception = assert_raises Exception do
      assert_compiles_to "@props({a: _required}) {{ a }}",
        'if !defined?(a);raise "Props statement: a is not defined";end;_out<<h(a);',
        ""
    end
    assert_equal "Props statement: a is not defined", exception.to_s

    assert_compiles_to "@ruby(a = 'A') @props({a: _required}) {{ a }}",
      'a = \'A\';if !defined?(a);raise "Props statement: a is not defined";end;_out<<h(a);',
      "A"
  end
end
