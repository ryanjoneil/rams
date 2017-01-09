require_relative 'solver'

module RAMS
  module Solvers
    # Interface to COIN-OR Branch-and-Cut
    class CBC < Solver
      def solver_command(model_path, solution_path, args)
        ['cbc', model_path] + args + ['printingOptions', 'all', 'solve', 'solution', solution_path]
      end

      private

      def parse_status(_model, lines)
        return :undefined if lines.count < 1
        status = lines.first
        return :optimal if status =~ /Optimal/
        return :feasible if status =~ /Stopped/
        return :infeasible if status =~ /Infeasible/
        return :unbounded if status =~ /Unbounded/
        :undefined
      end

      def parse_objective(model, lines)
        return nil if lines.count < 1
        objective = lines.first.split[-1].to_f
        model.sense == :max ? -objective : objective
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
          dual = model.sense == :max ? -comps[3].to_f : comps[3].to_f
          [model.constraints[comps[1]], dual]
        end.to_h
      end
    end
  end
end
