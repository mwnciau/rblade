module CompilesEchos
  def self.compile_echos!(tokens)
    tokens.map! do |token|
      next(token) if token.type != :unprocessed

      segments = token.value.split /(\{\{)(.+)(\}\})/
      i = 0
      while i < segments.count do
        if segments[i] == '{{'
          segments.delete_at i
          segments.delete_at i + 1

          segmentValue = "_out.<<h(".<< segments[i].<< ");"
          segments[i] = Token.new(:echo, segmentValue)

          i += 1
        elsif segments[i] != nil && segments[i] != ""
          segments[i] = Token.new(type: :unprocessed, value: segments[i])

          i += 1
        else
          segments.delete_at i
        end
      end

      segments
    end.flatten!
  end
end
