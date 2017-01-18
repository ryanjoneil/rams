module RAMS
  # A RAMS::Constraint must take the form:
  #
  #     lhs ==|<=|>= rhs
  #
  # lhs is a hash of variables to coefficients and rhs is a constant.
  # The sense is the sense of the inequality and must be closed.
  #
  class Constraint
    attr_reader :id, :lhs, :sense, :rhs

    def initialize(lhs, sense, rhs)
      @id = Variable.next_id

      @lhs = lhs.dup
      @sense = sense
      @rhs = rhs

      validate
    end

    def name
      "c#{id}"
    end

    @next_id = 0

    def self.next_id
      @next_id += 1
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
