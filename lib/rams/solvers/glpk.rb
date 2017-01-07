require_relative 'solver'

module RAMS
  module Solvers
    # Interface to the GNU Linear Programming Kit
    class GLPK < Solver
      def solver_command(model_file, solution_file)
        ['glpsol', '--lp', model_file.path, '-w', solution_file.path]
      end

      # TODO: implement me
      def parse_solution(model, _solution_file)
        model.variables.values.map { |v| [v.name, 0] }.to_h
      end
    end
  end
end
