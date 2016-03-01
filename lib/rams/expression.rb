module RAMS
  # TODO
  class Posynomial
    attr_reader :coefficients, :constant

    def initialize(coefficients = {}, constant = 0.0)
      @coefficients = coefficients.dup
      @coefficients.default = 0.0
      @constant = constant
    end

    # TODO: unary -, ^, **, ...

    def +(other)
      if other.is_a? Numeric
        return Posynomial.new(coefficients, constant + other)
      end
      Posynomial.new add_coefficients(other), constant + other.constant
    end

    def -(other)
      if other.is_a? Numeric
        return Posynomial.new(coefficients, constant - other)
      end
      Posynomial.new add_coefficients(other, -1), constant - other.constant
    end

    def *(other)
    end

    def /(other)
      # other must be a Monomial
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

  # TODO
  class Monomial < Posynomial
    attr_reader :exponents

    def initialize(exponents = {})
      @exponents = exponents.dup
      @exponents.default = 0.0

      super({ self => 1.0 })
    end

    def hash
      variables.map { |id| [id, exponents[id]] }.hash
    end

    private

    def variables
      exponents.keys.sort
    end
  end
end

# TODO
class Fixnum
  alias old_add +
  def +(other)
    return other + self if other.is_a? RAMS::Posynomial
    old_add other
  end
end

# TODO
class Float
  alias old_add +
  def +(other)
    return other + self if other.is_a? RAMS::Posynomial
    old_add other
  end
end
