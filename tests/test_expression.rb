require './lib/rams.rb'
require 'test/unit'

# TODO
class TestVariable < Test::Unit::TestCase
  def test_variable_initialize
    x = RAMS::Variable.new 'x'
    assert_equal 'x', x.name, 'x'
    assert_equal 1.0, x.exponents[x]
  end

  def test_variable_hash
    x = RAMS::Variable.new 'x'
    assert_equal x.hash, x.object_id
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

    # TODO:
    # e = 3.1 + x
  end
end
