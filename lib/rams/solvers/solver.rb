require 'open3'

module RAMS
  module Solvers
    # Generic solver interface
    class Solver
      def solve(model)
        model_file = write_model_file model
        begin
          get_solution model, model_file
        ensure
          model_file.unlink
        end
      end

      private

      def write_model_file(model)
        model_file = Tempfile.new ['', '.lp']
        model_file.write model.to_s
        model_file.close
        model_file
      end

      def get_solution(model, model_file)
        solution_file = Tempfile.new ['', '.sol']
        begin
          solve_and_parse model, model_file, solution_file
        ensure
          solution_file.unlink
        end
      end

      def solve_and_parse(model, model_file, solution_file)
        call_solver model, model_file, solution_file
        parse_solution model, solution_file
      end

      def call_solver(model, model_file, solution_file)
        command = solver_command(model_file, solution_file) + model.args
        _, stdout, stderr, exit_code = Open3.popen3(*command)

        begin
          output = stdout.gets(nil)
          puts output if model.verbose && output != ''
          raise stderr.gets(nil) unless exit_code.value == 0
        ensure
          stdout.close
          stderr.close
        end
      end

      def solver_command(_model_file, _solution_file)
        raise NotImplementedError
      end

      def parse_solution(_model, _solution_file)
        raise NotImplementedError
      end
    end
  end
end
