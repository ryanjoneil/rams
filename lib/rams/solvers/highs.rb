require_relative 'solver'

module RAMS
  module Solvers
    # Interface to HiGHS solver
    class HiGHS < Solver
      def solver_command(model_path, solution_path, args)
        [solver_executable('highs', 'highs'), model_path, '--solution_file', solution_path] + args
      end

      private

      def parse_status(_model, lines)
        status_idx = lines.index { |l| l =~ /^Model status/ }
        return :undefined unless status_idx

        # Status is on the next line after "Model status"
        status = lines[status_idx + 1]
        return :undefined unless status

        return :optimal if status =~ /optimal/i
        return :feasible if status =~ /^feasible/i
        return :infeasible if status =~ /infeasible/i
        return :unbounded if status =~ /unbounded/i
        :undefined
      end

      def parse_objective(_model, lines)
        objective_line = lines.find { |l| l =~ /^Objective/ }
        return nil unless objective_line
        objective_line.split.last.to_f
      end

      def parse_primal(model, lines)
        # Find the primal section
        start_idx = lines.index { |l| l =~ /^# Columns/ }
        return {} unless start_idx

        num_columns = lines[start_idx].split.last.to_i
        primal_values = {}

        # Parse variable values
        (1..num_columns).each do |i|
          line = lines[start_idx + i]
          next unless line

          parts = line.split
          next unless parts.length >= 2

          var_name = parts[0]
          var_value = parts[1].to_f
          variable = model.variables[var_name]
          primal_values[variable] = var_value if variable
        end

        primal_values
      end

      def parse_dual(model, lines)
        # Find the dual section
        dual_start_idx = lines.index { |l| l =~ /^# Dual solution values/ }
        return {} unless dual_start_idx


        # Check if dual solution is available
        lines = lines[dual_start_idx..-1]
        return {} if lines[dual_start_idx + 1] =~ /^None/

        # Find the rows section within dual values
        rows_idx = lines.index { |l| l =~ /^# Rows/ }
        return {} unless rows_idx

        num_rows = lines[rows_idx].split.last.to_i
        dual_values = {}

        # Parse constraint dual values
        (1..num_rows).each do |i|
          line = lines[rows_idx + i]
          next unless line

          parts = line.split
          next unless parts.length >= 2

          constraint_name = parts[0]
          dual_value = parts[1].to_f
          constraint = model.constraints[constraint_name]
          dual_values[constraint] = dual_value if constraint
        end

        dual_values
      end
    end
  end
end