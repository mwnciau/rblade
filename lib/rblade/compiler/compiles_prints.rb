module RBlade
  class CompilesPrints
    def compile!(tokens)
      compile_unsafe_prints!(tokens)
      compile_regular_prints!(tokens)
    end

    private

    def compile_regular_prints!(tokens)
      compile_prints! tokens, "{{", "}}", "RBlade.e"
      compile_prints! tokens, "<%=", "%>", "RBlade.e"
    end

    def compile_unsafe_prints!(tokens)
      compile_prints! tokens, "{!!", "!!}"
      compile_prints! tokens, "<%==", "%>"
    end

    def compile_prints!(tokens, start_token, end_token, wrapper_function = nil)
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
            segment_value = "_out<<"

            segment_value <<= if !wrapper_function.nil?
              wrapper_function + "(" + segments[i] + ");"
            else
              "(" + segments[i] + ").to_s;"
            end
            segments[i] = Token.new(:print, segment_value)

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
  end
end
