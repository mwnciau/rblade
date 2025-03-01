# frozen_string_literal: true

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
      component = {
        name: token.value[:name]
      }
      @component_stack << component

      attributes = compile_attributes token.value[:attributes]

      if component[:name].start_with? "slot::"
        "_out=_out<<_slot.call(:'#{RBlade.escape_quotes(component[:name].delete_prefix("slot::"))}', {#{attributes.join(",")}}) do;_out=+'';"
      else
        "_out=_out<<#{ComponentStore.component(component[:name])}.new.render({#{attributes.join(",")}},params,session,flash,cookies) do |_slot|;_out=+'';"
      end
    end

    def compile_token_end token
      component = @component_stack.pop
      if component.nil?
        raise StandardError.new "Unexpected closing tag (#{token.value[:name]})"
      end
      if token.type == :component_end && token.value[:name] != component[:name]
        raise StandardError.new "Unexpected closing tag (#{token.value[:name]}) expecting #{component[:name]}"
      end

      "_out;end;"
    end

    def compile_slot_end name, component
      parent = @component_stack.last

      code = "_c#{parent[:index]}_attr[:'#{RBlade.escape_quotes(name)}']=RBlade::SlotManager.new(_out,_c#{component[:index]}_attr);"
      code << "_out=_c#{component[:index]}_swap;_c#{component[:index]}_swap=nil;_c#{component[:index]}_attr=nil;"

      code
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
