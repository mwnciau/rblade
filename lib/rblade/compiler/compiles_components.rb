require "rblade/component_store"

module RBlade
  class CompilesComponents
    def initialize
      @component_count = 0
      @component_stack = []
    end

    def compile!(tokens)
      tokens.each do |token|
        if [:component, :component_start, :component_end, :component_unsafe_end].none? token.type
          next
        end

        token.value = if token.type == :component_start
          compile_token_start token
        elsif token.type == :component_end || token.type == :component_unsafe_end
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
        index: @component_count
      }

      attributes = compile_attributes token.value[:attributes]

      code = "_c#{@component_count}_swap=_out;_out='';"
      code << "_c#{@component_count}_attr={#{attributes.join(",")}};"

      code
    end

    def compile_token_end token
      component = @component_stack.pop
      if component.nil?
        raise StandardError.new "Unexpected closing tag (#{token.value[:name]})"
      end
      if token.type == :component_end && token.value[:name] != component[:name]
        raise StandardError.new "Unexpected closing tag (#{token.value[:name]}) expecting #{component[:name]}"
      end

      code = "_slot=_out;_out=_c#{component[:index]}_swap;"
      code << "_out<<#{ComponentStore.component(component[:name])}(_slot,_c#{component[:index]}_attr);"
      code << "_slot=nil;_c#{component[:index]}_swap=nil;"

      code
    end

    def get_method_name name
      name.gsub(/[^a-zA-Z0-9_]/, "_")
    end

    def compile_attributes attributes
      attributes.map do |attribute|
        case attribute[:type]
        when "class"
          "'class': RBlade::ClassManager.new(#{attribute[:value]})"
        when "style"
          "'style': RBlade::StyleManager.new(#{attribute[:value]})"
        when "attributes"
          "**(#{attribute[:value]})"
        when "string"
          "'#{attribute[:name]}': '#{RBlade.escape_quotes(attribute[:value])}'"
        when "ruby"
          "'#{attribute[:name]}': (#{attribute[:value]})"
        when "pass_through"
          "#{attribute[:name]}:"
        when "empty"
          "'#{attribute[:name]}': true"
        else
          raise StandardError.new "Component compiler: unexpected attribute type (#{attribute[:type]})"
        end
      end
    end
  end
end
