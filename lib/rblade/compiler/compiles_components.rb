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

    def ensure_all_tags_closed
      unless @component_stack.empty?
        raise RBladeTemplateError.new("Unexpected end of document. Expecting </x-#{@component_stack.last[:name]}>")
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
        "_slot.call(:'#{RBlade.escape_quotes(component[:name].delete_prefix("slot::"))}', {#{attributes.join(",")}}) do |_out|;"
      else
        "_out<<#{ComponentStore.component(component[:name])}(RBlade::AttributesManager.new({#{attributes.join(",")}}),params,session,flash,cookies,_rblade_components) do |_out,_slot|;"
      end
    end

    def compile_token_end token
      component = @component_stack.pop
      if component.nil?
        raise RBladeTemplateError.new "Unexpected closing tag </x-#{token.value[:name]}>"
      end

      if token.type == :component_end && token.value[:name] != component[:name]
        raise RBladeTemplateError.new "Unexpected closing tag </x-#{token.value[:name]}>, expecting </x-#{component[:name]}>"
      end

      "_out;end;"
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
      string.split(/((?<!@)\{\{.*?\}\})/).map do |substring|
        if substring.start_with?('{{') && substring.end_with?('}}')
          "(#{substring[2..-3]}).to_s"
        else
          "'#{RBlade.escape_quotes(substring.gsub(/@\{\{/, '{{'))}'"
        end
      end.join('<<').prepend('+')
    end
  end
end
