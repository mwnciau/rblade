# frozen_string_literal: true

module RBlade
  class CompilesInjections
    def compile!(tokens)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        segments = token.value.split(/
          (@?\{!!)(\s*+(?:[^!}%@]++|[!}%@])+?\s*+)(!!})
          |
          (@?\{\{)(\s*+(?:[^!}%@]++|[!}%@])+?\s*+)(}})
          |
          (\s?(?<!\w)@?@ruby)(\s++(?:[^!}%@]++|[!}%@])+?\s*+)((?<!\w)@end_?ruby(?!\w)\s?)
          |
          (<%%?=?=?)(\s*+(?:[^!}%@]++|[!}%@])+?\s*+)(%%?>)
        /xi)

        i = 0
        while i < segments.count
          case segments[i]
          when "{{", "<%="
            segments[i] = create_token(segments[i + 1].strip, true)
          when "<%", /\A\s?@ruby\z/i
            segments[i + 1].strip!
            segments[i + 1] << ";" unless segments[i + 1].end_with?(";")
            segments[i] = Token.new(type: :ruby, value: segments[i + 1])
          when "{!!", "<%=="
            segments[i] = create_token(segments[i + 1].strip, false)
          when "@{!!", "@{{", /\A\s?@@ruby\z/i
            segments[i].sub!("@", "")
            segments[i] = Token.new(type: :raw_text, value: "#{segments[i]}#{segments[i + 1]}#{segments[i + 2]}")
          when "<%%", "<%%=", "<%%=="
            segments[i] = Token.new(type: :raw_text, value: "<#{segments[i].delete_prefix!("<%")}#{segments[i + 1]}%>")
          when "", nil
            segments.delete_at i
            next
          else
            segments[i] = Token.new(type: :unprocessed, value: segments[i])
            i += 1
            next
          end

          segments.delete_at i + 1
          segments.delete_at i + 1
          i += 1
        end

        segments
      end.flatten!
    end

    private

    def create_token(expression, escape_html)
      # Don't try to print ends
      if expression.match?(/\A(?:}|end(?![[:alnum:]_]|[^\0-\177]))/i)
        return Token.new(:ruby, "#{expression};")
      end

      segment_value = if escape_html
        "@output_buffer.append=#{expression};"
      # If this is a block, don't wrap in parentheses
      elsif expression.match?(/
        (?:\{|do)\s*+
        (
          \|\s*+
          [a-zA-Z0-9_]++\s*+
          (,\s*+[a-zA-Z0-9_]++)?\s*+
          \|
        )?
        \z/x)
        "@output_buffer.safe_expr_append=#{expression};"
      else
        "@output_buffer.raw_buffer<<(#{expression}).to_s;"
      end

      Token.new(:print, segment_value)
    end
  end
end
