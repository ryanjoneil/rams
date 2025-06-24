require 'nokogiri'
require_relative 'solver'

module RAMS
  module Solvers
    # Interface to CPLEX
    class CPLEX < Solver
      def solve_and_parse(model, model_path, solution_path)
        call_solver model, model_path, solution_path
        return RAMS::Solution.new(:infeasible, nil, {}, {}) unless File.exist? solution_path
        parse_solution model, File.read(solution_path)
      end

      def solver_command(model_path, solution_path, args)
        [solver_executable('cplex', 'cplex'), '-c', "read #{model_path}"] + args + ['optimize', "write #{solution_path}"]
      end

      private

      def parse_solution(model, solution_text)
        xml_doc = Nokogiri::XML solution_text
        RAMS::Solution.new(
          parse_status(model, xml_doc),
          parse_objective(model, xml_doc),
          parse_primal(model, xml_doc),
          parse_dual(model, xml_doc)
        )
      end

      def parse_status(_model, xml_doc)
        status = xml_doc.css('CPLEXSolution').css('header').first['solutionStatusString']
        return :optimal if status =~ /optimal/i
        return :feasible if status =~ /feasible/i
        return :unbounded if status =~ /unbounded/i
        :unknown
      end

      def parse_objective(_model, xml_doc)
        xml_doc.css('CPLEXSolution').css('header').first['objectiveValue'].to_f
      end

      def parse_primal(model, xml_doc)
        xml_doc.css('CPLEXSolution').css('variables').css('variable').map do |v|
          [model.variables[v['name']], v['value'].to_f]
        end.to_h
      end

      def parse_dual(model, xml_doc)
        xml_doc.css('CPLEXSolution').css('linearConstraints').css('constraint').map do |c|
          [model.constraints[c['name']], c['dual'].to_f]
        end.to_h
      end
    end
  end
end
