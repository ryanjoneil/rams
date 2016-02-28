module RAMS
  # TODO
  class Posynomial
    attr_reader :coefficients, :constant

    def initialize(coefficients = {}, constant = 0.0)
      @coefficients = coefficients
      @constant = constant
    end

    # TODO: unary -, ^, **, ...

    def +(other)
      return Posynomial.new(coefficients, constant + other) if other.kind_of? Numeric
      coeff = coefficients.dup
      other.coefficients.each do |m, c|
        coeff[m] ||= 0.0
        coeff[m] += c
      end
      Posynomial.new coeff, constant + other.constant
    end

    def -(other)
      return Posynomial.new(coefficients, constant - other) if other.kind_of? Numeric
      coeff = coefficients.dup
      other.coefficients.each do |m, c|
        coeff[m] ||= 0.0
        coeff[m] -= c
      end
      Posynomial.new coeff, constant - other.constant
    end

    def *(other)
    end

    def /(other)
      # other must be a Monomial
    end
  end

  # TODO
  class Monomial < Posynomial
    attr_reader :exponents

    def initialize(exponents = {})
      @exponents = exponents
      super({ self => 1.0 })
    end

    def hash
      variables.map { |id| [id, self.exponents[id]] }.hash
    end

    private

    def variables
      exponents.keys.sort
    end
  end
end
