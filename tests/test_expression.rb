require './lib/rams.rb'
require 'test/unit'

# RAMS::Expression tests
class TestExpression < Test::Unit::TestCase
  def test_add_expressions
    x1 = RAMS::Variable.new
    x2 = RAMS::Variable.new
    e1 = 3 * (x1 + 2 * x2 + 1)
    e2 = 2 * (x1 / 2 - x2 + 2)
    e3 = e1 + 2 * e2
    assert_equal 5, e3.coefficients[x1]
    assert_equal 2, e3.coefficients[x2]
    assert_equal 11, e3.constant
  end

  def test_subtract_expressions
    x1 = RAMS::Variable.new
    x2 = RAMS::Variable.new
    e1 = 3 * (x1 + 2 * x2 + 1)
    e2 = 2 * (x1 / 2 - x2 + 2)
    e3 = e1 - 2 * e2
    assert_equal 1, e3.coefficients[x1]
    assert_equal 10, e3.coefficients[x2]
    assert_equal(-5, e3.constant)
  end
end
