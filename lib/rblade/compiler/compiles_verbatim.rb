# frozen_string_literal: true

module RBlade
  class CompilesVerbatim
    def compile!(tokens)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        current_match_id = nil
        segments = []
        token.value.split(/\s?(?<!\w)@verbatim(?!\w)\s?(?<contents>(?:[^@\s]++|[@\s])+?)\s?(?<!\w)@end_?verbatim(?!\w)\s?/i) do |before_match|
          next if current_match_id == $~.object_id
          current_match_id = $~.object_id

          # Add the current string to the segment list
          unless before_match == ""
            if segments.last&.type == :unprocessed
              segments.last.value << before_match
              segments.last.end_offset += before_match.length
            else
              start_offset = segments.last&.end_offset || token.start_offset
              segments << Token.new(
                type: :unprocessed,
                value: before_match,
                start_offset: start_offset,
                end_offset: start_offset + before_match.length,
              )
            end
          end
          next if $~.nil?

          if $~[:contents].present?
            start_offset = segments.last&.end_offset || token.start_offset
            segments << Token.new(
              type: :raw_text,
              value: $~[:contents],
              start_offset: start_offset,
              end_offset: start_offset + $&.length,
            )
          end
        end

        segments
      end.flatten!
    end
  end
end
