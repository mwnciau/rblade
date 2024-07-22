module RBlade
  class CompilesEchos
    def compile!(tokens)
      compile_regular_echos!(tokens)
      compile_unsafe_echos!(tokens)
    end

    private

    def compile_regular_echos!(tokens)
      compile_echos! tokens, "{{", "}}", "h"
      compile_echos! tokens, "<%=", "%>", "h"
    end

    def compile_unsafe_echos!(tokens)
      compile_echos! tokens, "{!!", "!!}"
    end

    def compile_echos!(tokens, start_token, end_token, wrapper_function = nil)
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
            # Special case for slot - we want this to be able to output HTML
            if !wrapper_function.nil? && segments[i] != "slot"
              segment_value <<= wrapper_function
            end
            segment_value <<= "(" + segments[i] + ");"
            segments[i] = Token.new(:echo, segment_value)

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
