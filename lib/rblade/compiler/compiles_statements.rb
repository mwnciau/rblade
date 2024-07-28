require "rblade/compiler/statements/compiles_conditionals"
require "rblade/compiler/statements/compiles_html_attributes"
require "rblade/compiler/statements/compiles_inline_ruby"
require "rblade/compiler/statements/compiles_loops"
require "rblade/compiler/statements/compiles_props"
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
        handler = getHandler(name)

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

        token.value = handler.call(*handler_arguments)
        token_index += 1
      end
    end

    def compileEnd
      "end;"
    end

    private

    def getHandler(name)
      handler_class, handler_method = @@statement_handlers[name]

      if !handler_class&.method_defined?(handler_method)
        raise StandardError.new "Unhandled statement: @#{name}"
      end

      if handler_class == CompilesStatements
        @@handler_instances[handler_class] = self
      else
        @@handler_instances[handler_class] ||= handler_class.new
      end

      @@handler_instances[handler_class].method(handler_method)
    end

    @@handler_instances = {}

    @@statement_handlers = {
      "break" => [CompilesLoops, :compileBreak],
      "breakif" => [CompilesLoops, :compileBreakIf],
      "case" => [CompilesConditionals, :compileCase],
      "checked" => [CompilesConditionals, :compileChecked],
      "class" => [CompilesHtmlAttributes, :compileClass],
      "disabled" => [CompilesConditionals, :compileDisabled],
      "else" => [CompilesConditionals, :compileElse],
      "elsif" => [CompilesConditionals, :compileElsif],
      "each" => [CompilesLoops, :compileEach],
      "eachelse" => [CompilesLoops, :compileEachElse],
      "empty" => [CompilesLoops, :compileEmpty],
      "end" => [CompilesStatements, :compileEnd],
      "endcase" => [CompilesStatements, :compileEnd],
      "endeach" => [CompilesStatements, :compileEnd],
      "endeachelse" => [CompilesStatements, :compileEnd],
      "endenv" => [CompilesStatements, :compileEnd],
      "endfor" => [CompilesStatements, :compileEnd],
      "endforelse" => [CompilesStatements, :compileEnd],
      "endif" => [CompilesStatements, :compileEnd],
      "endprepend" => [CompilesStacks, :compileEndPrepend],
      "endproduction" => [CompilesStatements, :compileEnd],
      "endpush" => [CompilesStacks, :compileEndPush],
      "endunless" => [CompilesStatements, :compileEnd],
      "enduntil" => [CompilesStatements, :compileEnd],
      "endwhile" => [CompilesStatements, :compileEnd],
      "env" => [CompilesConditionals, :compileEnv],
      "for" => [CompilesLoops, :compileFor],
      "forelse" => [CompilesLoops, :compileForElse],
      "if" => [CompilesConditionals, :compileIf],
      "next" => [CompilesLoops, :compileNext],
      "nextif" => [CompilesLoops, :compileNextIf],
      "prepend" => [CompilesStacks, :compilePrepend],
      "production" => [CompilesConditionals, :compileProduction],
      "props" => [CompilesProps, :compileProps],
      "push" => [CompilesStacks, :compilePush],
      "readonly" => [CompilesConditionals, :compileReadonly],
      "required" => [CompilesConditionals, :compileRequired],
      "ruby" => [CompilesInlineRuby, :compile],
      "selected" => [CompilesConditionals, :compileSelected],
      "stack" => [CompilesStacks, :compileStack],
      "style" => [CompilesHtmlAttributes, :compileStyle],
      "unless" => [CompilesConditionals, :compileUnless],
      "until" => [CompilesLoops, :compileUntil],
      "when" => [CompilesConditionals, :compileWhen],
      "while" => [CompilesLoops, :compileWhile]
    }
  end
end
