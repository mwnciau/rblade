# frozen_string_literal: true

require "rblade/compiler/statements/compiles_component_helpers"
require "rblade/compiler/statements/compiles_conditionals"
require "rblade/compiler/statements/compiles_form"
require "rblade/compiler/statements/compiles_html_attributes"
require "rblade/compiler/statements/compiles_inline_ruby"
require "rblade/compiler/statements/compiles_loops"
require "rblade/compiler/statements/compiles_once"
require "rblade/compiler/statements/compiles_stacks"

module RBlade
  class CompilesStatements
    def compile!(tokens)
      token_index = 0
      while token_index < tokens.count
        token = tokens[token_index]

        if token.type != :statement
          token_index += 1
          next
        end

        name = token.value[:name]
        arguments = token.value[:arguments]
        handler_class, handler = get_handler(name)

        handler_arguments = []
        handler.parameters.each do |parameter|
          case parameter.last
          when :args
            handler_arguments.push arguments
          when :tokens
            handler_arguments.push tokens
          when :token_index
            handler_arguments.push token_index
          else
            handler_arguments.push nil
          end
        end

        token.value = if handler_class == "proc"
          "@output_buffer.raw_buffer<<-'#{RBlade.escape_quotes(handler.call(*handler_arguments).to_s)}';"
        else
          handler.call(*handler_arguments)
        end
        token_index += 1
      end
    end

    def compile_end
      "end;"
    end

    def self.has_handler(name)
      statement_handlers[name].present? || (name.start_with?("end") && name != "endruby")
    end

    def self.register_handler(name, &block)
      statement_handlers[name.tr("_", "").downcase] = ["proc", block]
    end

    def self.register_raw_handler(name, &block)
      statement_handlers[name.tr("_", "").downcase] = ["raw_proc", block]
    end

    private

    def get_handler(name)
      handler_class, handler_method = statement_handlers[name]

      if handler_class == "proc" || handler_class == "raw_proc"
        return [handler_class, handler_method]
      end

      if !handler_class&.method_defined?(handler_method)
        if name.start_with? "end"
          ## Fallback to the default end handler
          handler_class, handler_method = statement_handlers["end"]
        else
          raise RBladeTemplateError.new "Unhandled statement: @#{name}"
        end
      end

      if handler_class == CompilesStatements
        handler_instances[handler_class] = self
      else
        handler_instances[handler_class] ||= handler_class.new
      end

      [handler_class, handler_instances[handler_class].method(handler_method)]
    end

    cattr_accessor :handler_instances, default: {}

    cattr_accessor :statement_handlers, default: {
      "blank?" => [CompilesConditionals, :compile_blank],
      "break" => [CompilesLoops, :compile_break],
      "case" => [CompilesConditionals, :compile_case],
      "checked" => [CompilesConditionals, :compile_checked],
      "class" => [CompilesHtmlAttributes, :compile_class],
      "defined?" => [CompilesConditionals, :compile_defined],
      "delete" => [CompilesForm, :compile_delete],
      "disabled" => [CompilesConditionals, :compile_disabled],
      "else" => [CompilesConditionals, :compile_else],
      "elsif" => [CompilesConditionals, :compile_elsif],
      "each" => [CompilesLoops, :compile_each],
      "eachelse" => [CompilesLoops, :compile_each_else],
      "eachwithindex" => [CompilesLoops, :compile_each_with_index],
      "eachwithindexelse" => [CompilesLoops, :compile_each_with_index_else],
      "empty" => [CompilesLoops, :compile_empty],
      "empty?" => [CompilesConditionals, :compile_empty],
      "end" => [CompilesStatements, :compile_end],
      "env" => [CompilesConditionals, :compile_env],
      "for" => [CompilesLoops, :compile_for],
      "forelse" => [CompilesLoops, :compile_for_else],
      "if" => [CompilesConditionals, :compile_if],
      "method" => [CompilesForm, :compile_method],
      "next" => [CompilesLoops, :compile_next],
      "nil?" => [CompilesConditionals, :compile_nil],
      "old" => [CompilesForm, :compile_old],
      "once" => [CompilesOnce, :compile_once],
      "patch" => [CompilesForm, :compile_patch],
      "prepend" => [CompilesStacks, :compile_prepend],
      "prependif" => [CompilesStacks, :compile_prepend_if],
      "prependonce" => [CompilesOnce, :compile_prepend_once],
      "present?" => [CompilesConditionals, :compile_present],
      "production" => [CompilesConditionals, :compile_production],
      "props" => [CompilesComponentHelpers, :compile_props],
      "push" => [CompilesStacks, :compile_push],
      "pushif" => [CompilesStacks, :compile_push_if],
      "pushonce" => [CompilesOnce, :compile_push_once],
      "put" => [CompilesForm, :compile_put],
      "readonly" => [CompilesConditionals, :compile_readonly],
      "required" => [CompilesConditionals, :compile_required],
      "ruby" => [CompilesInlineRuby, :compile],
      "selected" => [CompilesConditionals, :compile_selected],
      "shouldrender" => [CompilesComponentHelpers, :compile_should_render],
      "stack" => [CompilesStacks, :compile_stack],
      "style" => [CompilesHtmlAttributes, :compile_style],
      "unless" => [CompilesConditionals, :compile_unless],
      "until" => [CompilesLoops, :compile_until],
      "when" => [CompilesConditionals, :compile_when],
      "while" => [CompilesLoops, :compile_while],
    }
  end
end
