class CompilesEchos
  def self.compile!(tokens)
    self.compile_regular_echos!(tokens)
    self.compile_unsafe_echos!(tokens)
  end

  def self.compile_regular_echos!(tokens)
    self.compile_echos! tokens, "{{", "}}", "h"
  end
  private_class_method :compile_regular_echos!

  def self.compile_unsafe_echos!(tokens)
    self.compile_echos! tokens, "{!!", "!!}"
  end
  private_class_method :compile_unsafe_echos!

  def self.compile_echos!(tokens, start_token, end_token, wrapper_function = nil)
    tokens.map! do |token|
      next(token) if token.type != :unprocessed

      start_token_escaped = Regexp.escape start_token
      end_token_escaped = Regexp.escape end_token
      segments = token.value.split /(?:(@)(#{start_token_escaped}.+?#{end_token_escaped})?|(#{start_token_escaped})\s*(.+?)\s*(#{end_token_escaped}))/m

      i = 0
      while i < segments.count do
        if segments[i] == '@'
          segments.delete_at i
          segments[i] = Token.new(type: :raw_text, value: segments[i])

          i += 1
        elsif segments[i] == start_token
          segments.delete_at i
          segments.delete_at i + 1
          segmentValue = "_out<<"
          if wrapper_function != nil
            segmentValue <<= wrapper_function
          end
          segmentValue <<= "(" + segments[i] + ");"
          segments[i] = Token.new(:echo, segmentValue)

          i += 1
        elsif segments[i] != nil && segments[i] != ""
          segments[i] = Token.new(type: :unprocessed, value: segments[i])

          i += 1
        else
          segments.delete_at i
        end
      end

      segments
    end.flatten!
  end
  private_class_method :compile_echos!
end
