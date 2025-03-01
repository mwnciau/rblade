# frozen_string_literal: true

module RBlade
  class StackManager
    def self.initialize stack_name, before_stack
      @@stacks[stack_name] ||= Stack.new
      @@stacks[stack_name].set_before_stack before_stack
    end

    def self.clear
      @@stacks = {}
    end

    def self.push stack_name
      @@stacks[stack_name] ||= Stack.new
      @@stacks[stack_name].push yield(+"")
    end

    def self.prepend stack_name
      @@stacks[stack_name] ||= Stack.new
      @@stacks[stack_name].prepend yield(+"")
    end

    def self.get(stacks)
      stacks.map do |name|
        @@stacks.delete(name).to_s
      end.join
    end

    private

    @@stacks = {}

    class Stack
      def initialize
        @prepends = +""
        @stack = +""
      end

      def set_before_stack before_stack
        @before_stack = before_stack
      end

      def to_s
        "#{@before_stack}#{@prepends}#{@stack}"
      end

      def to_str
        to_s
      end

      def push code
        @stack << code
      end

      def prepend code
        @prepends << code
      end
    end
  end
end
