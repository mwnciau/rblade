module RBlade
  class CompilesStatements
    class CompilesHtmlAttributes
      def compileClass args
        if args&.count != 1
          raise StandardError.new "Class statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "_out<<'class=\"'<<RBlade::ClassManager.new(#{args[0]})<<'\"';"
      end

      def compileStyle args
        if args&.count != 1
          raise StandardError.new "Style statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "_out<<'style=\"'<<RBlade::StyleManager.new(#{args[0]})<<'\"';"
      end
    end
  end
end
