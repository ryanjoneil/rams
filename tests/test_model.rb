require './lib/rams.rb'
require 'test/unit'

# RAMS::Model tests
# rubocop:disable ClassLength
class TestModel < Test::Unit::TestCase
  def test_simple_primal
    run_test_simple_primal :cbc if ENV['RAMS_TEST_CBC']
    run_test_simple_primal :clp if ENV['RAMS_TEST_CLP']
    run_test_simple_primal :glpk if ENV['RAMS_TEST_GLPK']
    run_test_simple_primal :highs if ENV['RAMS_TEST_HIGHS']
    run_test_simple_primal :scip if ENV['RAMS_TEST_SCIP']
  end

  def test_simple_dual
    run_test_simple_dual :cbc if ENV['RAMS_TEST_CBC']
    run_test_simple_dual :clp if ENV['RAMS_TEST_CLP']
    run_test_simple_dual :glpk if ENV['RAMS_TEST_GLPK']
    run_test_simple_dual :highs if ENV['RAMS_TEST_HIGHS']
  end


  def test_binary
    run_test_binary :cbc if ENV['RAMS_TEST_CBC']
    run_test_binary :glpk if ENV['RAMS_TEST_GLPK']
    run_test_binary :highs if ENV['RAMS_TEST_HIGHS']
    run_test_binary :scip if ENV['RAMS_TEST_SCIP']
  end

  def test_integer
    run_test_integer :cbc if ENV['RAMS_TEST_CBC']
    run_test_integer :glpk if ENV['RAMS_TEST_GLPK']
    run_test_integer :highs if ENV['RAMS_TEST_HIGHS']
    run_test_integer :scip if ENV['RAMS_TEST_SCIP']
  end

  def test_infeasible
    run_test_infeasible :cbc if ENV['RAMS_TEST_CBC']
    run_test_infeasible :clp if ENV['RAMS_TEST_CLP']
    run_test_infeasible :glpk if ENV['RAMS_TEST_GLPK']
    run_test_infeasible :highs if ENV['RAMS_TEST_HIGHS']
    run_test_infeasible :scip if ENV['RAMS_TEST_SCIP']
  end

  def test_unbounded
    run_test_unbounded :cbc if ENV['RAMS_TEST_CBC']
    run_test_unbounded :clp if ENV['RAMS_TEST_CLP']
    run_test_unbounded :glpk if ENV['RAMS_TEST_GLPK']
    run_test_unbounded :highs if ENV['RAMS_TEST_HIGHS']
    run_test_unbounded :scip if ENV['RAMS_TEST_SCIP']
  end

  def test_implication
    run_test_implication :cbc if ENV['RAMS_TEST_CBC']
    run_test_implication :glpk if ENV['RAMS_TEST_GLPK']
    run_test_implication :highs if ENV['RAMS_TEST_HIGHS']
    run_test_implication :scip if ENV['RAMS_TEST_SCIP']
  end

  # rubocop:disable MethodLength
  def run_test_simple_primal(solver, args = [])
    m = RAMS::Model.new
    m.solver = solver
    m.args = args

    x1 = m.variable low: 0.5
    x2 = m.variable

    m.constrain(x1 + x2 <= 1)

    m.sense = :max
    m.objective = x1 + (2 * x2)
    solution = m.solve

    assert_equal :optimal, solution.status
    assert_in_delta 1.5, solution.objective, 10e-7
    assert_in_delta 0.5, solution[x1], 10e-7
    assert_in_delta 0.5, solution[x2], 10e-7
  end
  # rubocop:enable MethodLength


  # rubocop:disable MethodLength
  def run_test_simple_dual(solver, args = [])
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

    assert_includes [:infeasible, :unbounded, :undefined], solution.status
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
