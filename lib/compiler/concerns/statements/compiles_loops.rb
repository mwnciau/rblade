class CompilesLoops
  def compileBreak args
    if !args.nil?
      raise StandardError.new "Break statement: wrong number of arguments (given #{args&.count}, expecting 0)"
    end

    "break;"
  end

  def compileBreakIf args
    if args&.count != 1
      raise StandardError.new "Break statement: wrong number of arguments (given #{args&.count}, expecting 1)"
    end

    "if #{args[0]};break;end;"
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

  def compileNextIf args
    if args.nil? || args.count > 2
      raise StandardError.new "For statement: wrong number of arguments (given #{args&.count || 0}, expecting 1 or 2)"
    end

    if args.count == 1
      "if #{args[0]};next;end;"
    else
      "if #{args[0]};next #{args[1]};end;"
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
