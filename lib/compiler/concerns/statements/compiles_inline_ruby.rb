class CompilesInlineRuby
  def compile args
    if args&.count != 1
      raise Exception.new "Ruby statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    arg = args[0].strip
    if arg[-1] != ";"
      arg << ";"
    end
    arg
  end
end
