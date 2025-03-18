# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesOnce
      def initialize
        @once_counter = 0
      end

      def compile_once(args)
        if args&.count&.> 1
          raise RBladeTemplateError.new "Once statement: wrong number of arguments (given #{args.count}, expecting 0 or 1)"
        end

        once_id = args.nil? ? ":_#{@once_counter += 1}" : args[0]

        "unless @_rblade_once_tokens.include? #{once_id};@_rblade_once_tokens<<#{once_id};"
      end

      def compile_push_once(args)
        if args&.count != 1 && args&.count != 2
          raise RBladeTemplateError.new "Push once statement: wrong number of arguments (given #{args&.count || 0}, expecting 1 or 2)"
        end
        @once_counter += 1
        once_id = args[1].nil? ? ":_#{@once_counter}" : args[1]

        "(@_rblade_once_tokens.include? #{once_id}) || @_rblade_once_tokens<<#{once_id} && @_rblade_stack_manager.push(#{args[0]}, @output_buffer) do;"
      end

      def compile_prepend_once(args)
        if args&.count != 1 && args&.count != 2
          raise RBladeTemplateError.new "Prepend once statement: wrong number of arguments (given #{args&.count || 0}, expecting 1 or 2)"
        end
        @once_counter += 1
        once_id = args[1].nil? ? ":_#{@once_counter}" : args[1]

        "(@_rblade_once_tokens.include? #{once_id}) || @_rblade_once_tokens<<#{once_id} && @_rblade_stack_manager.prepend(#{args[0]}, @output_buffer) do;"
      end
    end
  end
end
