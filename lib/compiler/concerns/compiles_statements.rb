require_relative "statements/compiles_conditionals"
require_relative "statements/compiles_inline_ruby"
require_relative "statements/compiles_loops"

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
    handlerClass, handlerMethod = @@statementHandlers[name]

    if !handlerClass&.method_defined?(handlerMethod)
      raise StandardError.new "Unhandled statement: @#{name}"
    end

    if handlerClass == CompilesStatements
      @@handlerInstances[handlerClass] = self
    else
      @@handlerInstances[handlerClass] ||= handlerClass.new
    end

    @@handlerInstances[handlerClass].method(handlerMethod)
  end

  @@handlerInstances = {}

  @@statementHandlers = {
    "break" => [CompilesLoops, :compileBreak],
    "case" => [CompilesConditionals, :compileCase],
    "checked" => [CompilesConditionals, :compileChecked],
    "disabled" => [CompilesConditionals, :compileDisabled],
    "else" => [CompilesConditionals, :compileElse],
    "elsif" => [CompilesConditionals, :compileElsif],
    "empty" => [CompilesLoops, :compileEndForElse],
    "end" => [CompilesStatements, :compileEnd],
    "endcase" => [CompilesStatements, :compileEnd],
    "endfor" => [CompilesStatements, :compileEnd],
    "endforelse" => [CompilesLoops, :compileEndForElse],
    "endif" => [CompilesStatements, :compileEnd],
    "endunless" => [CompilesStatements, :compileEnd],
    "enduntil" => [CompilesStatements, :compileEnd],
    "endwhile" => [CompilesStatements, :compileEnd],
    "for" => [CompilesLoops, :compileFor],
    "forelse" => [CompilesLoops, :compileForElse],
    "if" => [CompilesConditionals, :compileIf],
    "next" => [CompilesLoops, :compileNext],
    "readonly" => [CompilesConditionals, :compileReadonly],
    "required" => [CompilesConditionals, :compileRequired],
    "ruby" => [CompilesInlineRuby, :compile],
    "selected" => [CompilesConditionals, :compileSelected],
    "unless" => [CompilesConditionals, :compileUnless],
    "until" => [CompilesLoops, :compileUntil],
    "when" => [CompilesConditionals, :compileWhen],
    "while" => [CompilesLoops, :compileWhile]
  }
end
