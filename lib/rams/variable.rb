require_relative 'expression'

module RAMS
  BINARY = :binary
  CONTINUOUS = :continuous
  INTEGER = :integer

  # A Variable has bounds and a type.
  class Variable < Expression
    attr_reader :id, :low, :high, :type

    def initialize(low = 0.0, high = nil, type = CONTINUOUS)
      @id = Variable.next_id
      @low = low
      @high = high
      @type = type
      super({ self => 1.0 })
    end

    def name
      "x#{id}"
    end

    def to_s
      "#{low.nil? ? '-inf' : low} <= #{name} <= #{high.nil? ? '+inf' : high}"
    end

    @@NEXT_ID = 0

    def self.next_id
      @@NEXT_ID += 1
    end
  end
end
