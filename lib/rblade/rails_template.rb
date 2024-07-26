require "rails"
require "rblade/compiler"
require "rblade/component_store"
require "rblade/helpers/attributes_manager"
require "rblade/helpers/class_manager"
require "rblade/helpers/stack_manager"
require "rblade/helpers/style_manager"

module RBlade
  class RailsTemplate
    def call(template, source = nil)
      RBlade::ComponentStore::clear
      RBlade::StackManager.clear
      setup = "_out='';_stacks=[];"
      code = RBlade::Compiler.compileString(source || template.source)
      setdown = "RBlade::StackManager.get(_stacks) + _out"
      setup + ComponentStore.get() + code + setdown
    end
  end
end
