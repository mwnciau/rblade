require "ripper"

module RBlade
  class TokenizesStatements
    def tokenize!(tokens)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        segments = token.value.split(/
          (?:^|[\b\s])
          (@@?)
          (\w+(?:::\w+)?)
          (?:[ \t]*
            (\(.*?\))
          )?/mx)

        parseSegments! segments
      end.flatten!
    end

    private

    def parseSegments! segments
      i = 0
      while i < segments.count
        segment = segments[i]

        # The @ symbol is used to escape blade directives so we return it unprocessed
        if segment == "@@"
          segments[i] = Token.new(type: :unprocessed, value: segment[1..] + segments[i + 1])
          segments.delete_at i + 1

          i += 1
        elsif segment == "@"
          tokenizeStatement! segments, i

          # Remove trailing whitespace if it exists, but don't double dip when another statement follows
          if !segments[i + 1].nil? && segments[i + 1].match(/^\s/) && (segments[i + 1].length > 1 || segments[i + 2].nil?)
            segments[i + 1].slice! 0, 1
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
    end

    def tokenizeStatement!(segments, i)
      statement_data = {name: segments[i + 1]}
      segments.delete_at i + 1

      if segments.count > i + 1 && segments[i + 1][0] == "("
        arguments = tokenizeArguments! segments, i + 1

        if !arguments.nil?
          statement_data[:arguments] = arguments
        end
      end

      segments[i] = Token.new(type: :statement, value: statement_data)
    end

    def tokenizeArguments!(segments, segment_index)
      success = expandSegmentToEndParenthesis! segments, segment_index

      # If no matching parentheses were found, so we combine the argument string with the next segment
      if !success
        if !segments[segment_index + 1].nil?
          segments[segment_index] <<= segments[segment_index + 1]
          segments.delete_at segment_index + 1
        end

        return nil
      end

      arguments = extractArguments segments[segment_index]
      segments.delete_at segment_index

      arguments
    end

    def expandSegmentToEndParenthesis! segments, segment_index
      parentheses_difference = 0
      tokens = nil

      loop do
        tokens = Ripper.lex(segments[segment_index]).map { |token| token[1] }
        parentheses_difference = tokens.count(:on_lparen) - tokens.count(:on_rparen)

        break if parentheses_difference.zero? || segments[segment_index + 1].nil?

        index = segments[segment_index + 1].each_char.find_index { |c| c == ")" && (parentheses_difference -= 1).zero? }

        if index.nil?
          segments[segment_index] << segments[segment_index + 1]
          segments.delete_at segment_index + 1
        else
          segments[segment_index] << segments[segment_index + 1].slice!(0..index)
        end

        break if segments[segment_index + 1].nil?
      end

      parentheses_difference.zero?
    end

    def extractArguments(segment)
      # Add a comma to the end to delimit the end of the last argument
      segment = segment[1..-2] + ","
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

          arguments.push argument.strip

          current_index = token[0][1] + 1
        end
      end

      return nil if arguments.count == 1 && arguments.first == ""

      arguments
    end
  end
end
