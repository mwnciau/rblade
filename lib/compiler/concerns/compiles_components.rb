require_relative "statements/compiles_conditionals"

class CompilesComponents
  def self.compile!(tokens)
    tokens.each do |token|
      if [:component, :component_start, :component_end].none? token.type
        next
      end

      name = token.value[:name]
      attributes = token.value[:attributes]

      dd token, token.type, name, type, attributes
    end
  end
end
