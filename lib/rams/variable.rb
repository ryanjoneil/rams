require_relative 'expression'

module RAMS
  # A Variable has bounds and a type. Names are created automatically.
  #
  #    RAMS::Variable.new                     # continuous, >= 0
  #    RAMS::Variable.new low: nil            # continuous, unbounded
  #    RAMS::Variable.new low: 1, high: 2.5   # continuous, >= 1, <= 2.5
  #    RAMS::Variable.new type: :binary       # binary variable
  #    RAMS::Variable.new type: :integer      # integer variable, >= 0
  #
  class Variable < Expression
    attr_reader :id, :low, :high, :type

    def initialize(low: 0.0, high: nil, type: :continuous)
      @id = Variable.next_id

      @low = low
      @high = high
      @type = type

      super({ self => 1.0 })
    end

    def name
      "v#{id}"
    end

    def to_s
      "#{low.nil? ? '-inf' : low} <= #{name} <= #{high.nil? ? '+inf' : high}"
    end

    @next_id = 0

    def self.next_id
      @next_id += 1
    end
  end
end
