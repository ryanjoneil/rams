require_relative 'solver'

module RAMS
  module Solvers
    # Interface to COIN-OR Linear Programming
    class CLP < Solver
      def solver_command(model_file, solution_file, args)
        ['clp', model_file.path] + args + ['printingOptions', 'all', 'solve', 'solution', solution_file.path]
      end

      private

      def parse_status(model, lines)
        return :undefined if lines.count < 1
        status = lines.first
        return :optimal if status =~ /optimal/
        return :feasible if status =~ /stopped/
        return :infeasible if status =~ /infeasible/
        return :unbounded if status =~ /unbounded/
        :undefined
      end

      def parse_objective(model, lines)
        return nil if lines.count < 2
        objective = lines[1].split[-1].to_f
        model.sense == :max ? -objective : objective
      end

      def parse_primal(model, lines)
        lines[model.constraints.count + 2, model.variables.count].map do |l|
          comps = l.split
          [model.variables[comps[1]], comps[2].to_f]
        end.to_h
      end

      def parse_dual(model, lines)
        lines[2, model.constraints.count].map do |l|
          comps = l.split
          dual = model.sense == :max ? -comps[3].to_f : comps[3].to_f
          [model.constraints[comps[1]], dual]
        end.to_h
      end
    end
  end
end
