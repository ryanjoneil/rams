require_relative 'solver'

module RAMS
  module Solvers
    # Interface to the GNU Linear Programming Kit
    class GLPK < Solver
      def solver_command(model_file, solution_file, args)
        ['glpsol', '--lp', model_file.path, '--output', solution_file.path] + args
      end

      private

      def parse_status(_model, lines)
        status = lines.select { |l| l =~ /^Status/ }.first
        return :optimal if status =~ /OPTIMAL/
        return :feasible if status =~ /FEASIBLE/
        return :infeasible if status =~ /EMPTY/
        return :unbounded if status =~ /UNBOUNDED/
        :undefined
      end

      def parse_objective(_model, lines)
        lines.select { |l| l =~ /^Objective/ }.first.split[3].to_f
      end

      def parse_primal(model, lines)
        start_idx = lines.index { |l| l =~ /Column name/ } + 2
        length = lines[start_idx, lines.length].index { |l| l == '' }
        lines[start_idx, length].map { |l| [model.variables[l[7, 12].strip], l[23, 13].to_f] }.to_h
      end

      def parse_dual(model, lines)
        start_idx = lines.index { |l| l =~ /Row name/ } + 2
        length = lines[start_idx, lines.length].index { |l| l == '' }
        lines[start_idx, length].map { |l| [model.constraints[l[7, 12].strip], l[-13, 13].to_f] }.to_h
      end
    end
  end
end
