require './lib/rams.rb'
require 'test/unit'

# RAMS::Variable tests
class TestVariable < Test::Unit::TestCase
  def test_variable_initialize
    x = RAMS::Variable.new
    assert_equal 1.0, x.coefficients[x]
  end

  def test_variable_hash
    x1 = RAMS::Variable.new
    x2 = RAMS::Variable.new
    assert_equal x1.coefficients[x1], 1
    assert_equal x1.coefficients[x2], 0
    assert_equal x2.coefficients[x1], 0
    assert_equal x2.coefficients[x2], 1
    assert_not_equal x1.hash, x2.hash
  end

  def test_variable_add_variable
    x1 = RAMS::Variable.new
    x2 = RAMS::Variable.new
    e = x1 + x2 + x1
    assert_equal 2.0, e.coefficients[x1]
    assert_equal 1.0, e.coefficients[x2]
    assert_equal 0.0, e.constant
  end

  def test_variable_add_constant
    x = RAMS::Variable.new
    e = x + 2.5
    assert_equal 1.0, e.coefficients[x]
    assert_equal 2.5, e.constant
  end

  def test_float_add_variable
    x = RAMS::Variable.new
    e = 2.5 + x
    assert_equal 1.0, e.coefficients[x]
    assert_equal 2.5, e.constant
  end

  def test_fixnum_add_variable
    x = RAMS::Variable.new
    e = 2 + x
    assert_equal 1.0, e.coefficients[x]
    assert_equal 2, e.constant
  end

  def test_variable_subtract_variable
    x1 = RAMS::Variable.new
    x2 = RAMS::Variable.new
    e = x1 - x2 - x1
    assert_equal 0.0, e.coefficients[x1]
    assert_equal(-1.0, e.coefficients[x2])
    assert_equal 0.0, e.constant
  end

  def test_variable_subtract_constant
    x = RAMS::Variable.new
    e = x - 2.5
    assert_equal 1.0, e.coefficients[x]
    assert_equal(-2.5, e.constant)
  end

  def test_float_subtract_variable
    x = RAMS::Variable.new
    e = 2.5 - x
    assert_equal(-1.0, e.coefficients[x])
    assert_equal 2.5, e.constant
  end

  def test_fixnum_subtract_variable
    x = RAMS::Variable.new
    e = 2 - x
    assert_equal(-1.0, e.coefficients[x])
    assert_equal 2, e.constant
  end

  def test_variable_times_constant
    x = RAMS::Variable.new
    e = x * 2.5 + 3
    assert_equal 2.5, e.coefficients[x]
    assert_equal 3, e.constant
  end

  def test_float_times_variable
    x = RAMS::Variable.new
    e = 2.5 * x
    assert_equal 2.5, e.coefficients[x]
    assert_equal 0, e.constant
  end

  def test_variable_times_variable
    x1 = RAMS::Variable.new
    x2 = RAMS::Variable.new
    assert_raise(NotImplementedError) { x1 * x2 }
  end

  def test_variable_over_constant
    x = RAMS::Variable.new
    e = x / 2 + 3
    assert_equal 0.5, e.coefficients[x]
    assert_equal 3, e.constant
  end

  def test_variable_over_variable
    x1 = RAMS::Variable.new
    x2 = RAMS::Variable.new
    assert_raise(NotImplementedError) { x1 / x2 }
  end
end
