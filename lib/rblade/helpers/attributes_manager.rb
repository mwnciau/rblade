module RBlade
  class AttributesManager
    @attributes = {}
    def initialize attributes
      @attributes = attributes

      if !@attributes[:_class].nil?
        @attributes[:class] = mergeClasses(@attributes[:class], @attributes.delete(:_class))
      end
      if !@attributes[:_style].nil?
        @attributes[:style] = mergeClasses(@attributes[:style], @attributes.delete(:_style))
      end

      @attributes
    end

    def default(key, default = nil)
      if @attributes[key].nil? && !default.nil?
        @attributes[key] = default
      end

      @attributes[key]
    end

    def has?(key)
      !@attributes[key].nil?
    end

    def to_h
      attributes = @attributes.dup
      if !attributes[:class].nil?
        attributes[:_class] = attributes.delete :class
      end
      if !attributes[:style].nil?
        attributes[:_style] = attributes.delete :style
      end

      attributes
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
          new_attributes[key] = mergeClasses(new_attributes[key], value.to_s)
          next
        end

        if key == :style && !new_attributes[key].nil?
          new_attributes[key] = mergeStyles(new_attributes[key], value.to_s)
          next
        end

        new_attributes[key] = value
      end

      self.class.new new_attributes
    end

    private

    def mergeClasses(classes_1, classes_2)
      if classes_1.nil?
        return classes_2
      end
      if classes_2.nil?
        return classes_1
      end

      classes_combined = classes_1
      unless classes_combined.end_with? " "
        classes_combined << " "
      end
      classes_combined << classes_2.to_s

      classes_combined
    end

    def mergeStyles(styles_1, styles_2)
      if styles_1.nil?
        return styles_2
      end
      if styles_2.nil?
        return styles_1
      end

      styles_combined = styles_1
      unless styles_combined.end_with? ";"
        styles_combined << ";"
      end
      styles_combined << styles_2.to_s

      styles_combined
    end
  end
end
