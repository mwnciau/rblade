# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesOnce
      def initialize
        @once_counter = 0
      end

      def compileOnce args
        if args&.count&.> 1
          raise StandardError.new "Once statement: wrong number of arguments (given #{args.count}, expecting 0 or 1)"
        end

        once_id = args.nil? ? ":_#{@once_counter += 1}" : args[0]

        "unless $_once_tokens.include? #{once_id};$_once_tokens<<#{once_id};"
      end

      def compilePushOnce args
        if args&.count != 1 && args&.count != 2
          raise StandardError.new "Push once statement: wrong number of arguments (given #{args&.count || 0}, expecting 1 or 2)"
        end
        @once_counter += 1
        once_id = args[1].nil? ? ":_#{@once_counter}" : args[1]

        "($_once_tokens.include? #{once_id}) || $_once_tokens<<#{once_id} && RBlade::StackManager.push(#{args[0]}) do |_out|;"
      end

      def compilePrependOnce args
        if args&.count != 1 && args&.count != 2
          raise StandardError.new "Prepend once statement: wrong number of arguments (given #{args&.count || 0}, expecting 1 or 2)"
        end
        @once_counter += 1
        once_id = args[1].nil? ? ":_#{@once_counter}" : args[1]

        "($_once_tokens.include? #{once_id}) || $_once_tokens<<#{once_id} && RBlade::StackManager.prepend(#{args[0]}) do |_out|;"
      end
    end
  end
end
