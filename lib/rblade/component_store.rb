# frozen_string_literal: true

module RBlade
  FILE_EXTENSIONS = [".rblade", ".html.rblade"]

  class ComponentStore
    class Component
      def initialize(attributes)
        @attributes = RBlade::AttributesManager.new(attributes)
      end

      attr_accessor :attributes

      def render(params, session, flash, cookies, &block)
        slot = capture_slots(&block) if block_given?

        compiled_component(slot, params, session, flash, cookies)
      end

      private

      def capture_slots
        RBlade::SlotManager.new yield(+"", ->(name, attributes, &block) do
          @attributes[name] = RBlade::SlotManager.new(block.call(+""), attributes)
        end)
      end
    end

    # Retrieve the method name for a component, and compile it if it hasn't already been compiled
    def self.component full_name
      # If this is a relative path, prepend with the previous component name's base
      if full_name.start_with? "."
        full_name = @@component_name_stack.last.gsub(/\.[^\.]+\Z/, "") + full_name
      end

      # Ensure each component is only compiled once
      unless @@component_method_names[full_name].nil?
        return @@component_method_names[full_name]
      end

      @@component_name_stack << full_name

      namespace = nil
      name = full_name

      if name.match? "::"
        namespace, name = full_name.split("::")
      end

      method_name = compile_component full_name, File.read(find_component_file(namespace, name))
      @@component_name_stack.pop

      method_name
    end

    def self.add_path path, namespace = nil
      path = path.to_s
      unless path.end_with? "/"
        path << "/"
      end

      @@template_paths[namespace] ||= []
      @@template_paths[namespace] << path
    end

    def self.view_name view_name
      @@component_name_stack.push view_name
    end

    def self.get
      @@component_definitions
    end

    def self.clear
      @@component_definitions = +""
      @@component_method_names = {}
      @@component_name_stack = []
    end

    def self.find_component_file namespace, name
      file_path = name.tr ".", "/"

      @@template_paths[namespace]&.each do |base_path|
        FILE_EXTENSIONS.each do |extension|
          if File.exist? base_path + file_path + extension
            return "#{base_path}#{file_path}#{extension}"
          end
          if File.exist? base_path + file_path + "/index" + extension
            # Account for index files for relative components
            @@component_name_stack << @@component_name_stack.pop + ".index"
            return "#{base_path}#{file_path}/index#{extension}"
          end
        end
      end

      raise StandardError.new "Unknown component #{namespace}::#{name}"
    end
    private_class_method :find_component_file

    def self.compile_component(name, code)
      @@component_method_names[name] = "RBlade::ComponentStore::C#{@@component_method_names.count}"

      compiled_component = RBlade::Compiler.compileString(code)

      @@component_definitions << "class #{@@component_method_names[name]} < RBlade::ComponentStore::Component;private def compiled_component(slot,params,session,flash,cookies);_out=+'';_stacks=[];#{compiled_component}RBlade::StackManager.get(_stacks)+_out;end;end;"

      @@component_method_names[name]
    end
    private_class_method :compile_component

    private

    @@component_definitions = +""
    @@component_name_stack = []
    @@component_method_names = {}
    @@template_paths = {}
  end
end
