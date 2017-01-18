require './lib/rams.rb'
require 'test/unit'

# RAMS::Model tests
# rubocop:disable ClassLength
class TestModel < Test::Unit::TestCase
  def test_simple
    run_test_simple :cbc
    run_test_simple :clp
    run_test_simple :cplex if ENV['RAMS_TEST_CPLEX']
    run_test_simple :glpk
    run_test_simple(:scip, ['-c', 'set presolving maxrounds 0'])
  end

  def test_binary
    run_test_binary :cbc
    run_test_binary :cplex if ENV['RAMS_TEST_CPLEX']
    run_test_binary :glpk
    run_test_binary :scip
  end

  def test_integer
    run_test_integer :cbc
    run_test_integer :cplex if ENV['RAMS_TEST_CPLEX']
    run_test_integer :glpk
    run_test_integer :scip
  end

  def test_infeasible
    run_test_infeasible :cbc
    run_test_infeasible :clp
    run_test_infeasible :cplex if ENV['RAMS_TEST_CPLEX']
    run_test_infeasible :glpk
    run_test_infeasible :scip
  end

  def test_unbounded
    run_test_unbounded :cbc
    run_test_unbounded :clp
    run_test_unbounded :cplex if ENV['RAMS_TEST_CPLEX']
    run_test_unbounded :glpk
    run_test_unbounded :scip
  end

  def test_implication
    run_test_implication :cbc
    run_test_implication :cplex if ENV['RAMS_TEST_CPLEX']
    run_test_implication :glpk
    run_test_implication :scip
  end

  # rubocop:disable MethodLength
  def run_test_simple(solver, args = [])
    m = RAMS::Model.new
    m.solver = solver
    m.args = args

    x1 = m.variable low: 0.5
    x2 = m.variable

    c = m.constrain(x1 + x2 <= 1)

    m.sense = :max
    m.objective = x1 + (2 * x2)
    solution = m.solve

    assert_equal :optimal, solution.status
    assert_in_delta 1.5, solution.objective, 10e-7
    assert_in_delta 0.5, solution[x1], 10e-7
    assert_in_delta 0.5, solution[x2], 10e-7
    assert_in_delta 2.0, solution.dual[c], 10e-7
  end
  # rubocop:enable MethodLength

  # rubocop:disable AbcSize, MethodLength
  def run_test_binary(solver, args = [])
    m = RAMS::Model.new
    m.solver = solver
    m.args = args

    x1 = m.variable type: :binary
    x2 = m.variable type: :binary
    m.constrain(x1 + x2 >= 1)

    m.sense = :min
    m.objective = 2 * x1 + x2
    solution = m.solve

    assert_equal :optimal, solution.status
    assert_in_delta 1.0, solution.objective, 10e-7
    assert_in_delta 0.0, solution[x1], 10e-7
    assert_in_delta 1.0, solution[x2], 10e-7

    m.objective = 2 * x1 + 3 * x2
    solution = m.solve

    assert_equal :optimal, solution.status
    assert_in_delta 2.0, solution.objective, 10e-7
    assert_in_delta 1.0, solution[x1], 10e-7
    assert_in_delta 0.0, solution[x2], 10e-7
  end
  # rubocop:enable AbcSize, MethodLength

  # rubocop:disable MethodLength
  def run_test_integer(solver, args = [])
    m = RAMS::Model.new
    m.solver = solver
    m.args = args

    x = m.variable type: :integer
    m.constrain(x <= 1.5)

    m.sense = :max
    m.objective = x
    solution = m.solve

    assert_equal :optimal, solution.status
    assert_in_delta 1.0, solution.objective, 10e-7
    assert_in_delta 1.0, solution[x], 10e-7
  end
  # rubocop:enable MethodLength

  def run_test_infeasible(solver, args = [])
    m = RAMS::Model.new
    m.solver = solver
    m.args = args

    x1 = m.variable type: :binary, high: 0
    x2 = m.variable type: :binary, high: 0
    m.constrain(x1 + x2 >= 1)

    m.sense = :min
    m.objective = 2 * x1 + x2
    solution = m.solve

    assert_equal :infeasible, solution.status
  end

  def run_test_unbounded(solver, args = [])
    m = RAMS::Model.new
    m.solver = solver
    m.args = args

    x = m.variable type: :integer
    m.constrain(x >= 1)

    m.sense = :max
    m.objective = x
    solution = m.solve

    assert_includes [:unbounded, :undefined], solution.status
  end

  # rubocop:disable MethodLength
  def run_test_implication(solver, args = [])
    m = RAMS::Model.new
    m.solver = solver
    m.args = args

    x1 = m.variable type: :binary
    x2 = m.variable type: :binary
    m.constrain(x1 + x2 <= 1)
    m.constrain(x1 <= x2)

    m.sense = :max
    m.objective = 2 * x1 + x2
    solution = m.solve

    assert_equal :optimal, solution.status
    assert_equal 0, solution[x1]
    assert_equal 1, solution[x2]
  end
  # rubocop:enable MethodLength
end
# rubocop:enable ClassLength
