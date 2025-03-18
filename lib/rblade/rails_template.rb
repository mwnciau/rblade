# frozen_string_literal: true

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

      unless template.nil?
        view_name = template.short_identifier
          .delete_prefix("app/views/")
          .delete_suffix(".rblade")
          .delete_suffix(".html")
          .tr("/", ".")

        # Let the component store know about the current view for relative components
        component_store.view_name("view::#{view_name}")
      end

      preamble = +"_stacks=[];@_rblade_once_tokens=[];@_rblade_stack_manager=RBlade::StackManager.new;"
      if RBlade.direct_component_rendering
        # If the attributes and slot are already set, we don't need to assign them
        unless template&.locals&.include?("attributes") && template.locals.include?("slot")
          preamble << "attributes=RBlade::AttributesManager.new(local_assigns);slot||=yield if block_given?;slot=attributes.delete(:slot) if slot.blank?;"
        end
      end

      -"#{preamble}#{component_store.get}#{RBlade::Compiler.compile_string(source, component_store)}@output_buffer.raw_buffer.prepend(@_rblade_stack_manager.get(_stacks));@output_buffer;"
    end
  end
end
