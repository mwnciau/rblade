require "test_case"
require "rblade/rails_template"

class RailsTemplateTest < TestCase
  def test_single_line
    source = "Hello, {{ world }}!"

    # Create a mock backtrace location
    backtrace_location = Class.new do
      def self.path = "app/views/test/index.rblade"
    end

    # Create a spot hash that would typically come from an error
    spot = {
      first_lineno: 5, # Adjusted for preamble and component store
      first_column: 40,
      script_lines: ["# frozen_string_literal: true\n"],
    }

    result = RBlade::RailsTemplate.new.translate_location(spot, backtrace_location, source)

    assert_equal(
      {
        first_lineno: 1,
        first_column: 7,
        last_lineno: 1,
        last_column: 18,
        snippet: "{{ world }}",
        script_lines: source.lines,
      },
      result,
    )
  end

  def test_multiline
    source = <<~TEMPLATE
      <div>
        <p>Hello, {{ world }}!</p>
      </div>
    TEMPLATE

    # Create a mock backtrace location
    backtrace_location = Class.new do
      def self.path = "app/views/test/index.rblade"
    end

    # Create a spot hash that would typically come from an error
    spot = {
      first_lineno: 6, # Adjusted for preamble and component store
      first_column: 14,
      script_lines: ["# frozen_string_literal: true\n"],
    }

    result = RBlade::RailsTemplate.new.translate_location(spot, backtrace_location, source)

    assert_equal(
      {
        first_lineno: 2,
        first_column: 12,
        last_lineno: 2,
        last_column: 23,
        snippet: "{{ world }}",
        script_lines: source.lines,
      },
      result,
    )
  end

  def test_without_frozen_string_literal
    source = <<~TEMPLATE
      <div>
        <p>Hello, {{ world }}!</p>
      </div>
    TEMPLATE

    # Create a mock backtrace location
    backtrace_location = Class.new do
      def self.path = "app/views/test/index.rblade"
    end

    # Create a spot hash that would typically come from an error
    spot = {
      first_lineno: 5,
      first_column: 14,
      script_lines: [""],
    }

    result = RBlade::RailsTemplate.new.translate_location(spot, backtrace_location, source)

    assert_equal(
      {
        first_lineno: 2,
        first_column: 12,
        last_lineno: 2,
        last_column: 23,
        snippet: "{{ world }}",
        script_lines: source.lines,
      },
      result,
    )
  end
end
