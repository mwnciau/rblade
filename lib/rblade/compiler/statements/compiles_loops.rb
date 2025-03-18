# frozen_string_literal: true

module RBlade
  class CompilesStatements
    class CompilesLoops
      def initialize
        @loop_else_counter = 0
      end

      def compile_break(args)
        if args&.count&.> 1
          raise RBladeTemplateError.new "Break statement: wrong number of arguments (given #{args.count}, expecting 0 or 1)"
        end

        if args.nil?
          "break;"
        else
          "if #{args[0]};break;end;"
        end
      end

      def compile_each(args)
        if args.nil? || args.count > 2
          raise RBladeTemplateError.new "Each statement: wrong number of arguments (given #{args&.count || 0}, expecting 1 or 2)"
        end
        last_arg, collection = args.pop.split(" in ")
        args.push(last_arg)

        if collection.nil?
          raise RBladeTemplateError.new "Each statement: collection not found (expecting 'in')"
        end

        "#{collection}.each do |#{args.join(",")}|;"
      end

      def compile_each_with_index(args)
        if args.nil? || args.count > 3
          raise RBladeTemplateError.new "Each with index statement: wrong number of arguments (given #{args&.count || 0}, expecting 1 to 3)"
        end
        last_arg, collection = args.pop.split(" in ")
        args.push(last_arg)

        if collection.nil?
          raise RBladeTemplateError.new "Each with index statement: collection not found (expecting 'in')"
        end

        # Special case for 3 arguments: the first 2 arguments are the key/value pair in a Hash, and
        # the third is the index
        if args.count == 3
          "#{collection}.each_with_index do |_ivar,#{args[2]}|;#{args[0]},#{args[1]}=_ivar;"
        else
          "#{collection}.each_with_index do |#{args.join(",")}|;"
        end
      end

      def compile_each_else(args)
        if args.nil? || args.count > 2
          raise RBladeTemplateError.new "Each else statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end
        last_arg, collection = args.pop.split(" in ")
        args.push(last_arg)

        if collection.nil?
          raise RBladeTemplateError.new "Each else statement: collection not found (expecting 'in')"
        end

        @loop_else_counter += 1

        "_looped_#{@loop_else_counter}=false;#{collection}.each do |#{args.join(",")}|;_looped_#{@loop_else_counter}=true;"
      end

      def compile_each_with_index_else(args)
        if args.nil? || args.count > 3
          raise RBladeTemplateError.new "Each with index statement: wrong number of arguments (given #{args&.count || 0}, expecting 1 to 3)"
        end
        last_arg, collection = args.pop.split(" in ")
        args.push(last_arg)

        if collection.nil?
          raise RBladeTemplateError.new "Each with index statement: collection not found (expecting 'in')"
        end

        @loop_else_counter += 1

        # Special case for 3 arguments: the first 2 arguments are the key/value pair in a Hash, and
        # the third is the index
        if args.count == 3
          "_looped_#{@loop_else_counter}=false;#{collection}.each_with_index do |_ivar,#{args[2]}|;#{args[0]},#{args[1]}=_ivar;_looped_#{@loop_else_counter}=true;"
        else
          "_looped_#{@loop_else_counter}=false;#{collection}.each_with_index do |#{args.join(",")}|;_looped_#{@loop_else_counter}=true;"
        end
      end

      def compile_for(args)
        if args&.count != 1
          raise RBladeTemplateError.new "For statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "for #{args[0]};"
      end

      def compile_for_else(args)
        if args&.count != 1
          raise RBladeTemplateError.new "For else statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end
        @loop_else_counter += 1

        "_looped_#{@loop_else_counter}=false;for #{args[0]};_looped_#{@loop_else_counter}=true;"
      end

      def compile_empty(args)
        unless args.nil?
          raise RBladeTemplateError.new "Empty statement: wrong number of arguments (given #{args.count}, expecting 0)"
        end

        @loop_else_counter -= 1

        "end;if !_looped_#{@loop_else_counter + 1};"
      end

      def compile_next(args)
        if args&.count&.> 1
          raise RBladeTemplateError.new "Next statement: wrong number of arguments (given #{args.count}, expecting 0 or 1)"
        end

        if args.nil?
          "next;"
        else
          "if #{args[0]};next;end;"
        end
      end

      def compile_until(args)
        if args&.count != 1
          raise RBladeTemplateError.new "Until statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "until #{args[0]};"
      end

      def compile_while(args)
        if args&.count != 1
          raise RBladeTemplateError.new "While statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
        end

        "while #{args[0]};"
      end
    end
  end
end
