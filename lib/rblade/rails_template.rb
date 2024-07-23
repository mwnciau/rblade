require "rails"
require "rblade/compiler"
require "rblade/helpers/attributes_manager"
require "rblade/helpers/class_manager"
require "rblade/helpers/stack_manager"
require "rblade/helpers/style_manager"

module RBlade
  class RailsTemplate
    def call(template, source = nil)
      RBlade::StackManager.clear
      setup = "_out='';_stacks=[];"
      setdown = "RBlade::StackManager.get(_stacks) + _out"
      setup + RBlade::Compiler.compileString(source || template.source) + setdown
    end
  end
end
