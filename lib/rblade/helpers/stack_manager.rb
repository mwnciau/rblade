# frozen_string_literal: true

module RBlade
  class StackManager
    def initialize
      @stacks = {}
    end

    def initialize_stack(stack_name, output_buffer)
      @stacks[stack_name] ||= Stack.new
      @stacks[stack_name].set_before_stack(-output_buffer.raw_buffer)
      output_buffer.raw_buffer.clear
    end

    def clear
      @stacks = {}
    end

    def push(stack_name, output_buffer, &)
      @stacks[stack_name] ||= Stack.new
      @stacks[stack_name].push output_buffer.capture(&)
    end

    def prepend(stack_name, output_buffer, &)
      @stacks[stack_name] ||= Stack.new
      @stacks[stack_name].prepend output_buffer.capture(&)
    end

    def get(stacks)
      stacks.map do |name|
        @stacks.delete(name).to_s
      end.join
    end

    private

    class Stack
      def initialize
        @prepends = +""
        @stack = +""
      end

      def set_before_stack(before_stack)
        @before_stack = before_stack
      end

      def to_s
        "#{@before_stack}#{@prepends}#{@stack}"
      end

      def to_str
        to_s
      end

      def push(code)
        @stack << code
      end

      def prepend(code)
        @prepends << code
      end
    end
  end
end
