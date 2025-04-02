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
  end
end
