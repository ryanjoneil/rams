require 'open3'
require_relative '../solution'

module RAMS
  module Solvers
    # Generic solver interface
    class Solver
      def solve(model)
        model_file = write_model_file model
        begin
          get_solution model, model_file.path
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

      def get_solution(model, model_path)
        solution_path = model_path + '.sol'
        begin
          solve_and_parse model, model_path, solution_path
        ensure
          File.delete(solution_path) if File.exist?(solution_path)
        end
      end

      def solve_and_parse(model, model_path, solution_path)
        call_solver model, model_path, solution_path
        return RAMS::Solution.new(:unknown, nil, {}, {}) unless File.exist? solution_path
        parse_solution model, File.read(solution_path)
      end

      # rubocop:disable MethodLength
      def call_solver(model, model_path, solution_path)
        command = solver_command(model_path, solution_path, model.args)
        _, stdout, stderr, exit_code = Open3.popen3(*command)

        begin
          output = stdout.gets(nil) || ''
          error = output + (stderr.gets(nil) || '')
          puts output if model.verbose && output != ''
          raise error unless exit_code.value == 0
        ensure
          stdout.close
          stderr.close
        end
      end
      # rubocop:enable MethodLength

      def solver_command(_model_file, _solution_path, _args)
        raise NotImplementedError
      end

      def parse_solution(model, solution_text)
        lines = solution_text.split "\n"
        RAMS::Solution.new(
          parse_status(model, lines),
          parse_objective(model, lines),
          parse_primal(model, lines),
          parse_dual(model, lines)
        )
      end

      def parse_status(_model, _lines)
        raise NotImplementedError
      end

      def parse_objective(_model, _lines)
        raise NotImplementedError
      end

      def parse_primal(_model, _lines)
        raise NotImplementedError
      end

      def parse_dual(_model, _lines)
        raise NotImplementedError
      end
    end
  end
end
