class CompilesRuby
  def self.compileRuby! args, tokens, token_index
    if !args.nil?
      return compileInlineRuby(args)
    end

    return compileBlockRuby!(tokens, token_index)
  end

  def self.compileInlineRuby args
    args.map do |arg|
      arg.strip!
      if arg[-1] != ";"
        arg << ";"
      end
      arg
    end.join
  end
  private_class_method :compileInlineRuby

  def self.compileBlockRuby! tokens, token_index
    code = ''
    token_index += 1

    while !tokens[token_index].nil?
      if tokens[token_index].type == :statement && tokens[token_index].value[:name] == 'endruby'
        tokens.delete_at token_index
        return code
      end

      code << tokens[token_index].value
      tokens.delete_at token_index
    end

    throw Exception "Unmatched @ruby statement: expecting @endruby"
  end
  private_class_method :compileInlineRuby
end
