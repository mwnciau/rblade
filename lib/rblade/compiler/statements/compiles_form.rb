# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesForm
      def compileMethod args
        if args&.count != 1
          raise RBladeTemplateError.new "Method statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        %(@output_buffer.raw_buffer<<'<input type="hidden" name="_method" value="'<<#{args[0]}<<'">';)
      end

      def compileDelete args
        unless args.nil?
          raise RBladeTemplateError.new "Delete statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        compileMethod(["'DELETE'"])
      end

      def compilePatch args
        unless args.nil?
          raise RBladeTemplateError.new "Patch statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        compileMethod(["'PATCH'"])
      end

      def compilePut args
        unless args.nil?
          raise RBladeTemplateError.new "Put statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        compileMethod(["'PUT'"])
      end

      def compileOld args
        if args.nil? || args.count > 2
          raise RBladeTemplateError.new "Old statement: wrong number of arguments (given #{args&.count || 0}, expecting 1 or 2)"
        end

        default_value = args[1] || "''"

        "@output_buffer.raw_buffer<<params.fetch(#{args[0]},#{default_value});"
      end
    end
  end
end
