require "minitest/autorun"
require "minitest/reporters"
require "rblade/rails_template"
require "action_view/helpers"

class TestCase < Minitest::Test
  include ActionView::Helpers

  RBlade::ComponentStore.add_path(File.join(File.dirname(__FILE__), "fixtures"))

  def assert_compiles_to template, expected_code = nil, expected_result = nil, locals = nil
    compiled_string = RBlade::Compiler.compileString(template)

    if expected_code
      assert_equal expected_code, compiled_string
    end

    if expected_result
      locals ||= %(
        extend ActionView::Helpers;
        foo = "FOO";
        bar = "BAR";
        params = {email: "user@example.com"};
        session = {user_id: 4};
        flash = {notice: "Request successful"};
        cookies = {accept_cookies: true};
      )
      result = Class.new.instance_eval(locals + RBlade::RailsTemplate.new.call(nil, template))

      assert_equal expected_result, result
    end
  end
end
