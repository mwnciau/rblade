require "minitest/autorun"
require "minitest/reporters"
require "rblade/rails_template"
require "action_view/helpers"

class TestCase < Minitest::Test
  include ActionView::Helpers

  RBlade::ComponentStore.add_path(File.join(File.dirname(__FILE__), "fixtures"))

  def assert_compiles_to template, expected_code = nil, expected_result = nil, locals = nil
    component_store = RBlade::ComponentStore.new
    compiled_string = RBlade::Compiler.compileString(template, component_store)

    if expected_code
      assert_equal expected_code, compiled_string
    end

    if expected_result
      mod = Module.new do
        extend ActionView::Helpers

        def self.params
          {email: "user@example.com"}
        end
      end

      locals ||= 'foo = "FOO";bar = "BAR";'

      result = mod.module_eval(locals + RBlade::RailsTemplate.new.call(nil, template))

      assert_equal expected_result, result
    end
  end
end
