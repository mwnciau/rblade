require_relative "statements/compiles_conditionals"

class CompilesComponents
  def self.compile!(tokens)
    tokens.each do |token|
      if [:component, :component_start, :component_end].none? token.type
        next
      end

      name = token.value[:name]
      attributes = token.value[:attributes]

      compile_token_start token
      if token.type == :component
      end


      dd token, token.type, name, attributes
    end
  end

  def self.compile_token_start token
    attributes = compile_attributes token
    code = "def method({#{attributes[:arguments].join(',')}});#{attributes[:assignments].join}"

    dd code
  end
  private_class_method :compile_token_start

  def self.compile_attributes token
    attribute_arguments = []
    attribute_assignments = []

    token.value[:attributes].each do |attribute|
      if attribute[:type] == 'class' || attribute[:type] == 'style'
        attribute_arguments.push "'#{attribute[:type]}': #{attribute[:value]}'"

        next
      end

      if attribute[:type] == 'string'
        attribute_arguments.push "'#{attribute[:name]}': '#{escape_quotes(attribute[:value])}'"
      end

      if attribute[:type] == 'ruby'
        attribute_arguments.push "'attribute[:name]': (#{attribute[:value]})'"
      end

      if attribute[:type] == 'pass_through'
        attribute_arguments.push "#{attribute[:name]}:"
      end

      if attribute[:type] == 'empty'
        attribute_arguments.push "'#{attribute[:name]}': true"
      end

      variableName = attribute[:name]&.gsub(/-/, "_")
      if !variableName.nil? && variableName.match(/^[A-Za-z_][A-Za-z0-9_]*$/)
        keywords = %w{__FILE__ __LINE__ alias and begin BEGIN break case class def defined? do else elsif end END ensure false for if in module next nil not or redo rescue retry return self super then true undef unless until when while yield}
        next if keywords.include? variableName

        attribute_assignments.push "#{variableName} = attributes[:'#{attribute[:name]}'];"
      end
    end

    ({arguments: attribute_arguments, assignments: attribute_assignments})
  end
  private_class_method :compile_attributes

  def self.compile_token_end token
  end
  private_class_method :compile_token_end
end
