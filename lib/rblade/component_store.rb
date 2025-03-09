# frozen_string_literal: true

module RBlade
  class ComponentStore
    FILE_EXTENSIONS = [".rblade", ".html.rblade"]

    def initialize
      @component_definitions = +""
      @component_name_stack = []
      @component_method_names = {}
    end

    # Retrieve the method name for a component, and compile it if it hasn't already been compiled
    def component(full_name)
      # If this is a relative path, prepend with the previous component name's base
      if full_name.start_with? "."
        full_name = @component_name_stack.last.gsub(/\.[^\.]+\Z/, "") + full_name
      end

      # Ensure each component is only compiled once
      unless @component_method_names[full_name].nil?
        return @component_method_names[full_name]
      end

      @component_name_stack << full_name

      namespace = nil
      name = full_name

      if name.match? "::"
        namespace, name = full_name.split("::")
      end

      method_name = compile_component full_name, File.read(find_component_file(namespace, name))
      @component_name_stack.pop

      method_name
    end

    def self.add_path(path, namespace = nil)
      path = path.to_s
      unless path.end_with? "/"
        path << "/"
      end

      @@template_paths[namespace] ||= []
      @@template_paths[namespace] << path
    end

    def view_name(view_name)
      @component_name_stack.push view_name
    end

    def get
      @component_definitions
    end

    private

    def find_component_file(namespace, name)
      file_path = name.tr ".", "/"

      @@template_paths[namespace]&.each do |base_path|
        FILE_EXTENSIONS.each do |extension|
          if File.exist? base_path + file_path + extension
            return "#{base_path}#{file_path}#{extension}"
          end
          if File.exist? base_path + file_path + "/index" + extension
            # Account for index files for relative components
            @component_name_stack << @component_name_stack.pop + ".index"
            return "#{base_path}#{file_path}/index#{extension}"
          end
        end
      end

      raise RBladeTemplateError.new "Unknown component #{namespace}::#{name}"
    end

    def compile_component(name, template)
      escaped_name = name.gsub(/[^0-9a-zA-Z_]/) do |match|
        # Convert invalid characters to hex
        (match == ".") ? "__" : "_#{match.unpack1("H*")}_"
      end

      compiled_component = RBlade::Compiler.compileString(template, self)

      slot_assignment = compiled_component.match?(/\Wslot\W/) ? "slot=" : ""

      @component_definitions << "def self._rblade_component_#{escaped_name}(attributes,&);#{slot_assignment}if block_given?;RBlade::SlotManager.new(@output_buffer.capture(->(name, slot_attributes, &slot_block)do;attributes[name]=RBlade::SlotManager.new(@output_buffer.capture(&slot_block), slot_attributes);end,&));end;_stacks=[];@output_buffer.raw_buffer<<@output_buffer.capture do;#{compiled_component}@output_buffer.raw_buffer.prepend(@_rblade_stack_manager.get(_stacks));end;end;"

      @component_method_names[name] = "_rblade_component_#{escaped_name}"
    end

    @@template_paths = {}
  end
end
