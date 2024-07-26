require "rblade/compiler"

module RBlade
  FILE_EXTENSIONS = [".rblade", ".html.rblade"]

  class ComponentStore
    # Retrieve the method name for a component, and compile it if it hasn't already been compiled
    def self.component full_name
      # Ensure each component is only compiled once
      unless @@component_method_names[full_name].nil?
        return @@component_method_names[full_name]
      end

      namespace = nil
      name = full_name

      if name.match? "::"
        namespace, name = full_name.split("::")
      end

      return compile_component full_name, File.read(find_component_file(namespace, name))
    end

    def self.add_path path, namespace = nil
      path = path.to_s
      if !path.end_with? "/"
        path += "/"
      end

      @@template_paths[namespace] ||= []
      @@template_paths[namespace] << path
    end

    def self.get
      @@component_definitions
    end

    def self.clear
      @@component_definitions = ''
      @@component_method_names = {}
    end

    private

    @@component_definitions = ''
    @@component_method_names = {}
    @@template_paths = {}

    def self.find_component_file namespace, name
      file_path = name.tr ".", "/"

      @@template_paths[namespace]&.each do |base_path|
        FILE_EXTENSIONS.each do |extension|
          if File.exist? base_path + file_path + extension
            return base_path + file_path + extension
          end
        end
      end

      raise StandardError.new "Unknown component #{namespace}::#{name}"
    end

    def self.compile_component(name, code)
      @@component_method_names[name] = "_c#{@@component_method_names.count}"

      @@component_definitions <<
        "def #{@@component_method_names[name]}(slot,attributes);_out='';" <<
        "_stacks=[];" <<
        "attributes=RBlade::AttributesManager.new(attributes);" <<
        RBlade::Compiler.compileString(code) <<
        "RBlade::StackManager.get(_stacks) + _out;end;"

      @@component_method_names[name]
    end
  end
end
