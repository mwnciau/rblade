require_relative "statements/compiles_conditionals"

class CompilesStatements
  def self.compile!(tokens)
    tokens.each do |token|
      if token.type != :statement
        next
      end

      name = token.value[:name]
      arguments = token.value[:arguments]
      handler = @@statementHandlers[name]

      if handler.nil?
        raise Exception.new "Unhandled statement: @#{name}"
      end

      token.value = handler.call(arguments)
    end
  end

  def self.compileEnd statement
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
