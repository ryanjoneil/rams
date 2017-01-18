require './lib/rams.rb'
require 'test/unit'

# RAMS::Formatters::LP tests
class TestFormattersLP < Test::Unit::TestCase
  def test_leading_plus_is_stripped
    m = RAMS::Model.new
    x = m.variable
    m.objective = 3 * x
    m.constrain(2 * x <= 10)
    lp = m.to_lp
    assert_match(/obj: 3.0 v\d+/, lp)
    assert_match(/c\d+: 2.0 v\d+ <= 10.0/, lp)
  end

  def test_continuous_variables
    m = RAMS::Model.new
    m.variable
    m.variable low: nil
    m.variable low: 1, high: 5
    lp = m.to_lp
    assert_match(/0.0 <= v\d+ <= \+inf/, lp)
    assert_match(/-inf <= v\d+ <= \+inf/, lp)
    assert_match(/1 <= v\d+ <= 5/, lp)
  end

  def test_binary_variables
    m = RAMS::Model.new
    m.variable type: :binary
    m.variable type: :binary, low: 1.0
    m.variable type: :binary, high: 0.0
    lp = m.to_lp
    assert_match(/0.0 <= v\d+ <= 1.0/, lp)
    assert_match(/1.0 <= v\d+ <= 1.0/, lp)
    assert_match(/0.0 <= v\d+ <= 0.0/, lp)
  end
end
