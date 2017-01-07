require './lib/rams.rb'
require 'test/unit'

# RAMS::Model tests
class TestModel < Test::Unit::TestCase
  # rubocop:disable MethodLength
  def test_simple
    m = RAMS::Model.new

    x1 = m.variable
    x2 = m.variable

    m.constrain(x1 + x2 <= 1)
    m.constrain(x2 >= 0.5)

    m.sense = :max
    m.objective = x1 + (2 * x2)

    m.solver = :glpk
    m.verbose = true
    puts m.to_s
    m.solve
  end
  # rubocop:enable MethodLength
end
