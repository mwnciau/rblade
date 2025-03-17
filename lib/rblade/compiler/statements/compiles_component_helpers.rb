# frozen_string_literal: true

require "rblade/helpers/tokenizer"

module RBlade
  class CompilesStatements
    class CompilesComponentHelpers
      def compileShouldRender(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Should render statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "unless(#{args[0]});return'';end;"
      end

      def compileProps(args, tokens)
        props = extract_props args
        props.map do |key, value|
          compiled_code = if RBlade.direct_component_rendering
            "if !attributes.has?(:'#{RBlade.escape_quotes(key)}') && content_for?(:'#{RBlade.escape_quotes(key)}');attributes[:'#{RBlade.escape_quotes(key)}']=content_for :'#{RBlade.escape_quotes(key)}';end;"
          else
            +""
          end
          compiled_code << if value == "required"
            "if !attributes.has?(:'#{RBlade.escape_quotes(key)}');raise \"Props statement: #{key} is not defined\";end;"
          else
            "attributes.default(:'#{RBlade.escape_quotes(key)}', #{value});"
          end

          if is_valid_variable_name key
            compiled_code << if variableIsSlot key, tokens
              "#{key}=RBlade::SlotManager.wrap(attributes.delete :'#{RBlade.escape_quotes(key)}');"
            else
              "#{key}=attributes.delete :'#{RBlade.escape_quotes(key)}';"
            end
          end

          compiled_code
        end.join
      end

      private

      def extract_props(prop_strings)
        props = {}

        prop_strings.each do |prop|
          prop.strip!

          key, value = prop.split(/\A
            (?:
              '(.+)':
              |
              "(.+)":
              |
              ([^ :]+):
              |
              :(?:
                '(.+?)'
                |
                "(.+?)"
                |
                ([^"' ]+)
              )\s*=>
            )
            \s*(.+?)$
          /x).reject(&:empty?)

          if key.nil? || value.nil?
            raise RBladeTemplateError.new "Props statement: invalid property hash"
          end
          props[key] = value
        end

        props
      end

      RUBY_RESERVED_KEYWORDS = %w[__FILE__ __LINE__ alias and begin BEGIN break case class def defined? do else elsif end END ensure false for if in module next nil not or redo rescue retry return self super then true undef unless until when while yield].freeze

      def is_valid_variable_name(key)
        return false unless key.match?(/\A[a-zA-Z_][a-zA-Z0-9_]*\z/)

        return false if RUBY_RESERVED_KEYWORDS.include? key

        true
      end

      # Automatically detect if a variable is a slot by looking for "<var>.attributes"
      def variableIsSlot name, tokens
        tokens.any? { |token| token.value.to_s.match? "#{name}.attributes" }
      end
    end
  end
end
