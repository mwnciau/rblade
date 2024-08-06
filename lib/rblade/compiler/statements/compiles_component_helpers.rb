require "rblade/helpers/tokenizer"

module RBlade
  class CompilesStatements
    class CompilesComponentHelpers
      def compileShouldRender args
        if args&.count != 1
          raise StandardError.new "Should render statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "unless(#{args[0]});return'';end;"
      end

      def compileProps args
        if args&.count != 1
          raise StandardError.new "Props statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        props = extractProps args[0]
        props.map do |key, value|
          compiled_code = ""
          if value == "_required"
            compiled_code << "if !attributes.has?(:'#{RBlade.escape_quotes(key)}');raise \"Props statement: #{key} is not defined\";end;"
            compiled_code << "#{key}=attributes[:'#{RBlade.escape_quotes(key)}'];attributes.delete :'#{RBlade.escape_quotes(key)}';"
          elsif isValidVariableName key
            compiled_code << "#{key}=attributes[:'#{RBlade.escape_quotes(key)}'].nil? ? #{value} : attributes[:'#{RBlade.escape_quotes(key)}'];"
            compiled_code << "attributes.delete :'#{RBlade.escape_quotes(key)}';"
          else
            compiled_code << "attributes.default(:'#{RBlade.escape_quotes(key)}', #{value});"
          end

          compiled_code
        end.join
      end

      private

      def extractProps prop_string
        if !prop_string.start_with?("{") || !prop_string.end_with?("}")
          raise StandardError.new "Props statement: expecting hash as parameter"
        end

        props = {}
        prop_strings = Tokenizer.extractCommaSeparatedValues prop_string[1..-2]

        prop_strings.each do |prop|
          prop.strip!

          key, value = prop.split(/^
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
            raise StandardError.new "Props statement: invalid property hash"
          end
          props[key] = value
        end

        props
      end

      RUBY_RESERVED_KEYWORDS = %w[__FILE__ __LINE__ alias and begin BEGIN break case class def defined? do else elsif end END ensure false for if in module next nil not or redo rescue retry return self super then true undef unless until when while yield].freeze

      def isValidVariableName key
        return false unless key.match?(/^[a-zA-Z_][a-zA-Z0-9_]*$/)

        return false if RUBY_RESERVED_KEYWORDS.include? key

        true
      end
    end
  end
end
