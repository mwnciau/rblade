# frozen_string_literal: true

require "rblade/helpers/regular_expressions"
require "rblade/helpers/tokenizer"
require "ripper"

module RBlade
  class TokenizesStatements
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
            arguments = tokenize_arguments! statement_handle, $~[:statement_arguments]

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

    def tokenize_arguments!(statement_handle, arguments)
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
  end
end
