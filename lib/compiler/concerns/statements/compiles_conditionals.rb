class CompilesConditionals
  def self.compileIf args
    if args == nil || args.count != 1
      raise Exception.new "If statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    return "if(#{args[0]});"
  end
end
