# frozen_string_literal: true

module RBlade
  class ClassManager
    def initialize classes
      if classes.is_a? String
        @classes = classes
      elsif classes.is_a? Array
        @classes = classes.join " "
      elsif classes.is_a? Hash
        @classes = +""
        classes.map do |value, predicate|
          if predicate
            @classes << "#{value} "
          end
        end
        @classes.rstrip!
      end
    end

    def to_s
      @classes
    end

    def to_str
      to_s
    end
  end
end
