require "rblade/compiler"

module RBlade
  FILE_EXTENSIONS = [".blade", ".html.blade"]

  class ComponentStore
    def self.fetchComponent name
      namespace = nil
      path = name

      if name.match '::'
        namespace, path = name.split('::')
      end

      path.gsub! '.', '/'

      @@templatePaths[namespace]&.each do |base_path|
        FILE_EXTENSIONS.each do |extension|
          if File.exist? base_path + path + extension
            return RBlade::Compiler.compileString File.read(base_path + path + extension)
          end
        end
      end

      raise StandardError.new "Unknown component #{name}"
    end

    def self.add_path path, namespace = nil
      path = path.to_s
      if !path.end_with? "/"
        path = path + "/"
      end

      @@templatePaths[namespace] ||= []
      @@templatePaths[namespace] << path
    end

    private

    @@templatePaths = {}
  end
end
