module RAMS
  # TODO
  class Expression
    attr_reader :coefficients, :constant

    def initialize(coefficients = {}, constant = 0.0)
      @coefficients = coefficients.dup
      @coefficients.default = 0.0
      @constant = constant.to_f
    end

    def -@
      Expression.new coefficients.map { |v, c| [v, -c] }.to_h, -constant
    end

    def +(other)
      if other.is_a? Numeric
        return Expression.new({}, 0.0) unless other
        return Expression.new(coefficients, constant + other)
      end
      Expression.new add_coefficients(other), constant + other.constant
    end

    def -(other)
      if other.is_a? Numeric
        return Expression.new({}, 0.0) unless other
        return Expression.new(coefficients, constant - other)
      end
      Expression.new add_coefficients(other, -1), constant - other.constant
    end

    def *(other)
      if other.is_a? Numeric
        return Expression.new(coefficients.map do |v, c|
          [v, c * other]
        end.to_h, constant * other)
      end
    end

    def /(other)
      if other.is_a? Numeric
        return Expression.new(coefficients.map do |v, c|
          [v, c / other]
        end.to_h, constant / other)
      end
    end

    private

    def merge_variables(other)
      (coefficients.keys + other.coefficients.keys).uniq
    end

    def add_coefficients(other, sign = +1)
      vars = merge_variables(other)
      vars.map do |v|
        [v, coefficients[v] + (sign * other.coefficients[v])]
      end.to_h
    end
  end
end
