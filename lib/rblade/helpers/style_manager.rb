# frozen_string_literal: true

module RBlade
  class StyleManager
    def initialize(styles)
      if styles.is_a? String
        @styles = styles.strip
        unless @styles == "" || @styles.end_with?(";")
          @styles << ";"
        end
      elsif styles.is_a? Array
        @styles = styles.map do |style|
          style = style.strip
          unless style.end_with? ";"
            style << ";"
          end

          style
        end.join
      elsif styles.is_a? Hash
        @styles = +""
        styles.each do |value, predicate|
          if predicate
            value = value.to_s.strip
            unless value.end_with? ";"
              value << ";"
            end

            @styles << value
          end
        end
      end
    end

    def to_s
      @styles
    end

    def to_str
      to_s
    end
  end
end
