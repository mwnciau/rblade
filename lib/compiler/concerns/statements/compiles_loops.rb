class CompilesLoops
  def compileBreak args
    if !args.nil?
      raise StandardError.new "Break statement: wrong number of arguments (given #{args&.count}, expecting 0)"
    end

    "break;"
  end

  def compileFor args
    if args&.count != 1
      raise StandardError.new "For statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    "for #{args[0]};"
  end

  def compileNext args
    if args&.count&.> 1
      raise StandardError.new "For statement: wrong number of arguments (given #{args&.count || 0}, expecting 0 or 1)"
    end

    if args.nil?
      "next;"
    else
      "next #{args[0]};"
    end
  end

  def compileUntil args
    if args&.count != 1
      raise StandardError.new "Until statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    "until #{args[0]};"
  end

  def compileWhile args
    if args&.count != 1
      raise StandardError.new "While statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    "while #{args[0]};"
  end
end
