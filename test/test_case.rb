require "minitest/autorun"
require "minitest/reporters"
require "rblade/rails_template"

class TestCase < Minitest::Test
  def setup
    super

    RBlade::ComponentStore.add_path(File.join(File.dirname(__FILE__), "fixtures"))
  end

  def assert_compiles_to template, expected_code = nil, expected_result = nil
    compiled_string = RBlade::Compiler.compileString(template)

    if expected_code
      assert_equal expected_code, compiled_string
    end

    if expected_result
      #foo = "FOO" # standard:disable Lint/UselessAssignment
      #bar = "BAR" # standard:disable Lint/UselessAssignment
      result = eval RBlade::RailsTemplate.new.call(nil, template) # standard:disable Security/Eval

      assert_equal expected_result, result
    end
  end
end
