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
  # An example of a simple model:
  #
  #   m = RAMS::Model.new
  #   x1 = m.variable(type: :binary)
  #   x2 = m.variable
  #   m.constrain(x1 + x2 <= 1)
  #
  # Models can be maximized or minimized by different solvers.
  #
  #   m.sense = :max
  #   m.objective = (x1 + (2 * x2))
  #   m.solver = :glpk
  #   m.verbose = true
  #   m.solve
  #
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

    def variable(low: 0.0, high: nil, type: :continuous)
      v = Variable.new low: low, high: high, type: type
      variables[v.name] = v
    end

    def constrain(constraint)
      constraints[constraint.name] = constraint
    end

    def solve
      raise(ArgumentError, 'model has no variables') if variables.empty?
      raise(ArgumentError, 'model has no constraints') if constraints.empty?
      SOLVERS[solver].solve self
    end

    # rubocop:disable AbcSize
    def to_s
      <<-LP
#{sense}
  obj: #{feasible_objective.is_a?(Variable) ? feasible_objective.name : feasible_objective}
st
  #{constraints.values.map(&:to_s).join("\n  ")}
bounds
  #{variables.values.map(&:to_s).join("\n  ")}
general
  #{variables.values.select { |v| v.type == :integer }.map(&:name).join("\n  ")}
binary
  #{variables.values.select { |v| v.type == :binary }.map(&:name).join("\n  ")}
end
      LP
    end
    # rubocop:enable AbcSize

    private

    def feasible_objective
      objective || variables.values.first
    end
  end
end
