# frozen_string_literal: true

require "rblade/helpers/attributes_manager"

module RBlade
  class SlotManager
    def initialize(content, attributes = nil)
      @content = content
      @attributes = attributes && AttributesManager.new(attributes)
    end

    def html_safe?
      true
    end

    def to_s
      self
    end

    def to_str
      @content
    end

    def method_missing(method, *)
      @content.send(method, *)
    end

    def respond_to_missing?(method_name, *args)
      @content.respond_to?(method_name)
    end

    # Wraps var in a slot manager if it's a string
    def self.wrap(var)
      var.is_a?(String) ? new(var) : var
    end

    attr_reader :attributes
  end
end
