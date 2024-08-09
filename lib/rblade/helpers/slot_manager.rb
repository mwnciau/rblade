require "rblade/helpers/attributes_manager"
require "rblade/helpers/html_string"

module RBlade
  class SlotManager < HtmlString
    def initialize content, attributes = nil
      @content = content
      @attributes = attributes && AttributesManager.new(attributes)
    end

    def to_s
      @content
    end

    def to_str
      to_s
    end

    def method_missing(method, *)
      @content.send(method, *)
    end

    def respond_to_missing?(method_name, *args)
      @content.respond_to?(method_name)
    end

    # Wraps var in a slot manager if it's a string
    def self.wrap var
      var.is_a?(String) ? new(var) : var
    end

    attr_reader :attributes
  end
end
