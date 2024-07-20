module RBlade
  class StackManager
    def self.initialize stack_name, before_stack
      @@stacks[stack_name] ||= Stack.new
      @@stacks[stack_name].set_before_stack before_stack
    end

    def self.clear
      @@stacks = {}
    end

    def self.push stack_name, code
      @@stacks[stack_name] ||= Stack.new
      @@stacks[stack_name].push code.to_s
    end

    def self.prepend stack_name, code
      @@stacks[stack_name] ||= Stack.new
      @@stacks[stack_name].prepend code.to_s
    end

    def self.get(stacks)
      stacks.map do |name|
        out = @@stacks[name].to_s
        @@stacks.delete name

        out
      end.join
    end

    private

    @@stacks = {}

    class Stack
      def initialize
        @prepends = ""
        @stack = ""
      end

      def set_before_stack before_stack
        @before_stack = before_stack
      end

      def to_s
        "#{@before_stack}#{@prepends}#{@stack}"
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
