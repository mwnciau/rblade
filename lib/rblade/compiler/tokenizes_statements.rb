# frozen_string_literal: true

require "rblade/helpers/tokenizer"
require "ripper"

module RBlade
  class TokenizesStatements
    def tokenize!(tokens)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        segments = token.value.split(/
          (\s)?(?<!\w)
          (?:
            (?:
              (@@)
              (\w++[!\?]?)
            )
            |
            (?:
              (@)
              (\w++[!\?]?)
              (?:([ \t]*+)
                (\([^)]*+\))
              )?
            )
          )
          (\s)?
        /x)

        parse_segments! segments
      end.flatten!
    end

    private

    def parse_segments!(segments)
      i = 0
      while i < segments.count
        segment = segments[i]

        # The @ symbol is used to escape blade directives so we return it unprocessed
        if segment == "@@"
          segments[i] = Token.new(type: :unprocessed, value: segment[1..] + segments[i + 1])
          segments.delete_at i + 1

          i += 1
        elsif segment == "@"
          if CompilesStatements.has_handler(segments[i + 1])
            tokenize_statement! segments, i
            handle_special_cases! segments, i

            segments.delete_at(i + 1) if segments[i + 1]&.match?(/\A\s\z/)
            if segments[i - 1].is_a?(Token) && segments[i - 1].type == :unprocessed && segments[i - 1].value.match?(/\A\s\z/)
              segments.delete_at i - 1
              i -= 1
            end
          else
            # For unhandled statements, restore the original string
            segments[i] = Token.new(type: :unprocessed, value: segments[i] + segments[i + 1])
            segments.delete_at i + 1

            if segments.count > i + 2 && segments[i + 1].match?(/\A[ \t]*+\z/) && segments[i + 2][0] == "("
              segments[i].value += segments[i + 1] + segments[i + 2]
              segments.delete_at i + 1
              segments.delete_at i + 1
            elsif segments.count > i + 1 && segments[i + 1][0] == "("
              segments[i].value += segments[i + 1]
              segments.delete_at i + 1
            end
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

    def tokenize_statement!(segments, i)
      statement_data = {name: segments[i + 1]}
      statement_name = segments.delete_at i + 1

      # Remove optional whitespace
      if segments.count > i + 2 && segments[i + 1].match?(/\A[ \t]*+\z/) && segments[i + 2][0] == "("
        segments.delete_at i + 1
      end

      if segments.count > i + 1 && segments[i + 1][0] == "("
        arguments = tokenize_arguments! statement_name, segments, i + 1

        unless arguments.nil?
          statement_data[:arguments] = arguments
        end
      end

      segments[i] = Token.new(type: :statement, value: statement_data)
    end

    def handle_special_cases!(segments, i)
      if segments[i][:value][:name] == "case"
        # Remove any whitespace before a when statement
        until segments[i + 1].nil? || segments[i + 1] == "@"
          segments.delete_at i + 1
        end
      end
    end

    def tokenize_arguments!(statement_name, segments, segment_index)
      success = expand_segment_to_end_parenthesis! segments, segment_index

      # If no matching parentheses were found, so we combine the argument string with the next segment
      unless success
        unless segments[segment_index + 1].nil?
          segments[segment_index] <<= segments[segment_index + 1]
          segments.delete_at segment_index + 1
        end

        return nil
      end

      # Remove the parentheses from the argument string
      argument_string = segments[segment_index][1..-2]

      # Special case for the props statement: remove the wrapping braces if they exist
      if statement_name == "props"
        if argument_string.start_with?("{") && argument_string.end_with?("}")
          argument_string = argument_string[1..-2]
        end
      end

      arguments = Tokenizer.extractCommaSeparatedValues argument_string
      segments.delete_at segment_index

      arguments
    end

    def expand_segment_to_end_parenthesis!(segments, segment_index)
      parentheses_difference = 0

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
  end
end
