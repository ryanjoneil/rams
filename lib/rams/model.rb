require 'tempfile'
require_relative 'variable'
require_relative 'solvers/glpk'

module RAMS
  # A Model is a collection of:
  #
  #   * Variables
  #   * Constraints
  #   * An objective function and sense
  #
  # Models can be maximized or minimized by different solvers.
  class Model
    attr_accessor :objective, :args, :verbose
    attr_reader :solver, :sense, :variables, :constraints

    SOLVERS = { glpk: RAMS::Solvers::GLPK.new }.freeze

    def initialize
      @solver = :glpk
      @sense = :max
      @objective = nil
      @verbose = false
      @args = []
      @variables = {}
      @constraints = {}
    end

    def solver=(solver)
      raise(ArgumentError, "valid solvers: #{SOLVERS.keys.join(' ')}") if SOLVERS[solver].nil?
      @solver = solver
    end

    def sense=(sense)
      raise(ArgumentError, 'sense must be :min or :max') unless sense == :min || sense == :max
      @sense = sense
    end

    def variable(low = 0.0, high = nil, type = CONTINUOUS)
      v = Variable.new low, high, type
      variables[v.name] = v
    end

    def constrain(constraint)
      constraints[constraint.name] = constraint
    end

    def <<(constraint)
      constrain constraint
    end

    def solve
      SOLVERS[solver].solve self
    end

    def to_s
      <<-LP
#{sense}
  obj: #{objective || feasible_objective}
st
  #{constraints.values.map(&:to_s).join("\n  ")}
bounds
  #{variables.values.map(&:to_s).join("\n  ")}
end
      LP
    end

    private

    def feasible_objective
      variables.first * 0
    end
  end
end
