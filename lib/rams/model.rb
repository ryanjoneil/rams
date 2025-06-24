require 'tempfile'
require_relative 'expression'
require_relative 'formatters/lp'
require_relative 'solvers/cbc'
require_relative 'solvers/clp'
require_relative 'solvers/glpk'
require_relative 'solvers/highs'
require_relative 'solvers/scip'
require_relative 'variable'

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
    attr_accessor :args, :verbose
    attr_reader :solver, :sense, :variables, :constraints
    attr_writer :objective

    SOLVERS = {
      cbc: RAMS::Solvers::CBC.new,
      clp: RAMS::Solvers::CLP.new,
      glpk: RAMS::Solvers::GLPK.new,
      highs: RAMS::Solvers::HiGHS.new,
      scip: RAMS::Solvers::SCIP.new
    }.freeze

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

    def objective
      @objective || Expression.new(variables.values.first => 0)
    end

    def solve
      raise(ArgumentError, 'model has no variables') if variables.empty?
      raise(ArgumentError, 'model has no constraints') if constraints.empty?
      SOLVERS[solver].solve self
    end

    def to_lp
      RAMS::Formatters::LP.format self
    end
  end
end
