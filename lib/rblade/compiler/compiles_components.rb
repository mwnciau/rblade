# frozen_string_literal: true

require "rblade/component_store"

module RBlade
  class CompilesComponents
    def initialize(component_store)
      @component_count = 0
      @component_stack = []
      @component_store = component_store
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

    def ensure_all_tags_closed
      unless @component_stack.empty?
        raise RBladeTemplateError.new("Unexpected end of document. Expecting </x-#{@component_stack.last[:name]}>")
      end
    end

    private

    def compile_token_start(token)
      component = {
        name: token.value[:name],
      }
      @component_stack << component

      return compile_dynamic_component(token) if component[:name] == "dynamic"

      attributes = compile_attributes token.value[:attributes]

      if component[:name].start_with? "slot::"
        "_slot.call(:'#{RBlade.escape_quotes(component[:name].delete_prefix("slot::"))}', {#{attributes.join(",")}}) do;"
      else
        "#{@component_store.component(component[:name])}(RBlade::AttributesManager.new({#{attributes.join(",")}})) do |_slot|;"
      end
    end

    def compile_dynamic_component(token)
      component_index = token.value[:attributes].index { |item| item[:name] == "component" }
      component = token.value[:attributes].delete_at(component_index)
      component_value = case component[:type]
      when "string"
        process_string_attribute(component[:value])
      when "ruby"
        component[:value]
      when "pass_through"
        component[:name]
      else
        raise RBladeTemplateError.new "Component compiler: unexpected attribute type for component attribute (#{attribute[:type]})"
      end

      attributes = compile_attributes token.value[:attributes]

      "@output_buffer.raw_buffer<<component(#{component_value}, '#{RBlade.escape_quotes(@component_store.current_view_name)}', #{attributes.join ","}) do;"
    end

    def compile_token_end(token)
      component = @component_stack.pop
      if component.nil?
        raise RBladeTemplateError.new "Unexpected closing tag </x-#{token.value[:name]}>"
      end

      if token.type == :component_end && token.value[:name] != component[:name]
        raise RBladeTemplateError.new "Unexpected closing tag </x-#{token.value[:name]}>, expecting </x-#{component[:name]}>"
      end

      "end;"
    end

    def compile_attributes(attributes)
      attributes.map do |attribute|
        case attribute[:type]
        when "class"
          "'class': RBlade::ClassManager.new(#{attribute[:value]})"
        when "style"
          "'style': RBlade::StyleManager.new(#{attribute[:value]})"
        when "attributes"
          "**(#{attribute[:value]})"
        when "string"
          "'#{attribute[:name]}': #{process_string_attribute(attribute[:value])}"
        when "ruby"
          "'#{attribute[:name]}': (#{attribute[:value]})"
        when "pass_through"
          "#{attribute[:name]}:"
        when "empty"
          "'#{attribute[:name]}': true"
        else
          raise RBladeTemplateError.new "Component compiler: unexpected attribute type (#{attribute[:type]})"
        end
      end
    end

    def process_string_attribute(string)
      result = string.split(/((?<!@)\{\{(?:[^}]++|\})*?\}\})/).map do |substring|
        if substring.start_with?("{{") && substring.end_with?("}}")
          "(#{substring[2..-3]}).to_s"
        elsif !substring.empty?
          "'#{RBlade.escape_quotes(substring.gsub(/@\{\{/, "{{"))}'"
        end
      end.compact.join("<<")

      result.empty? ? "+''" : result.prepend("+")
    end
  end
end
