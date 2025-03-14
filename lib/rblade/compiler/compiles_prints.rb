# frozen_string_literal: true

module RBlade
  class CompilesPrints
    def compile!(tokens)
      compile_unsafe_prints!(tokens)
      compile_regular_prints!(tokens)
    end

    private

    def compile_unsafe_prints!(tokens)
      compile_prints! tokens, /\A(@?)\{!!\z/, /(@?\{!!)(\s*+(?:[^!]++|!)+?\s*+)(!!})/
      compile_prints! tokens, /\A<%(%?)==\z/, /(<%%?==)(\s*+(?:[^%]++|%)+?\s*+)(%>)/
    end

    def compile_regular_prints!(tokens)
      compile_prints! tokens, /\A(@?)\{\{\z/, /(@?\{\{)(\s*+(?:[^}]++|})+?\s*+)(}})/, true
      compile_prints! tokens, /\A<%(%?)=\z/, /(<%%?=)(\s*+(?:[^%]++|%)+?\s*+)(%>)/, true
    end

    def compile_prints!(tokens, start_token, regex, escape_html = false)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        segments = token.value.split(regex)

        i = 0
        while i < segments.count
          if segments[i].match start_token
            if $1 != ""
              segments[i] = Token.new(type: :raw_text, value: "#{segments[i].sub($1, "")}#{segments[i + 1]}#{segments[i + 2]}")
            else
              segments[i] = create_token(segments[i + 1].strip, escape_html)
            end

            segments.delete_at i + 1
            segments.delete_at i + 1

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
      if expression.match?(/\A(?:}|end(?![[:alnum:]_]|[^\0-\177]))/i)
        return Token.new(:print, "#{expression};")
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
