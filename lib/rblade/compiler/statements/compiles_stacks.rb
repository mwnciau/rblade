# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesStacks
      def compileStack args
        if args&.count != 1
          raise RBladeTemplateError.new "Stack statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "RBlade::StackManager.initialize(#{args[0]}, @output_buffer);_stacks.push(#{args[0]});"
      end

      def compilePrepend args
        if args&.count != 1
          raise RBladeTemplateError.new "Prepend statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "RBlade::StackManager.prepend(#{args[0]}, @output_buffer) do;"
      end

      def compilePrependIf args
        if args&.count != 2
          raise RBladeTemplateError.new "Prepend if statement: wrong number of arguments (given #{args&.count}, expecting 2)"
        end

        "(#{args[0]}) && RBlade::StackManager.prepend(#{args[1]}, @output_buffer) do;"
      end

      def compilePush args
        if args&.count != 1
          raise RBladeTemplateError.new "Push statement: wrong number of arguments (given #{args&.count}, expecting 1)"
        end

        "RBlade::StackManager.push(#{args[0]}, @output_buffer) do;"
      end

      def compilePushIf args
        if args&.count != 2
          raise RBladeTemplateError.new "Push if statement: wrong number of arguments (given #{args&.count || 0}, expecting 2)"
        end

        "(#{args[0]}) && RBlade::StackManager.push(#{args[1]}, @output_buffer) do;"
      end
    end
  end
end
