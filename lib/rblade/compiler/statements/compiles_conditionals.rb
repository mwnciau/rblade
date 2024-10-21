# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesConditionals
      def compileIf args
        if args&.count != 1
          raise StandardError.new "If statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};"
      end

      def compileBlank args
        if args&.count != 1
          raise StandardError.new "Blank? statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if (#{args[0]}).blank?;"
      end

      def compileDefined args
        if args&.count != 1
          raise StandardError.new "Defined? statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if defined? #{args[0]};"
      end

      def compileEmpty args
        if args&.count != 1
          raise StandardError.new "Empty? statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if (#{args[0]}).empty?;"
      end

      def compileNil args
        if args&.count != 1
          raise StandardError.new "Nil? statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if (#{args[0]}).nil?;"
      end

      def compilePresent args
        if args&.count != 1
          raise StandardError.new "Present? statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if (#{args[0]}).present?;"
      end

      def compileElsif args
        if args&.count != 1
          raise StandardError.new "Elsif statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "elsif #{args[0]};"
      end

      def compileElse args
        unless args.nil?
          raise StandardError.new "Else statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        "else;"
      end

      def compileUnless args
        if args&.count != 1
          raise StandardError.new "Unless statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "unless #{args[0]};"
      end

      def compileCase args
        if args&.count != 1
          raise StandardError.new "Case statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "case #{args[0]};"
      end

      def compileWhen args
        if args.nil?
          raise StandardError.new "When statement: wrong number of arguments (given 0, expecting at least 1)"
        end

        "when #{args.join ","};"
      end

      def compileChecked args
        if args&.count != 1
          raise StandardError.new "Checked statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};_out<<'checked';end;"
      end

      def compileDisabled args
        if args&.count != 1
          raise StandardError.new "Disabled statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};_out<<'disabled';end;"
      end

      def compileReadonly args
        if args&.count != 1
          raise StandardError.new "Readonly statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};_out<<'readonly';end;"
      end

      def compileRequired args
        if args&.count != 1
          raise StandardError.new "Required statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};_out<<'required';end;"
      end

      def compileSelected args
        if args&.count != 1
          raise StandardError.new "Selected statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "if #{args[0]};_out<<'selected';end;"
      end

      def compileEnv args
        if args&.count != 1
          raise StandardError.new "Env statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        environments = args[0].strip

        "if Array.wrap(#{environments}).include?(Rails.env);"
      end

      def compileProduction args
        unless args.nil?
          raise StandardError.new "Production statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        "if Rails.env.production?;"
      end
    end
  end
end
