class CompilesRuby
  def compile!(tokens)
    tokens.map! do |token|
      next(token) if token.type != :unprocessed

      segments = token.value.split(/
        # @ escapes blade style tags
        (@)(@ruby.+?@endruby)
        |
        # <%% and %%> are escape ERB style tags
        (<%%)(.+?)(%%>)
        |
        (?:^|[\b\s])(@ruby)\s+(.+?)[\s;]*(@endruby)(?:$|[\b\s])
        |
        (<%)\s+(.+?)[\s;]*(%>)
      /xm)

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
        elsif segments[i] == "@ruby" || segments[i] == "<%"
          segments.delete_at i
          segments.delete_at i + 1

          segments[i].strip!
          if segments[i][-1] != ";"
            segments[i] << ";"
          end

          segments[i] = Token.new(type: :php, value: segments[i])

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
