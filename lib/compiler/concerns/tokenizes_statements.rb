require "ripper"

class TokenizesStatements
  def self.tokenize!(tokens)
    tokens.map! do |token|
      next(token) if token.type != :unprocessed

      segments = token.value.split(/\B(@@?)(\w+(?:::\w+)?)(?:[ \t]*(\(.*?\)))?/m)

      parseSegments! segments
    end.flatten!
  end

  def self.parseSegments! segments
    i = 0
    while i < segments.count
      segment = segments[i]

      # The @ symbol is used to escape blade directives so we return it unprocessed
      if segment == "@@"
        segments[i] = Token.new(type: :unprocessed, value: segment[1..-1] + segments[i + 1])
        segments.delete_at i + 1

        i += 1
      elsif segment == "@"
        tokenizeStatement! segments, i

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
  private_class_method :parseSegments!

  def self.tokenizeStatement!(segments, i)
    statementData = {name: segments[i + 1]}
    segments.delete_at i + 1

    if segments.count > i + 1 && segments[i + 1][0] == "("
      arguments = tokenizeArguments! segments, i + 1

      if !arguments.nil?
        statementData[:arguments] = arguments
      end
    end

    segments[i] = Token.new(type: :statement, value: statementData)
  end
  private_class_method :tokenizeStatement!

  def self.tokenizeArguments!(segments, segmentIndex)
    success = expandSegmentToEndParenthesis! segments, segmentIndex

    # If no matching parentheses were found, so we combine the argument string with the next segment
    if !success
      if !segments[segmentIndex + 1].nil?
        segments[segmentIndex] <<= segments[segmentIndex + 1]
        segments.delete_at segmentIndex + 1
      end

      return nil
    end

    arguments = extractArguments segments[segmentIndex]
    segments.delete_at segmentIndex

    arguments
  end
  private_class_method :tokenizeArguments!

  def self.expandSegmentToEndParenthesis! segments, segmentIndex
    parenthesesDifference = 0
    tokens = nil

    loop do
      tokens = Ripper.lex(segments[segmentIndex]).map { |token| token[1] }
      parenthesesDifference = tokens.count(:on_lparen) - tokens.count(:on_rparen)

      break if parenthesesDifference.zero? || segments[segmentIndex + 1].nil?

      index = segments[segmentIndex + 1].each_char.find_index { |c| c == ")" && (parenthesesDifference -= 1).zero? }

      if index.nil?
        segments[segmentIndex] << segments[segmentIndex + 1]
        segments.delete_at segmentIndex + 1
      else
        segments[segmentIndex] << segments[segmentIndex + 1].slice!(0..index)
      end

      break if segments[segmentIndex + 1].nil?
    end

    parenthesesDifference.zero?
  end
  private_class_method :expandSegmentToEndParenthesis!

  def self.extractArguments(segment)
    # Add a comma to the end to delimit the end of the last argument
    segment = segment[1..-2] + ","
    segmentLines = segment.lines

    tokens = Ripper.lex segment
    arguments = []

    currentLine = 1
    currentIndex = 0
    tokens.each do |token|
      if token[1] == :on_comma
        argument = ""

        # Concatenate all lines up to this token's line, including the tail end of the current line
        if token[0][0] != currentLine
          for i in currentLine...token[0][0]
            argument << (segmentLines[i - 1].slice(currentIndex..-1) || "")
            currentIndex = 0
          end
          currentLine = token[0][0]
        end
        argument <<= segmentLines[currentLine - 1].slice(currentIndex...token[0][1])

        arguments.push argument.strip

        currentIndex = token[0][1] + 1
      end
    end

    return nil if arguments.count == 1 && arguments.first == ""

    arguments
  end
  private_class_method :extractArguments
end
