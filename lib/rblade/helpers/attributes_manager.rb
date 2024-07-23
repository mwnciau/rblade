module RBlade
  class AttributesManager
    @attributes = {}
    def initialize attributes
      @attributes = attributes
    end

    def to_h
      @attributes
    end

    def to_s attributes = nil
      attributes ||= @attributes

      attributes.map do |key, value|
        "#{key}=\"#{h(value)}\""
      end.join " "
    end

    def only(keys)
      keys = if keys.is_a? Array
        keys.map(&:to_sym)
      else
        [keys.to_sym]
      end

      self.class.new @attributes.slice(*keys)
    end

    def except(keys)
      keys = if keys.is_a? Array
        keys.map(&:to_sym)
      else
        [keys.to_sym]
      end

      self.class.new @attributes.except(*keys)
    end

    def merge(default_attributes)
      new_attributes = default_attributes

      @attributes.each do |key, value|
        if key == :class && !new_attributes[key].nil?
          unless new_attributes[key].end_with? " "
            new_attributes[key] << " "
          end
          new_attributes[key] << value.to_s
          next
        end

        if key == :style && !new_attributes[key].nil?
          unless new_attributes[key].end_with? ";"
            new_attributes[key] << ";"
          end
          new_attributes[key] << value.to_s
          next
        end

        new_attributes[key] = value
      end

      self.class.new new_attributes
    end
  end
end
