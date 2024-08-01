require "minitest/autorun"
require "minitest/reporters"
require "rblade/rails_template"

class TestCase < Minitest::Test
  RBlade::ComponentStore.add_path(File.join(File.dirname(__FILE__), "fixtures"))

  def assert_compiles_to template, expected_code = nil, expected_result = nil
    compiled_string = RBlade::Compiler.compileString(template)

    if expected_code
      assert_equal expected_code, compiled_string
    end

    if expected_result
      foo = "FOO" # standard:disable Lint/UselessAssignment
      bar = "BAR" # standard:disable Lint/UselessAssignment
      params = {email: "user@example.com"} # standard:disable Lint/UselessAssignment
      session = {user_id: 4} # standard:disable Lint/UselessAssignment
      flash = {notice: "Request successful"} # standard:disable Lint/UselessAssignment
      cookies = {accept_cookies: true} # standard:disable Lint/UselessAssignment
      result = eval RBlade::RailsTemplate.new.call(nil, template) # standard:disable Security/Eval

      assert_equal expected_result, result
    end
  end
end
