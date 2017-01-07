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
    attr_accessor :sense, :objective
    attr_reader :variables, :constraints

    SOLVERS = {
      glpk: RAMS::Solvers::GLPK.new
    }

    def initialize
      @sense = :max
      @objective = nil
      @variables = []
      @constraints = []
    end

    def variable(low = 0.0, high = nil, type = CONTINUOUS)
      v = Variable.new low, high, type
      variables << v
      v
    end

    def <<(constraint)
      constraints << constraint
      self
    end

    def solve(solver = :glpk, *solver_args)
      model_file = write_model_file
      begin
        call_solver solver, model_file, *solver_args
      ensure
        model_file.unlink
      end
    end

    def to_s
      <<-LP
#{sense}
  obj: #{(objective.nil? || feasible_objective).to_s}
st
  #{constraints.map(&:to_s).join("\n  ")}
bounds
  #{variables.map(&:to_s).join("\n  ")}
end
      LP
    end

    private

    def write_model_file
      model_file = Tempfile.new ['', '.lp']
      model_file.write to_s
      model_file.close
      model_file
    end

    def call_solver(solver, model_file, *solver_args)
      solution_file = Tempfile.new ['', '.sol']
      # begin
      #   puts `glpsol --lp #{model_file.path} -w #{solution_file.path}`
      # ensure
      #   solution_file.unlink
      # end
      SOLVERS[solver].solve(model_file, solution_file, solver_args)
    end

    def feasible_objective
      variables.first * 0
    end
  end
end
