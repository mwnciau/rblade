require "rblade/helpers/tokenizer"

module RBlade
  class CompilesStatements
    class CompilesProps
      def compileProps args
        if args.nil?
          raise StandardError.new "Props statement: wrong number of arguments (given #{args&.count}, expecting 1)"
        end

        props = extractProps args[0]
        props.map do |key, value|
          if value == "_required"
            "if !defined?(#{key})&&!attributes.has?(:'#{RBlade.escape_quotes(key)}');raise \"Props statement: #{key} is not defined\";end;#{key.sub(/[^a-zA-Z0-9_]/, "_")}=attributes.default(:'#{RBlade.escape_quotes(key)}');"
          else
            "#{key.sub(/[^a-zA-Z0-9_]/, "_")}=attributes.default(:'#{RBlade.escape_quotes(key)}',#{value});"
          end
        end.join
      end

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
              ('.+'):
              |
              (".+"):
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
    end
  end
end
