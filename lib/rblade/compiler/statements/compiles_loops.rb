module RBlade
  class CompilesStatements
    class CompilesLoops
      def initialize
        @loop_else_counter = 0
      end

      def compileBreak args
        if args&.count&.> 1
          raise StandardError.new "Break statement: wrong number of arguments (given #{args.count}, expecting 0 or 1)"
        end

        if args.nil?
          "break;"
        else
          "if #{args[0]};break;end;"
        end
      end

      def compileEach args
        if args.nil? || args.count > 2
          raise StandardError.new "Each statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end
        # Allow variables to be a key, value pair
        args = args.join ","

        variables, collection = args.split(" in ")

        "#{collection}.each do |#{variables}|;"
      end

      def compileEachElse args
        if args.nil? || args.count > 2
          raise StandardError.new "Each else statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end
        # Allow variables to be a key, value pair
        args = args.join ","
        @loop_else_counter += 1

        variables, collection = args.split(" in ")

        "_looped_#{@loop_else_counter}=false;#{collection}.each do |#{variables}|;_looped_#{@loop_else_counter}=true;"
      end

      def compileFor args
        if args&.count != 1
          raise StandardError.new "For statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "for #{args[0]};"
      end

      def compileForElse args
        if args&.count != 1
          raise StandardError.new "For else statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end
        @loop_else_counter += 1

        "_looped_#{@loop_else_counter}=false;for #{args[0]};_looped_#{@loop_else_counter}=true;"
      end

      def compileEmpty args
        unless args.nil?
          raise StandardError.new "Empty statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        @loop_else_counter -= 1

        "end;if !_looped_#{@loop_else_counter + 1};"
      end

      def compileNext args
        if args&.count&.> 1
          raise StandardError.new "Next statement: wrong number of arguments (given #{args.count}, expecting 0 or 1)"
        end

        if args.nil?
          "next;"
        else
          "if #{args[0]};next;end;"
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
  end
end
