class TokenizesStatements
  def self.tokenize!(tokens)
    tokens.map! do |token|
      next(token) if token.type != :unprocessed

      segments = token.value.split /\B(@@?)(\w+(?:::\w+)?)(?:[ \t]*(\(.*?\)))?/m
      segments_orig = segments.map(&:clone)
      i = 0
      while i < segments.count do
        segment = segments[i]
        if segment == "@@"
          segments[i] = Token.new(type: :unprocessed, value: segment << segments[i + 1])
          segments.delete_at i + 1

          i += 1
        elsif segment == "@"
          statementData = {statement: segments[i+1]}
          segments.delete_at i + 1

          if i + 1 < segments.count && segments[i + 1][0] == "("
            arguments = segments[i + 1]

            statementData[:arguments] = arguments
            segments.delete_at i + 1
          end

          segments[i] = Token.new(type: :statement, value: statementData)

          i += 1
        elsif segments[i] != nil && segments[i] != ""
          segments[i] = Token.new(type: :unprocessed, value: segments[i])

          i += 1
        else
          segments.delete_at i
        end
      end
      #dd segments_orig, segments
      segments
    end.flatten!
  end


end
