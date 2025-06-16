module RBlade
  class SourceMap
    def initialize(template)
      @source_tokens = []
      @compiled_column = 0
      @compiled_offset = 0

      calculate_comment_offsets(template)
    end

    private def calculate_comment_offsets(template)
      template_without_verbatim = CompilesVerbatim.nullify_verbatim(template)

      @comment_offsets = CompilesComments.comment_offsets(template_without_verbatim)
      @current_comment_offset = 0
    end

    def add(start_offset, end_offset, compiled_code)
      increment_comment_offset_to start_offset
      start_offset += @current_comment_offset

      # Prevent extending the end offset into a comment
      increment_comment_offset_to end_offset - 1
      end_offset += @current_comment_offset

      lines = StringUtility.lines(compiled_code)

      @source_tokens << {
        start_offset: start_offset,
        end_offset: end_offset,
        compiled_start_line: @compiled_column,
        compiled_start_offset: @compiled_offset,
      }

      @compiled_column += lines.length - 1
      @compiled_offset = (lines.length == 1) ? @compiled_offset + compiled_code.length : lines.last.length
    end

    private def increment_comment_offset_to(source_position)
      while @comment_offsets.any? && @comment_offsets.first[:source_position] <= source_position
        @current_comment_offset += @comment_offsets.shift[:offset]
      end
    end

    def source_location(first_lineno, first_column)
      previous_token = nil

      @source_tokens.each do |token|
        break previous_token if token[:compiled_start_line] > first_lineno ||
          (token[:compiled_start_line] == first_lineno && token[:compiled_start_offset] > first_column)

        previous_token = token
      end

      previous_token
    end
  end
end
