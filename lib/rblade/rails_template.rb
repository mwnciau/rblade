require "rails"
require "rblade/compiler"
require "rblade/helpers/stack_manager"

module RBlade
  class RailsTemplate
    def call(template, source = nil)
      RBlade::StackManager.clear
      setup = "foo = 'FOO';bar = 'BAR';_out='';_stacks=[];"
      setdown = "RBlade::StackManager.get(_stacks) + _out"
      setup + RBlade::Compiler.compileString(source || template.source) + setdown
    end
  end
end
