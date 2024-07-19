class CompilesComments
  def compile!(tokens)
    tokens.each do |token|
      next if token.type != :unprocessed

      token.value.gsub!(/\{\{--.*?--\}\}/m, "")
      token.value.gsub!(/<%#.*?%>/m, "")
    end
  end
end
