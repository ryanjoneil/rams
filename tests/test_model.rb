require './lib/rams.rb'
require 'test/unit'

# RAMS::Model tests
class TestModel < Test::Unit::TestCase
  # rubocop:disable AbcSize, MethodLength
  def test_simple
    m = RAMS::Model.new
    x1 = m.variable
    x2 = m.variable

    c1 = m.constrain(x1 + x2 <= 1)
    c2 = m.constrain(x1 >= 0.5)

    m.sense = :max
    m.objective = x1 + (2 * x2)
    solution = m.solve

    assert_equal :optimal, solution.status
    assert_in_delta 1.5, solution.objective, 10e-7
    assert_in_delta 0.5, solution[x1], 10e-7
    assert_in_delta 0.5, solution[x2], 10e-7
    assert_in_delta 2.0, solution.dual[c1], 10e-7
    assert_in_delta(-1.0, solution.dual[c2], 10e-7)
  end
  # rubocop:enable AbcSize, MethodLength

  # rubocop:disable AbcSize, MethodLength
  def test_binary
    m = RAMS::Model.new

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

  def test_integer
    m = RAMS::Model.new

    x = m.variable type: :integer
    m.constrain(x <= 1.5)

    m.sense = :max
    m.objective = x
    solution = m.solve

    assert_equal :optimal, solution.status
    assert_in_delta 1.0, solution.objective, 10e-7
    assert_in_delta 1.0, solution[x], 10e-7
  end

  # rubocop:disable MethodLength
  def test_infeasible
    m = RAMS::Model.new

    x1 = m.variable type: :binary, high: 0
    x2 = m.variable type: :binary, high: 0
    m.constrain(x1 + x2 >= 1)

    m.sense = :min
    m.objective = 2 * x1 + x2
    solution = m.solve

    assert_equal :infeasible, solution.status
    assert_in_delta 0.0, solution.objective, 10e-7
    assert_in_delta 0.0, solution[x1], 10e-7
    assert_in_delta 0.0, solution[x2], 10e-7
  end
  # rubocop:enable MethodLength

  def test_unbounded
    m = RAMS::Model.new

    x = m.variable type: :integer
    m.constrain(x >= 1)

    m.sense = :max
    m.objective = x
    solution = m.solve

    assert_equal :undefined, solution.status
  end
end
