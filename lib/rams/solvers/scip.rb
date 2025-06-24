require 'open3'
require_relative 'solver'

module RAMS
  module Solvers
    # Interface to SCIP
    class SCIP < Solver
      def solve_and_parse(model, model_path, solution_path)
        output = call_solver model, model_path, solution_path
        parse_solution model, output
      end

      def solver_command(model_path, _solution_path, args)
        ['scip', '-c', "read #{model_path}"] + args +
          ['-c', 'optimize', '-c', 'display solution', '-c', 'display dualsolution', '-c', 'quit']
      end

      private

      def parse_status(_model, lines)
        return :undefined if lines.count < 1
        status = lines.select { |l| l =~ /^SCIP Status/ }.first
        return :optimal if status =~ /optimal/i
        return :unknown if status =~ /(unknown|infeasible or unbounded)/i
        return :infeasible if status =~ /infeasible/i
        return :unbounded if status =~ /unbounded/i
        :feasible
      end

      def parse_objective(_model, lines)
        objective = (lines.select { |l| l =~ /^objective value:/ }.first || '').split
        return nil if objective.size < 3
        objective[2].to_f
      end

      def parse_primal(model, lines)
        primal = model.variables.values.map { |v| [v, 0.0] }.to_h
        primal.merge(solution_lines(lines).map do |l|
          comps = l.split
          model.variables[comps[0]].nil? ? [] : [model.variables[comps.first], comps[1].to_f]
        end.reject(&:empty?).to_h)
      end

      def parse_dual(model, lines)
        dual = model.constraints.values.map { |c| [c, 0.0] }.to_h
        dual.merge(solution_lines(lines).map do |l|
          comps = l.split
          model.constraints[comps[0]].nil? ? [] : [model.constraints[comps[0]], dual_value(model, comps[1].to_f)]
        end.reject(&:empty?).to_h)
      end

      def solution_lines(lines)
        start_idx = lines.index { |l| l =~ /^objective value:/ }
        return [] unless start_idx
        lines[start_idx, lines.count]
      end

      def dual_value(model, dual)
        model.sense == :max ? -dual : dual
      end
    end
  end
end
