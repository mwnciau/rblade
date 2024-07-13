class CompilesComments
  def self.compile!(tokens)
    tokens.each do |token|
      next(token) if token.type != :unprocessed

      token.value.gsub!(/\{\{--.*?--\}\}/m, "")
    end
  end
end
