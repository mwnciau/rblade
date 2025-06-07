module RBlade
  class Utility
    def self.append_unprocessed_string_segment!(token, segments, string)
      if segments.last&.type == :unprocessed
        segments.last.value << string
        segments.last.end_offset += string.length
      else
        start_offset = segments.last&.end_offset || token.start_offset
        segments << Token.new(
          type: :unprocessed,
          value: string,
          start_offset: start_offset,
          end_offset: start_offset + string.length,
        )
      end
    end
  end
end
