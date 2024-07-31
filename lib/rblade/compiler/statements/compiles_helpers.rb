module RBlade
  class CompilesStatements
    class CompilesHelpers
      def compileMethod args
        if args&.count != 1
          raise StandardError.new "Once statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end
        method = RBlade.h(args[0].tr "\"'", "")

        %[_out<<'<input type="hidden" name="_method" value="#{method}">';]
      end

      def compileDelete args
        if !args.nil?
          raise StandardError.new "Once statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        compileMethod(['DELETE'])
      end

      def compilePatch args
        if !args.nil?
          raise StandardError.new "Once statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        compileMethod(['PATCH'])
      end

      def compilePut args
        if !args.nil?
          raise StandardError.new "Once statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        compileMethod(['PUT'])
      end
    end
  end
end
