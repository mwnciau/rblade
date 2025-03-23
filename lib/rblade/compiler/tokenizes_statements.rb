# frozen_string_literal: true

require "rblade/helpers/regular_expressions"
require "rblade/helpers/tokenizer"
require "ripper"

module RBlade
  class TokenizesStatements
    def tokenize_old!(tokens)
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

    def tokenize!(tokens)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        current_match_id = nil
        segments = []
        token.value.split(/
          \s?(?<!\w|@)
          (?:
            (?:
              (?<escaped_at>@@)
              (?=\w++[!\?]?(?!\w))
            )
            |
            (?:
              @
              (?# Statement name )
              (?<statement_name>\w++[!\?]?)
              (?# Optional parameters )
              (?:
                [ \t]*+
                (?# Matched parentheses )
                (?<statement_arguments>
                  \(
                    (?:
                      [^()#{RegularExpressions::RUBY_STRING_CHARACTERS}]++
                      |
                      #{RegularExpressions::RUBY_STRING}
                      |
                      \g<statement_arguments>
                    )*+
                  \)
                )
              )?
            )
          )
          \s?
        /xo) do |before_match|
          next if current_match_id == $~.object_id
          current_match_id = $~.object_id# unless $~.nil?

          # Add the current string to the segment list
          unless before_match == ""
            # Skip output between case and when statements
            unless segments.last&.type == :statement && segments.last&.value&.[](:name) == 'case'
              if segments.last && segments.last.type == :unprocessed
                segments.last.value << before_match
              else
                segments << Token.new(type: :unprocessed, value: before_match)
              end
            end
          end
          next if $~.nil?

          # Skip escaped statements
          if $~&.[](:escaped_at) == "@@"
            segment = $&
            # Remove the first or second @, depending on whether there is whitespace
            segment.slice!(1).inspect
            if segments.last && segments.last.type == :unprocessed
              segments.last.value << segment
            else
              segments << Token.new(type: :unprocessed, value: segment)
            end

            next
          end

          statement_handle = $~[:statement_name].downcase.tr("_", "")
          unless CompilesStatements.has_handler(statement_handle)
            if segments.last && segments.last.type == :unprocessed
              segments.last.value << $&
            else
              segments << Token.new(type: :unprocessed, value: $&)
            end

            next
          end

          statement_data = {name: statement_handle}

          unless $~[:statement_arguments].blank?
            arguments = tokenize_arguments_new! statement_handle, $~[:statement_arguments]

            unless arguments.nil?
              statement_data[:arguments] = arguments
            end

          end

          segments << Token.new(type: :statement, value: statement_data)
        end

        segments
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
          statement_handle = segments[i + 1].downcase.tr "_", ""
          if CompilesStatements.has_handler(statement_handle)
            tokenize_statement! statement_handle, segments, i
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

    def tokenize_statement!(handle, segments, i)
      segments.delete_at i + 1
      statement_data = {name: handle}

      # Remove optional whitespace
      if segments.count > i + 2 && segments[i + 1].match?(/\A[ \t]*+\z/) && segments[i + 2][0] == "("
        segments.delete_at i + 1
      end

      if segments.count > i + 1 && segments[i + 1][0] == "("
        arguments = tokenize_arguments! handle, segments, i + 1

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

    def tokenize_arguments_new!(statement_handle, arguments)
      # Remove the parentheses from the argument string
      arguments = arguments[1..-2]

      # Special case for the props statement: remove the wrapping braces if they exist
      if statement_handle == "props"
        if arguments.start_with?("{") && arguments.end_with?("}")
          arguments = arguments[1..-2]
        end
      end

      Tokenizer.extract_comma_separated_values arguments
    end

    def tokenize_arguments!(statement_handle, segments, segment_index)
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
      if statement_handle == "props"
        if argument_string.start_with?("{") && argument_string.end_with?("}")
          argument_string = argument_string[1..-2]
        end
      end

      arguments = Tokenizer.extract_comma_separated_values argument_string
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
