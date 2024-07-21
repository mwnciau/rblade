require "rblade/component_store"

module RBlade
  class CompilesComponents
    def compile!(tokens)
      tokens.each do |token|
        if [:component, :component_start, :component_end].none? token.type
          next
        end

        token.value = if token.type == :component_start
          compile_token_start token
        elsif token.type == :component_end
          compile_token_end token
        else
          compile_token_start(token) + compile_token_end(token)
        end
      end
    end

    private

    def compile_token_start token
      attributes = compile_attributes token
      "def _component(attributes={#{attributes[:arguments].join(",")}});#{attributes[:assignments].join}_out='';"
    end

    def compile_token_end token
      code = "slot=_out;_out='';_stacks=[];"
      code << ComponentStore.fetchComponent(token.value[:name])
      code << "RBlade::StackManager.get(_stacks) + _out;end;_out<<_component();"

      code
    end

    def compile_attributes token
      attribute_arguments = []
      attribute_assignments = []

      token.value[:attributes].each do |attribute|
        if attribute[:type] == "class" || attribute[:type] == "style"
          attribute_arguments.push "'#{attribute[:type]}': #{attribute[:value]}'"

          next
        end

        if attribute[:type] == "string"
          attribute_arguments.push "'#{attribute[:name]}': '#{RBlade::escape_quotes(attribute[:value])}'"
        end

        if attribute[:type] == "ruby"
          attribute_arguments.push "'#{attribute[:name]}': (#{attribute[:value]})'"
        end

        if attribute[:type] == "pass_through"
          attribute_arguments.push "#{attribute[:name]}:"
        end

        if attribute[:type] == "empty"
          attribute_arguments.push "'#{attribute[:name]}': true"
        end

        variable_name = attribute[:name]&.tr("-", "_")
        if !variable_name.nil? && variable_name.match(/^[A-Za-z_][A-Za-z0-9_]*$/)
          keywords = %w[__FILE__ __LINE__ alias and begin BEGIN break case class def defined? do else elsif end END ensure false for if in module next nil not or redo rescue retry return self super then true undef unless until when while yield attributes _out slot]
          next if keywords.include? variable_name

          attribute_assignments.push "#{variable_name} = attributes[:'#{attribute[:name]}'];"
        end
      end

      {arguments: attribute_arguments, assignments: attribute_assignments}
    end
  end
end
