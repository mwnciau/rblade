require "minitest/autorun"
require "minitest/reporters"
require "rblade/railtie"
require "action_view/buffers"
require "action_view/flows"
require "action_view/helpers"
require "ostruct"

class TestCase < Minitest::Test
  RBlade::ComponentStore.add_path(File.join(File.dirname(__FILE__), "fixtures"))
  RBlade::ComponentStore.add_path(File.join(File.dirname(__FILE__), "fixtures"), "view")

  def assert_compiles_to(template, expected_code = nil, expected_result = nil, locals = nil)
    component_store = RBlade::ComponentStore.new
    compiled_string = RBlade::Compiler.compile_string(template, component_store)

    if expected_code.is_a?(Regexp)
      assert compiled_string.match? expected_code
    elsif expected_code.is_a?(String)
      assert_equal expected_code, compiled_string
    end

    if expected_result
      locals ||= 'foo = "FOO";bar = "BAR";'

      result = module_context.module_eval(locals + RBlade::RailsTemplate.new.call(nil, template)).to_str

      assert_equal expected_result, result
    end
  end

  def assert_partial_compiles_to(template, expected_result = nil, **args, &)
    component_store = RBlade::ComponentStore.new
    RBlade.direct_component_rendering = true
    compiled_string = RBlade::Compiler.compile_string(template, component_store)

    if args[:compiles_to].is_a?(Regexp)
      assert compiled_string.match? args[:compiles_to]
    elsif args[:compiles_to].is_a?(String)
      assert_equal args[:compiles_to], compiled_string
    end

    if args[:exception] || expected_result
      mod = module_context

      mod.module_eval("def self._compiled_component(local_assigns);#{RBlade::RailsTemplate.new.call(nil, template)}end", __FILE__, __LINE__)

      if args[:exception]
        exception = assert_raises Exception do
          mod.method(:_compiled_component).call(args[:locals] || {}, &)
        end

        if args[:exception].is_a? String
          assert_equal args[:exception], exception.to_s
        end
      else
        result = mod.method(:_compiled_component).call(args[:locals] || {}, &).to_str
        assert_equal expected_result, result
      end
    end
  ensure
    RBlade.direct_component_rendering = false
  end

  def module_context
    mod = Module.new do
      extend ActionView::Helpers

      @output_buffer = ActionView::OutputBuffer.new
      @view_flow = ActionView::OutputFlow.new

      def self.params
        {email: "user@example.com"}
      end

      def self.view_paths
        [File.join(File.dirname(__FILE__), "fixtures")]
      end

      def self.render(**args)
        template = File.read(File.join(File.dirname(__FILE__), "fixtures#{args[:template]}.rblade"))

        local_assigns = {}
        attributes = args[:locals][:attributes]
        slot = args[:locals][:slot]

        options = OpenStruct.new(
          short_identifier: args[:template].delete_prefix("/"),
          locals: ["attributes", "slot"],
        )

        capture do
          module_eval "def _component(local_assigns, attributes, slot);#{RBlade::RailsTemplate.new.call(options, template)}end;module_function :_component", __FILE__, __LINE__
          _component(local_assigns, attributes, slot)
        end
      end
    end

    RBlade::Railtie.setup_component_view_helper(mod.singleton_class)

    mod
  end
end
