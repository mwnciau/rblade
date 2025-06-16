# frozen_string_literal: true

module RBlade
  class CompilesComments
    def compile!(tokens)
      tokens.each do |token|
        next if token.type != :unprocessed

        token.value.gsub!(/\{\{--(?:[^-]++|-)*?--}}/, "")
        token.value.gsub!(/<%#(?:[^%]++|%)*?%>/, "")
      end
    end

    def self.comment_offsets(source)
      current_match_id = nil
      offsets = []

      source.split(/(\{\{--(?:[^-]++|-)*?--}}|<%#(?:[^%]++|%)*?%>)/) do |before_match|
        next if current_match_id == $~.object_id || $&.nil?
        current_match_id = $~.object_id

        offsets << {
          source_position: (offsets.last&.[](:source_position) || 0) + before_match.length,
          offset: $&.length,
        }
      end

      offsets
    end
  end
end
