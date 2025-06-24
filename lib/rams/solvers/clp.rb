require_relative 'solver'

module RAMS
  module Solvers
    # Interface to COIN-OR Linear Programming
    class CLP < Solver
      def solver_command(model_path, solution_path, args)
        ['clp', model_path] + args + ['printingOptions', 'all', 'solve', 'solution', solution_path]
      end

      private

      def parse_status(_model, lines)
        return :undefined if lines.count < 1
        status = lines.first
        return :optimal if status =~ /optimal/i
        return :feasible if status =~ /stopped/i
        return :infeasible if status =~ /infeasible/i
        return :unbounded if status =~ /unbounded/i
        :undefined
      end

      def parse_objective(model, lines)
        return nil if lines.count < 1
        lines[0].split[-1].to_f
      end

      def parse_primal(model, lines)
        lines[model.constraints.count + 1, model.variables.count].map do |l|
          comps = l.split
          [model.variables[comps[1]], comps[2].to_f]
        end.to_h
      end

      def parse_dual(model, lines)
        lines[1, model.constraints.count].map do |l|
          comps = l.split
          dual = comps[3].to_f
          [model.constraints[comps[1]], dual]
        end.to_h
      end
    end
  end
end
