# frozen_string_literal: true

module RBlade
  class CompilesRuby
    def compile!(tokens)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        segments = token.value.split(/
          # @ escapes blade style tags
          (@)(@ruby.+?@end_?ruby)
          |
          # <%% and %%> are escape ERB style tags
          (<%%)(.+?)(%%>)
          |
          \s?(?<!\w)(@ruby)\s+(.+?)[\s;]*(@end_?ruby)(?!\w)\s?
          |
          (<%)(?!=)\s*(.+?)[\s;]*(%>)
        /xmi)

        i = 0
        while i < segments.count
          if segments[i] == "@"
            segments.delete_at i
            segments[i] = Token.new(type: :raw_text, value: segments[i])

            i += 1
          elsif segments[i] == "<%%"
            segments.delete_at i
            segments.delete_at i + 1
            segments[i] = Token.new(type: :raw_text, value: "<%#{segments[i]}%>")

            i += 1
          elsif segments[i].downcase == "@ruby" || segments[i] == "<%"
            segments.delete_at i
            segments.delete_at i + 1

            segments[i].strip!
            if segments[i][-1] != ";"
              segments[i] << ";"
            end

            # Ensure _out is returned at the end of any blocks
            # See also ./compiles_prints.rb
            if segments[i].match(/^end(?![a-zA-Z0-9_])/i)
              segments[i] =  Token.new(type: :ruby, value: "_out;#{segments[i]}")
            else
              segments[i] = Token.new(type: :ruby, value: segments[i])
            end

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
