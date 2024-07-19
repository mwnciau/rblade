require_relative "statements/compiles_conditionals"

class CompilesStatements
  def self.compile!(tokens)
    token_index = 0
    while token_index < tokens.count
      token = tokens[token_index]
      if token.type != :statement
        token_index += 1
        next
      end

      name = token.value[:name]
      arguments = token.value[:arguments]
      handler = @@statementHandlers[name]

      if handler.nil?
        raise Exception.new "Unhandled statement: @#{name}"
      end

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

  def self.compileEnd
    "end;"
  end

  @@statementHandlers = {
    "case" => CompilesConditionals.method(:compileCase),
    "checked" => CompilesConditionals.method(:compileChecked),
    "disabled" => CompilesConditionals.method(:compileDisabled),
    "else" => CompilesConditionals.method(:compileElse),
    "elsif" => CompilesConditionals.method(:compileElsif),
    "end" => CompilesStatements.method(:compileEnd),
    "endcase" => CompilesStatements.method(:compileEnd),
    "endif" => CompilesStatements.method(:compileEnd),
    "endunless" => CompilesStatements.method(:compileEnd),
    "if" => CompilesConditionals.method(:compileIf),
    "readonly" => CompilesConditionals.method(:compileReadonly),
    "required" => CompilesConditionals.method(:compileRequired),
    "selected" => CompilesConditionals.method(:compileSelected),
    "unless" => CompilesConditionals.method(:compileUnless),
    "when" => CompilesConditionals.method(:compileWhen)
  }
end
