# frozen_string_literal: true

module RBlade
  class AttributesManager
    delegate :delete, to: :@attributes

    def initialize attributes
      @attributes = attributes
    end

    def default(key, default = nil)
      if @attributes[key].nil? && !default.nil?
        @attributes[key] = default
      end

      @attributes[key]
    end

    def has?(*keys)
      keys.map!(&:to_sym)

      keys.all? { |key| @attributes.has_key? key }
    end

    def method_missing(method, *, &)
      if [:select, :filter, :slice].include? method
        AttributesManager.new @attributes.send(method, *, &)
      else
        @attributes.send(method, *, &)
      end
    end

    def respond_to_missing?(method_name, *args)
      @attributes.respond_to?(method_name)
    end

    def html_safe?
      true
    end

    def to_str attributes = nil
      attributes ||= @attributes

      attributes.map do |key, value|
        (value == true) ? key : "#{key}=\"#{CGI.escape_html(value.to_s)}\""
      end.join(" ")
    end

    def to_s
      self
    end

    def only(keys)
      keys = if keys.is_a? Array
        keys.map(&:to_sym)
      else
        [keys.to_sym]
      end

      AttributesManager.new @attributes.slice(*keys)
    end

    def except(keys)
      keys = if keys.is_a? Array
        keys.map(&:to_sym)
      else
        [keys.to_sym]
      end

      AttributesManager.new @attributes.except(*keys)
    end

    def class(new_classes)
      new_classes = ClassManager.new(new_classes).to_s
      attributes = @attributes.dup
      attributes[:class] = merge_classes attributes[:class], new_classes

      AttributesManager.new attributes
    end

    def merge(default_attributes)
      new_attributes = default_attributes

      @attributes.each do |key, value|
        if key == :class && !new_attributes[key].nil?
          new_attributes[key] = merge_classes(new_attributes[key], value.to_s)
          next
        end

        if key == :style && !new_attributes[key].nil?
          new_attributes[key] = merge_styles(new_attributes[key], value.to_s)
          next
        end

        new_attributes[key] = value
      end

      AttributesManager.new new_attributes
    end

    def has_any?(*keys)
      keys.map!(&:to_sym)

      keys.any? { |key| @attributes.has_key? key }
    end

    private

    def merge_classes(classes_1, classes_2)
      if classes_1.nil?
        return classes_2
      end
      if classes_2.nil?
        return classes_1
      end

      classes_combined = +classes_1
      unless classes_combined.end_with? " "
        classes_combined << " "
      end
      classes_combined << classes_2.to_s

      classes_combined
    end

    def merge_styles(styles_1, styles_2)
      if styles_1.nil?
        return styles_2
      end
      if styles_2.nil?
        return styles_1
      end

      styles_combined = +styles_1
      unless styles_combined.end_with? ";"
        styles_combined << ";"
      end
      styles_combined << styles_2.to_s

      styles_combined
    end
  end
end
