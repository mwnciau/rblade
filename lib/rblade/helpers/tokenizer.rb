module RBlade
  class Tokenizer
    def self.extractCommaSeparatedValues segment
      unless segment.match /,\s*\z/
        # Add a comma to the end to delimit the end of the last argument
        segment += ","
      end
      segment_lines = segment.lines

      tokens = Ripper.lex segment
      arguments = []

      current_line = 1
      current_index = 0
      bracket_count = {
        "[]": 0,
        "{}": 0,
        "()": 0
      }
      tokens.each do |token|
        case token[1]
        when :on_lbracket
          bracket_count[:[]] += 1
        when :on_rbracket
          bracket_count[:[]] -= 1
        when :on_lbrace
          bracket_count[:"{}"] += 1
        when :on_rbrace
          bracket_count[:"{}"] -= 1
        when :on_lparen
          bracket_count[:"()"] += 1
        when :on_rparen
          bracket_count[:"()"] -= 1
        when :on_comma
          if bracket_count[:[]] != 0 || bracket_count[:"{}"] != 0 || bracket_count[:"()"] != 0
            next
          end

          argument = ""

          # Concatenate all lines up to this token's line, including the tail end of the current line
          if token[0][0] != current_line
            (current_line...token[0][0]).each do |i|
              argument << (segment_lines[i - 1].slice(current_index..-1) || "")
              current_index = 0
            end
            current_line = token[0][0]
          end
          argument <<= segment_lines[current_line - 1].slice(current_index...token[0][1])
          argument.strip!

          arguments.push argument

          current_index = token[0][1] + 1
        end
      end

      return nil if arguments.count == 1 && arguments.first == ""

      arguments
    end
  end
end