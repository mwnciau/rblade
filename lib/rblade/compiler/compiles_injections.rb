# frozen_string_literal: true

module RBlade
  class CompilesInjections
    def compile!(tokens)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        current_match_id = nil
        segments = []
        token.value.split(/
          (?<escape_unsafe_rblade>@?)\{!!(?<unsafe_rblade>(?:[^!}]++|[!}])+?)!!}
          |
          (?<escape_safe_rblade>@?) \{\{ (?<safe_rblade>(?:[^!}]++|[!}])+?) }}
          |
          \s?(?<![\w@])@ruby\s++(?<ruby>(?:[^@]++|[@])+?)(?<!\w)@end_?ruby(?!\w)\s?
          |
          (?<escaped_erb_start><%%)
          |
          (?<escaped_erb_end>%%>)
          |
          (?<erb_tag><%(?!%)=?=?)\s*+(?<erb_tag_content>(?:[^%]++|[%])+?)(?<!%)%?>
        /xi) do |before_match|
          next if current_match_id == $~.object_id
          current_match_id = $~.object_id

          unless before_match == ""
            RBlade::Utility.append_unprocessed_string_segment!(token, segments, before_match)
          end
          next if $~.nil?

          if $~[:unsafe_rblade].present? || $~[:erb_tag] == "<%=="
            if $~[:escape_unsafe_rblade] == "@"
              RBlade::Utility.append_unprocessed_string_segment!(token, segments, $&.delete_prefix("@"))
            else
              start_offset = segments.last&.end_offset || token.start_offset
              segments << create_token(
                ($~[:unsafe_rblade] || $~[:erb_tag_content]).strip,
                false,
                start_offset,
                start_offset + $&.length,
              )
            end
          elsif $~[:safe_rblade].present? || $~[:erb_tag] == "<%="
            if $~[:escape_safe_rblade] == "@"
              RBlade::Utility.append_unprocessed_string_segment!(token, segments, $&.delete_prefix("@"))
            else
              start_offset = segments.last&.end_offset || token.start_offset
              segments << create_token(
                ($~[:safe_rblade] || $~[:erb_tag_content]).strip,
                true,
                start_offset,
                start_offset + $&.length,
              )
            end
          elsif $~[:ruby].present? || $~[:erb_tag] == "<%"
            value = ($~[:ruby] || $~[:erb_tag_content]).strip
            value << ";" unless value.end_with?(";")
            start_offset = segments.last&.end_offset || token.start_offset

            segments << Token.new(
              type: :ruby,
              value: value,
              start_offset: start_offset,
              end_offset: start_offset + $&.length,
            )
          elsif $~[:escaped_erb_start].present?
            RBlade::Utility.append_unprocessed_string_segment!(token, segments, +"<%")
          elsif $~[:escaped_erb_end].present?
            RBlade::Utility.append_unprocessed_string_segment!(token, segments, +"%>")
          end
        end

        segments
      end.flatten!
    end

    private def create_token(expression, escape_html, start_offset, end_offset)
      # Don't try to print ends
      if expression.match?(/\A(?:}|end(?![[:alnum:]_]|[^\0-\177]))/i)
        return Token.new(:ruby, "#{expression};", start_offset, end_offset)
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

      Token.new(:print, segment_value, start_offset, end_offset)
    end
  end
end
