require_relative 'variable.rb'

module RAMS
  # A Model is a collection of:
  #
  #   * Variables
  #   * Constraints
  #   * An objective function
  #
  # Models can be maximized or minimized by different solvers.
  class Model
    attr_reader :variables, :constraints

    def init
      @variables = []
      @constraints = []
    end

    def variable(name = '', low = 0.0, high = nil, type = CONTINUOUS)
      v = Variable.new name, low, high, type
      variables << v
      v
    end

    def <<(constraint)
      @constraints << constraint
      self
    end

    def maximize
      # TODO
    end

    def minimize
      -maximize
    end

    private

    def optimize
      # TODO
    end
  end
end
