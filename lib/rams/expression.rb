require_relative 'constraint'

module RAMS
  # A RAMS::Expression is a dot product of variables, cofficients, and a
  # constant offset:
  #
  #     3 * x1 + 1.5 * x3 - 4
  #
  # Expressions must be linear. They can be added and subtracted.
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
      raise NotImplementedError
    end

    def /(other)
      if other.is_a? Numeric
        return Expression.new(coefficients.map do |v, c|
          [v, c / other]
        end.to_h, constant / other)
      end
      raise NotImplementedError
    end

    def <=(other)
      RAMS::Constraint.new(lhs(other), :<=, rhs(other))
    end

    def ==(other)
      RAMS::Constraint.new(lhs(other), :==, rhs(other))
    end

    def >=(other)
      RAMS::Constraint.new(lhs(other), :>=, rhs(other))
    end

    def to_s
      vars_s = coefficients.map { |v, c| "#{c >= 0 ? '+' : '-'} #{c} #{v.name} " }.join
      const_s = constant.zero? ? '' : "#{constant >= 0 ? '+' : '-'} #{constant}"
      vars_s + const_s
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

    def lhs(other)
      (self - other).coefficients
    end

    def rhs(other)
      return other - constant if other.is_a? Numeric
      other.constant - constant
    end
  end
end
