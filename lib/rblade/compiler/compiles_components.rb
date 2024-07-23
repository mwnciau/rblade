require "rblade/component_store"

module RBlade
  class CompilesComponents
    def initialize
      @component_count = 0
      @component_stack = []
    end

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
      @component_count += 1

      @component_stack << {
        name: token.value[:name],
        attributes: token.value[:attributes],
        index: @component_count
      }

      "_comp_#{@component_count}_swap=_out;_out='';"
    end

    def compile_token_end token
      component = @component_stack.pop
      if component.nil?
        raise StandardError.new "Unexpected closing tag (#{token.value[:name]})"
      end
      if token.value[:name] != component[:name]
        raise StandardError.new "Unexpected closing tag (#{token.value[:name]}) expecting #{component[:name]}"
      end

      attributes = compile_attributes component[:attributes]

      code = "def _component(slot,attributes);#{attributes[:assignments].join}_out='';"
      code << "_stacks=[];"
      code << "attributes=RBlade::AttributesManager.new(attributes);"
      code << ComponentStore.fetchComponent(token.value[:name])
      code << "RBlade::StackManager.get(_stacks) + _out;end;"
      code << "_slot=_out;_out=_comp_#{component[:index]}_swap;"
      code << "_out<<_component(_slot,{#{attributes[:arguments].join(",")}});"

      code
    end

    def compile_attributes attributes
      attribute_arguments = []
      attribute_assignments = []

      attributes.each do |attribute|
        if attribute[:type] == "class"
          attribute_arguments.push "'class': RBlade::ClassManager.new(#{attribute[:value]})"
          attribute_assignments.push "_class = attributes[:class];"

          next
        end
        if attribute[:type] == "style"
          attribute_arguments.push "'style': RBlade::StyleManager.new(#{attribute[:value]})"
          attribute_assignments.push "_style = attributes[:style];"

          next
        end
        if attribute[:type] == "attributes"
          attribute_arguments.push "**attributes.to_h"
          attribute_assignments.push "_style = attributes[:style];"

          next
        end

        if attribute[:type] == "string"
          attribute_arguments.push "'#{attribute[:name]}': '#{RBlade.escape_quotes(attribute[:value])}'"
        end

        if attribute[:type] == "ruby"
          attribute_arguments.push "'#{attribute[:name]}': (#{attribute[:value]})"
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
