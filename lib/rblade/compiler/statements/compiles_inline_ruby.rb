# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesInlineRuby
      def compile args
        if args&.count != 1
          raise RBladeTemplateError.new "Ruby statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        arg = args[0].strip
        if arg[-1] != ";"
          arg << ";"
        end
        arg
      end
    end
  end
end
