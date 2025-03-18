# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesStacks
      def compile_stack(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Stack statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "@_rblade_stack_manager.initialize_stack(#{args[0]}, @output_buffer);_stacks.push(#{args[0]});"
      end

      def compile_prepend(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Prepend statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "@_rblade_stack_manager.prepend(#{args[0]}, @output_buffer) do;"
      end

      def compile_prepend_if(args)
        if args&.count != 2
          raise RBladeTemplateError.new "Prepend if statement: wrong number of arguments (given #{args&.count}, expecting 2)"
        end

        "(#{args[0]}) && @_rblade_stack_manager.prepend(#{args[1]}, @output_buffer) do;"
      end

      def compile_push(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Push statement: wrong number of arguments (given #{args&.count}, expecting 1)"
        end

        "@_rblade_stack_manager.push(#{args[0]}, @output_buffer) do;"
      end

      def compile_push_if(args)
        if args&.count != 2
          raise RBladeTemplateError.new "Push if statement: wrong number of arguments (given #{args&.count || 0}, expecting 2)"
        end

        "(#{args[0]}) && @_rblade_stack_manager.push(#{args[1]}, @output_buffer) do;"
      end
    end
  end
end
