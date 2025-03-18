# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesForm
      def compile_method(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Method statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        %(@output_buffer.raw_buffer<<-"<input type=\\"hidden\\" name=\\"_method\\" value=\\"\#{#{args[0]}}\\">";)
      end

      def compile_delete(args)
        unless args.nil?
          raise RBladeTemplateError.new "Delete statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        compile_method(["'DELETE'"])
      end

      def compile_patch(args)
        unless args.nil?
          raise RBladeTemplateError.new "Patch statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        compile_method(["'PATCH'"])
      end

      def compile_put(args)
        unless args.nil?
          raise RBladeTemplateError.new "Put statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        compile_method(["'PUT'"])
      end

      def compile_old(args)
        if args.nil? || args.count > 2
          raise RBladeTemplateError.new "Old statement: wrong number of arguments (given #{args&.count || 0}, expecting 1 or 2)"
        end

        default_value = args[1] || "''"

        "@output_buffer.raw_buffer<<params.fetch(#{args[0]},#{default_value});"
      end
    end
  end
end
