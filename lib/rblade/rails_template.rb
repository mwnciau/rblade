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

      -"_stacks=[];@_rblade_once_tokens=[];#{component_store.get}#{RBlade::Compiler.compileString(source, component_store)}@output_buffer.raw_buffer.prepend(RBlade::StackManager.get(_stacks))"
    end
  end
end
