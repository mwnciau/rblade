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

    def attributes
      @attributes
    end
  end
end
