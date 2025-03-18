# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesConditionals
      def compile_if(args)
        if args&.count != 1
          raise RBladeTemplateError.new "If statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};"
      end

      def compile_blank(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Blank? statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if (#{args[0]}).blank?;"
      end

      def compile_defined(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Defined? statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if defined? #{args[0]};"
      end

      def compile_empty(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Empty? statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if (#{args[0]}).empty?;"
      end

      def compile_nil(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Nil? statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if (#{args[0]}).nil?;"
      end

      def compile_present(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Present? statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if (#{args[0]}).present?;"
      end

      def compile_elsif(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Elsif statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "elsif #{args[0]};"
      end

      def compile_else(args)
        unless args.nil?
          raise RBladeTemplateError.new "Else statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        "else;"
      end

      def compile_unless(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Unless statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "unless #{args[0]};"
      end

      def compile_case(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Case statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "case #{args[0]};"
      end

      def compile_when(args)
        if args.nil?
          raise RBladeTemplateError.new "When statement: wrong number of arguments (given 0, expecting at least 1)"
        end

        "when #{args.join ","};"
      end

      def compile_checked(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Checked statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};@output_buffer.raw_buffer<<-'checked';end;"
      end

      def compile_disabled(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Disabled statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};@output_buffer.raw_buffer<<-'disabled';end;"
      end

      def compile_readonly(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Readonly statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};@output_buffer.raw_buffer<<-'readonly';end;"
      end

      def compile_required(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Required statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};@output_buffer.raw_buffer<<-'required';end;"
      end

      def compile_selected(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Selected statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};@output_buffer.raw_buffer<<-'selected';end;"
      end

      def compile_env(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Env statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        environments = args[0].strip

        "if Array.wrap(#{environments}).include?(Rails.env);"
      end

      def compile_production(args)
        unless args.nil?
          raise RBladeTemplateError.new "Production statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        "if Rails.env.production?;"
      end
    end
  end
end
