# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesHtmlAttributes
      def compile_class(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Class statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        %`@output_buffer.raw_buffer<<-"class=\\"\#{RBlade::ClassManager.new(#{args[0]})}\\"";`
      end

      def compile_style(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Style statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        %`@output_buffer.raw_buffer<<-"style=\\"\#{RBlade::StyleManager.new(#{args[0]})}\\"";`
      end
    end
  end
end
