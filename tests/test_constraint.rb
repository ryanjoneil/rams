require './lib/rams.rb'
require 'test/unit'

# RAMS::Constraint tests
class TestConstraint < Test::Unit::TestCase
  # rubocop:disable Metrics/AbcSize, MethodLength
  def test_constraints
    x1 = RAMS::Variable.new
    x2 = RAMS::Variable.new

    e1 = 3 * (x1 + 2 * x2 + 1)
    e2 = 2 * (x1 / 2 - x2 + 2)

    c1 = e1 <= e2
    c2 = e1 == e2
    c3 = e1 >= e2

    [c1, c2, c3].each do |c|
      assert_equal 2, c.lhs[x1]
      assert_equal 8, c.lhs[x2]
      assert_equal 1, c.rhs
    end

    assert_equal :<=, c1.sense
    assert_equal :==, c2.sense
    assert_equal :>=, c3.sense
  end
  # rubocop:enable Metrics/AbcSize, MethodLength
end
