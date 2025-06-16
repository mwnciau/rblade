class StringUtility
  class << self
    def lines(string)
      lines = string.split(/(?<=\n)/, -1)
      lines = [""] if lines.length == 0

      lines
    end
  end
end
