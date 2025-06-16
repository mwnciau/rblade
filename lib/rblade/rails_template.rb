# frozen_string_literal: true

require "rblade/compiler"
require "rblade/component_store"
require "rblade/helpers/attributes_manager"
require "rblade/helpers/class_manager"
require "rblade/helpers/slot_manager"
require "rblade/helpers/source_map"
require "rblade/helpers/stack_manager"
require "rblade/helpers/string_utility"
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

      -"#{preamble}\n#{component_store.get}\n#{RBlade::Compiler.compile_string(source, component_store)}@output_buffer.raw_buffer.prepend(@_rblade_stack_manager.get(_stacks));@output_buffer;"
    end

    def translate_location(spot, backtrace_location, source)
      view_name = backtrace_location.path
        .sub(/^.*app\/views\/(.+?)(?:\.\w++)?\.rblade$/, "\\1")
        .tr("/", ".")

      # Let the component store know about the current view for relative components
      component_store = RBlade::ComponentStore.new
      component_store.view_name("view::#{view_name}")

      source_map = RBlade::Compiler.generate_source_map(source, component_store)

      # Account for the preamble and component store
      offset = 2 + StringUtility.lines(component_store.get).length
      offset += 1 if spot[:script_lines]&.first == "# frozen_string_literal: true\n"

      location = source_map.source_location(spot[:first_lineno] - offset - 1, spot[:first_column])

      before_lines = StringUtility.lines(source[0...(location[:start_offset])])
      excerpt = source[(location[:start_offset])...(location[:end_offset])]
      excerpt_lines = StringUtility.lines(excerpt)

      first_lineno = before_lines.length
      first_column = before_lines.last.length

      last_lineno = first_lineno + excerpt_lines.length - 1
      last_column = (excerpt_lines.length > 1) ? excerpt_lines.last.length : first_column + excerpt_lines.first.length

      {
        first_lineno: first_lineno,
        first_column: first_column,
        last_lineno: last_lineno,
        last_column: last_column,
        snippet: excerpt,
        script_lines: source.lines,
      }
    rescue => e
      Rails.logger&.debug "Unable to locate error position in template: #{e.message}"
      spot
    end
  end
end
