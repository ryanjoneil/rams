require_relative 'solver'

module RAMS
  module Solvers
    # Interface to the GNU Linear Programming Kit
    class GLPK < Solver
      def solver_command(model_file, solution_file)
        ['glpsol', '--lp', model_file.path, '--output', solution_file.path]
      end

      private

      def parse_status(lines)
        status = lines.select { |l| l =~ /^Status/ }.first
        return :optimal if status =~ /OPTIMAL/
        return :feasible if status =~ /FEASIBLE/
        return :infeasible if status =~ /EMPTY/
        :undefined
      end

      def parse_objective(lines)
        lines.select { |l| l =~ /^Objective/ }.first.split[3].to_f
      end

      def parse_primal(model, lines)
        primal = model.variables.values.map { |v| [v, 0.0] }.to_h
        start_idx = lines.index { |l| l =~ /Column name/ } + 2
        length = lines[start_idx, lines.length].index { |l| l == '' }
        primal.update(lines[start_idx, length].map { |l| [model.variables[l[7, 12].strip], l[23, 13].to_f] }.to_h)
      end

      def parse_dual(model, lines)
        duals = model.constraints.values.map { |c| [c, 0.0] }.to_h
        start_idx = lines.index { |l| l =~ /Row name/ } + 2
        length = lines[start_idx, lines.length].index { |l| l == '' }
        duals.update(lines[start_idx, length].map { |l| [model.constraints[l[7, 12].strip], l[-13, 13].to_f] }.to_h)
      end
    end
  end
end
