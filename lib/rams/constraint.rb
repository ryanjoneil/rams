module RAMS
  # A RAMS::Constraint must take the form:
  #
  #     lhs ==|<=|>= rhs
  #
  # lhs is a hash of variables to coefficients and rhs is a constant.
  # The sense is the sense of the inequality and must be closed.
  class Constraint
    attr_reader :lhs, :sense, :rhs

    def initialize(lhs, sense, rhs)
      @lhs = lhs.dup
      @sense = sense
      @rhs = rhs

      validate
    end

    private

    def validate
      validate_lhs
      validate_sense
      validate_rhs
    end

    def validate_lhs
      raise(ArgumentError, 'invalid lhs') if lhs.empty?
    end

    def validate_sense
      raise(ArgumentError, 'invalid sense') unless [:<=, :==, :>=].index(sense)
    end

    def validate_rhs
      raise(ArgumentError, 'invalid rhs') unless rhs.is_a? Numeric
    end
  end
end
