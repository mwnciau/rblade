module RBlade
  class RailsTemplate
    def call(template, source = nil)
      RBlade::Compiler.compileString(template)
    end
  end
end
