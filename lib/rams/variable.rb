require_relative 'expression'

module RAMS
  BINARY = :binary
  CONTINUOUS = :continuous
  INTEGER = :integer

  # A Variable has a name, bounds, and a type.
  class Variable < Expression
    attr_reader :name, :low, :high, :type

    def initialize(name = '', low = 0.0, high = nil, type = CONTINUOUS)
      @name = name
      @low = low
      @high = high
      @type = type
      super({ self => 1.0 })
    end

    def to_s
      name.to_s
    end
  end
end
