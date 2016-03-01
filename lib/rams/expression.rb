module RAMS
  # TODO
  class Posynomial
    attr_reader :coefficients, :constant

    def initialize(coefficients = {}, constant = 0.0)
      @coefficients = coefficients.dup
      @coefficients.default = 0.0
      @constant = constant.to_f
    end

    # TODO: ^, **, ...
    def -@
      Posynomial.new coefficients.map { |v, c| [v, -c] }.to_h, -constant
    end

    def +(other)
      if other.is_a? Numeric
        return Posynomial.new({}, 0.0) unless other
        return Posynomial.new(coefficients, constant + other)
      end
      Posynomial.new add_coefficients(other), constant + other.constant
    end

    def -(other)
      if other.is_a? Numeric
        return Posynomial.new({}, 0.0) unless other
        return Posynomial.new(coefficients, constant - other)
      end
      Posynomial.new add_coefficients(other, -1), constant - other.constant
    end

    def *(other)
      if other.is_a? Numeric
        return Posynomial.new(coefficients.map do |v, c|
          [v, c * other]
        end.to_h, constant * other)
      end
      # Posynomial.new multiply_coefficients(other, -1) +
    end

    def /(other)
      if other.is_a? Numeric
        return Posynomial.new(coefficients.map do |v, c|
          [v, c / other]
        end.to_h, constant / other)
      end
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
  alias old_sub -
  alias old_multiply *
  alias old_divide /

  def +(other)
    return other + self if other.is_a? RAMS::Posynomial
    old_add other
  end

  def -(other)
    return -other + self if other.is_a? RAMS::Posynomial
    old_sub other
  end

  def *(other)
    return other * self if other.is_a? RAMS::Posynomial
    old_multiply other
  end

  def /(other)
    return other * (1.0 / self) if other.is_a? RAMS::Posynomial
    old_divide other
  end
end

# TODO
class Float
  alias old_add +
  alias old_sub -
  alias old_multiply *
  alias old_divide /

  def +(other)
    return other + self if other.is_a? RAMS::Posynomial
    old_add other
  end

  def -(other)
    return -other + self if other.is_a? RAMS::Posynomial
    old_sub other
  end

  def *(other)
    return other * self if other.is_a? RAMS::Posynomial
    old_multiply other
  end

  def /(other)
    return other * (1.0 / self) if other.is_a? RAMS::Posynomial
    old_divide other
  end
end
