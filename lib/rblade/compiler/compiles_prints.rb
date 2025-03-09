# frozen_string_literal: true

module RBlade
  class CompilesPrints
    def compile!(tokens)
      compile_unsafe_prints!(tokens)
      compile_regular_prints!(tokens)
    end

    private

    def compile_regular_prints!(tokens)
      compile_prints! tokens, "{{", "}}", true
      compile_prints! tokens, "<%=", "%>", true
    end

    def compile_unsafe_prints!(tokens)
      compile_prints! tokens, "{!!", "!!}"
      compile_prints! tokens, "<%==", "%>"
    end

    def compile_prints!(tokens, start_token, end_token, escape_html = false)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        start_token_escaped = Regexp.escape start_token
        end_token_escaped = Regexp.escape end_token
        segments = token.value.split(/(?:(@)(#{start_token_escaped}.+?#{end_token_escaped})|(#{start_token_escaped})\s*(.+?)\s*(#{end_token_escaped}))/m)

        i = 0
        while i < segments.count
          if segments[i] == "@"
            segments.delete_at i
            segments[i] = Token.new(type: :raw_text, value: segments[i])

            i += 1
          elsif segments[i] == start_token
            segments.delete_at i
            segments.delete_at i + 1

            segments[i] = create_token(segments[i], escape_html)

            i += 1
          elsif !segments[i].nil? && segments[i] != ""
            segments[i] = Token.new(type: :unprocessed, value: segments[i])

            i += 1
          else
            segments.delete_at i
          end
        end

        segments
      end.flatten!
    end

    def create_token(expression, escape_html)
      # Don't try to print ends
      if expression.match?(/\A\s*(?:\}|end(?![:alnum:]_]|[^\0-\177]))/i)
        return Token.new(:print, "#{expression};")
      end

      segment_value = if escape_html
        "@output_buffer.append=#{expression};"
      # If this is a block, don't wrap in parentheses
      elsif expression.match?(/
        (?:\{|do)\s*
        (
          \|\s*
          [a-zA-Z0-9_]+\s*
          (,\s*[a-zA-Z0-9_]+)?\s*
          \|\s*
        )?
        \Z/x)
        "@output_buffer.safe_expr_append=#{expression};"
      else
        "@output_buffer.raw_buffer<<(#{expression}).to_s;"
      end

      Token.new(:print, segment_value)
    end
  end
end
