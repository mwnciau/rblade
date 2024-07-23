module RBlade
  class AttributesManager
    @attributes = {}
    def initialize attributes
      @attributes = attributes
    end

    def to_s attributes = nil
      attributes ||= @attributes

      attributes.map do |key, value|
        "#{key}=\"#{h(value)}\""
      end.join " "
    end

    def only(keys)
      if keys.is_a? Array
        keys = keys.map(&:to_sym)
      else
        keys = [keys.to_sym]
      end

      self.class.new @attributes.slice(*keys)
    end

    def except(keys)
      if keys.is_a? Array
        keys = keys.map(&:to_sym)
      else
        keys = [keys.to_sym]
      end

      self.class.new @attributes.except(*keys)
    end

    def merge(defaultAttributes)
      newAttributes = defaultAttributes

      @attributes.each do |key, value|
        if key == :class && !newAttributes[key].nil?
          newAttributes[key] << ' ' + value
          next
        end

        if key == :style && !newAttributes[key].nil?
          newAttributes[key] << ';' + value
          next
        end

        newAttributes[key] = value
      end

      self.class.new newAttributes
    end
  end
end
