# frozen_string_literal: true

module RBlade
  class CompilesVerbatim
    def compile!(tokens)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        segments = token.value.split(/\s?(?<!\w)(@verbatim)(?!\w)\s?(.+?)\s?(?<!\w)@end_?verbatim(?!\w)\s?/mi)

        i = 0
        while i < segments.count
          if segments[i] == "@verbatim"
            segments.delete_at i
            segments[i] = Token.new(type: :raw_text, value: segments[i])

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
