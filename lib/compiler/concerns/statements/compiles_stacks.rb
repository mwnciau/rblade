class CompilesStacks
  def initialize
    @push_counter = 0
  end

  def compileStack args
    if args&.count != 1
      raise StandardError.new "Stack statement: wrong number of arguments (given #{args&.count}, expecting 1)"
    end

    "RBlade::StackManager.initialize(#{args[0]}, _out);_stacks.push(#{args[0]});_out = '';"
  end

  def compilePrepend args
    if args.nil? || args.count > 2
      raise StandardError.new "Prepend statement: wrong number of arguments (given #{args&.count}, expecting 1 or 2)"
    end

    if args.count == 2
      "RBlade::StackManager.prepend(#{args[0]}, #{args[1]});"
    else
      @push_counter += 1

      "_push_#{@push_counter}_name=#{args[0]};_push_#{@push_counter}_buffer=_out;_out='';"
    end
  end

  def compileEndPrepend args
    if !args.nil?
      raise StandardError.new "End prepend statement: wrong number of arguments (given #{args&.count}, expecting 0)"
    end

    @push_counter -= 1

    "RBlade::StackManager.prepend(_push_#{@push_counter + 1}_name, _out);_out=_push_#{@push_counter + 1}_buffer;"
  end

  def compilePush args
    if args.nil? || args.count > 2
      raise StandardError.new "Push statement: wrong number of arguments (given #{args&.count}, expecting 1 or 2)"
    end

    if args.count == 2
      "RBlade::StackManager.push(#{args[0]}, #{args[1]});"
    else
      @push_counter += 1

      "_push_#{@push_counter}_name=#{args[0]};_push_#{@push_counter}_buffer=_out;_out='';"
    end
  end

  def compileEndPush args
    if !args.nil?
      raise StandardError.new "End push statement: wrong number of arguments (given #{args&.count}, expecting 0)"
    end

    @push_counter -= 1

    "RBlade::StackManager.push(_push_#{@push_counter + 1}_name, _out);_out=_push_#{@push_counter + 1}_buffer;"
  end
end