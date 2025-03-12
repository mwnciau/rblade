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

    def compileEnd
      "end;"
    end

    def self.has_handler(name)
      name = name.downcase
      @@statement_handlers[name.tr("_", "")].present? || name.start_with?("end")
    end

    def self.register_handler(name, &block)
      @@statement_handlers[name.tr("_", "").downcase] = ["proc", block]
    end

    def self.register_raw_handler(name, &block)
      @@statement_handlers[name.tr("_", "").downcase] = ["raw_proc", block]
    end

    private

    def get_handler(name)
      handler_class, handler_method = @@statement_handlers[name.tr("_", "").downcase]

      if handler_class == "proc" || handler_class == "raw_proc"
        return [handler_class, handler_method]
      end

      if !handler_class&.method_defined?(handler_method)
        if name.start_with? "end"
          ## Fallback to the default end handler
          handler_class, handler_method = @@statement_handlers["end"]
        else
          raise RBladeTemplateError.new "Unhandled statement: @#{name}"
        end
      end

      if handler_class == CompilesStatements
        @@handler_instances[handler_class] = self
      else
        @@handler_instances[handler_class] ||= handler_class.new
      end

      [handler_class, @@handler_instances[handler_class].method(handler_method)]
    end

    @@handler_instances = {}

    @@statement_handlers = {
      "blank?" => [CompilesConditionals, :compileBlank],
      "break" => [CompilesLoops, :compileBreak],
      "case" => [CompilesConditionals, :compileCase],
      "checked" => [CompilesConditionals, :compileChecked],
      "class" => [CompilesHtmlAttributes, :compileClass],
      "defined?" => [CompilesConditionals, :compileDefined],
      "delete" => [CompilesForm, :compileDelete],
      "disabled" => [CompilesConditionals, :compileDisabled],
      "else" => [CompilesConditionals, :compileElse],
      "elsif" => [CompilesConditionals, :compileElsif],
      "each" => [CompilesLoops, :compileEach],
      "eachelse" => [CompilesLoops, :compileEachElse],
      "eachwithindex" => [CompilesLoops, :compileEachWithIndex],
      "eachwithindexelse" => [CompilesLoops, :compileEachWithIndexElse],
      "empty" => [CompilesLoops, :compileEmpty],
      "empty?" => [CompilesConditionals, :compileEmpty],
      "end" => [CompilesStatements, :compileEnd],
      "env" => [CompilesConditionals, :compileEnv],
      "for" => [CompilesLoops, :compileFor],
      "forelse" => [CompilesLoops, :compileForElse],
      "if" => [CompilesConditionals, :compileIf],
      "method" => [CompilesForm, :compileMethod],
      "next" => [CompilesLoops, :compileNext],
      "nil?" => [CompilesConditionals, :compileNil],
      "old" => [CompilesForm, :compileOld],
      "once" => [CompilesOnce, :compileOnce],
      "patch" => [CompilesForm, :compilePatch],
      "prepend" => [CompilesStacks, :compilePrepend],
      "prependif" => [CompilesStacks, :compilePrependIf],
      "prependonce" => [CompilesOnce, :compilePrependOnce],
      "present?" => [CompilesConditionals, :compilePresent],
      "production" => [CompilesConditionals, :compileProduction],
      "props" => [CompilesComponentHelpers, :compileProps],
      "push" => [CompilesStacks, :compilePush],
      "pushif" => [CompilesStacks, :compilePushIf],
      "pushonce" => [CompilesOnce, :compilePushOnce],
      "put" => [CompilesForm, :compilePut],
      "readonly" => [CompilesConditionals, :compileReadonly],
      "required" => [CompilesConditionals, :compileRequired],
      "ruby" => [CompilesInlineRuby, :compile],
      "selected" => [CompilesConditionals, :compileSelected],
      "shouldrender" => [CompilesComponentHelpers, :compileShouldRender],
      "stack" => [CompilesStacks, :compileStack],
      "style" => [CompilesHtmlAttributes, :compileStyle],
      "unless" => [CompilesConditionals, :compileUnless],
      "until" => [CompilesLoops, :compileUntil],
      "when" => [CompilesConditionals, :compileWhen],
      "while" => [CompilesLoops, :compileWhile]
    }
  end
end
