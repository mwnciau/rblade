module RBlade
  class StackManager
    def self.initialize stackName, before_stack
      @@stacks[stackName] ||= Stack.new
      @@stacks[stackName].set_before_stack before_stack
    end

    def self.clear
      @@stacks = {}
    end

    def self.push stackName, code
      @@stacks[stackName] ||= Stack.new
      @@stacks[stackName].push code.to_s
    end

    def self.prepend stackName, code
      @@stacks[stackName] ||= Stack.new
      @@stacks[stackName].prepend code.to_s
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
        @prepends = ''
        @stack = ''
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