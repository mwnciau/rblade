# frozen_string_literal: true

require "rails"
require "rblade/compiler"
require "rblade/component_store"
require "rblade/helpers/attributes_manager"
require "rblade/helpers/class_manager"
require "rblade/helpers/slot_manager"
require "rblade/helpers/stack_manager"
require "rblade/helpers/style_manager"

module RBlade
  class RailsTemplate
    def call(template, source = nil)
      component_store = RBlade::ComponentStore.new
      RBlade::StackManager.clear

      unless template.nil?
        view_name = template.short_identifier
          .delete_prefix("app/views/")
          .delete_suffix(".rblade")
          .delete_suffix(".html")
          .tr("/", ".")

        # Let the component store know about the current view for relative components
        component_store.view_name("view::#{view_name}")
      end
      setup = "_out=+'';_stacks=[];$_once_tokens=[];"
      code = RBlade::Compiler.compileString(source, component_store)
      setdown = "RBlade::StackManager.get(_stacks) + _out"
      setup + component_store.get + code + setdown
    end
  end
end
