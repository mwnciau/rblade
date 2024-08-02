module RBlade
  class CompilesStatements
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
        if args&.count != 1
          raise StandardError.new "Prepend statement: wrong number of arguments (given #{args&.count}, expecting 1)"
        end

        @push_counter += 1

        "_p_#{@push_counter}=#{args[0]};_p_#{@push_counter}_b=_out;_out='';"
      end

      def compileEndPrepend args
        if !args.nil?
          raise StandardError.new "End prepend statement: wrong number of arguments (given #{args&.count}, expecting 0)"
        end

        @push_counter -= 1

        "RBlade::StackManager.prepend(_p_#{@push_counter + 1}, _out);_out=_p_#{@push_counter + 1}_b;"
      end

      def compilePrependIf args
        if args&.count != 2
          raise StandardError.new "Prepend if statement: wrong number of arguments (given #{args&.count}, expecting 2)"
        end

        "if #{args[0]};" + compilePrepend([args[1]])
      end

      def compileEndPrependIf args
        if !args.nil?
          raise StandardError.new "End push if statement: wrong number of arguments (given #{args&.count}, expecting 0)"
        end

        "end;" + compileEndPush(nil)
      end

      def compilePush args
        if args&.count != 1
          raise StandardError.new "Push statement: wrong number of arguments (given #{args&.count}, expecting 1)"
        end

        @push_counter += 1

        "_p_#{@push_counter}=#{args[0]};_p_#{@push_counter}_b=_out;_out='';"
      end

      def compilePushIf args
        if args&.count != 2
          raise StandardError.new "Push if statement: wrong number of arguments (given #{args&.count}, expecting 2)"
        end

        "if #{args[0]};" + compilePush([args[1]])
      end

      def compileEndPush args
        if !args.nil?
          raise StandardError.new "End push statement: wrong number of arguments (given #{args&.count}, expecting 0)"
        end

        @push_counter -= 1

        "RBlade::StackManager.push(_p_#{@push_counter + 1}, _out);_out=_p_#{@push_counter + 1}_b;"
      end

      def compileEndPushIf args
        if !args.nil?
          raise StandardError.new "End push if statement: wrong number of arguments (given #{args&.count}, expecting 0)"
        end

        "end;" + compileEndPush(nil)
      end
    end
  end
end
